-- Migration 00179: Sync order total_price when buyer accepts listing changes
--
-- When a seller edits a listing, all pending orders are set to 'invalidated'.
-- When the buyer accepts the changes and re-submits, accept_listing_changes()
-- reverts the order to 'pending'. However, the order's total_price was still
-- set at the original offer time and does NOT reflect the seller's new price.
--
-- Fix: when the buyer accepts, pull the current listing price and:
--   - Sale orders:   set total_price = listing.price
--   - Rental orders: set deposit_amount = listing.deposit_amount
--                    (total_price for rentals depends on rate × duration;
--                     the Flutter UI already reads listing.rentalXxxPrice
--                     for display, so only the stored deposit is updated here)

CREATE OR REPLACE FUNCTION public.accept_listing_changes(p_order_id uuid)
RETURNS jsonb
LANGUAGE plpgsql SECURITY DEFINER
SET search_path = ''
AS $$
DECLARE
  v_order   RECORD;
  v_listing RECORD;
BEGIN
  SELECT * INTO v_order
  FROM public.orders
  WHERE id = p_order_id;

  IF NOT FOUND THEN
    RETURN jsonb_build_object('success', false, 'error', 'Order not found');
  END IF;

  -- Only the buyer may call this
  IF v_order.buyer_id != auth.uid() THEN
    RETURN jsonb_build_object('success', false, 'error', 'Unauthorized');
  END IF;

  -- Only meaningful for invalidated orders
  IF v_order.status != 'invalidated' THEN
    RETURN jsonb_build_object(
      'success', true,
      'note', 'Order is not invalidated — no action taken'
    );
  END IF;

  -- Fetch the current listing to get up-to-date pricing
  SELECT * INTO v_listing
  FROM public.listings
  WHERE id = v_order.listing_id;

  IF NOT FOUND THEN
    RETURN jsonb_build_object('success', false, 'error', 'Listing not found');
  END IF;

  -- Revert to pending, clear the snapshot, and sync prices.
  -- NOTE: For sale orders, total_price is simply the listing price — update it.
  --       For rental orders, total_price = rate × duration which depends on the
  --       rate type (daily/weekly/monthly) the buyer originally chose; we sync
  --       deposit_amount only since that is a flat value from the listing.
  UPDATE public.orders
  SET
    status           = 'pending',
    listing_snapshot = NULL,
    -- Sync sale price to current listing price
    total_price      = CASE
                         WHEN v_order.order_type = 'sale'
                           THEN v_listing.price
                         ELSE v_order.total_price  -- keep existing for rental
                       END,
    -- Sync deposit (applies to both sale and rental if seller changed it)
    deposit_amount   = COALESCE(v_listing.deposit_amount, 0),
    updated_at       = now()
  WHERE id = p_order_id;

  -- Notify the seller so they know the buyer re-entered the queue.
  -- NOTE: action_url matches Flutter GoRouter path for TransactionManagementScreen:
  -- AppRoutes.transactionManagementPath = '/listing/:id/transactions'
  INSERT INTO public.notifications
    (user_id, type, title, body, action_type, action_url)
  SELECT
    v_order.seller_id,
    'order_placed',
    'Buyer Re-submitted Offer',
    COALESCE(up.display_name, 'A buyer') ||
      ' has reviewed your updates and re-submitted their offer. Tap to manage.',
    'route',
    '/listing/' || v_order.listing_id::text || '/transactions'
  FROM public.user_profiles up
  WHERE up.id = auth.uid();

  RETURN jsonb_build_object(
    'success',     true,
    'status',      'pending',
    'total_price', CASE
                     WHEN v_order.order_type = 'sale' THEN v_listing.price
                     ELSE v_order.total_price
                   END
  );
END;
$$;

GRANT EXECUTE ON FUNCTION public.accept_listing_changes(uuid) TO authenticated;

COMMENT ON FUNCTION public.accept_listing_changes IS
'Buyer accepts listing changes: clears listing_snapshot, reverts invalidated
order to pending, syncs total_price (sale) and deposit_amount to current
listing values, and notifies the seller with a deep-link to Manage Transactions.
(Migration 00179: added price sync on re-submit)';

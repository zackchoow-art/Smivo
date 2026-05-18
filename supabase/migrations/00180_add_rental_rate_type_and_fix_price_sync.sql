-- Migration 00180: Add rental_rate_type to orders table and update accept_listing_changes
--
-- PROBLEM: When a seller edits a rental listing and the buyer re-submits an offer,
-- the order's total_price cannot be recalculated server-side because the rate type
-- (day/week/month) chosen by the buyer was never stored on the order row.
--
-- FIX:
-- 1. Add rental_rate_type column (text, nullable) to the orders table.
--    Existing rows default to NULL — no backfill needed because only future
--    accept_listing_changes calls will recalculate.
-- 2. Update accept_listing_changes to recalculate total_price for rental orders
--    using the stored rate_type and current listing rates.

-- ── 1. Add rental_rate_type column ─────────────────────────────────────────
ALTER TABLE public.orders
  ADD COLUMN IF NOT EXISTS rental_rate_type text
  CHECK (rental_rate_type IN ('day', 'week', 'month'));

COMMENT ON COLUMN public.orders.rental_rate_type IS
  'Rate type the buyer chose at order creation: day | week | month. '
  'Stored so accept_listing_changes() can recalculate total_price when the '
  'seller edits rental pricing and the buyer re-accepts.';

-- ── 2. Update accept_listing_changes ───────────────────────────────────────
CREATE OR REPLACE FUNCTION public.accept_listing_changes(p_order_id uuid)
RETURNS jsonb
LANGUAGE plpgsql SECURITY DEFINER
SET search_path = ''
AS $$
DECLARE
  v_order        RECORD;
  v_listing      RECORD;
  v_new_price    numeric;
  v_duration_days  integer;
  v_duration_weeks integer;
  v_duration_months integer;
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

  -- Fetch current listing pricing
  SELECT * INTO v_listing
  FROM public.listings
  WHERE id = v_order.listing_id;

  IF NOT FOUND THEN
    RETURN jsonb_build_object('success', false, 'error', 'Listing not found');
  END IF;

  -- Calculate new total_price based on order type and rate type
  IF v_order.order_type = 'sale' THEN
    -- Sale: always the current listing price
    v_new_price := v_listing.price;

  ELSIF v_order.order_type = 'rental' AND v_order.rental_rate_type IS NOT NULL
        AND v_order.rental_start_date IS NOT NULL
        AND v_order.rental_end_date IS NOT NULL THEN
    -- Rental: recalculate using the stored rate type and current listing rates.
    -- NOTE: Duration is computed from the stored dates so the buyer's originally
    -- chosen period is preserved — only the rate amount changes.
    CASE v_order.rental_rate_type
      WHEN 'day' THEN
        v_duration_days := GREATEST(
          1,
          (v_order.rental_end_date::date - v_order.rental_start_date::date)::integer
        );
        v_new_price := COALESCE(v_listing.rental_daily_price, 0) * v_duration_days;

      WHEN 'week' THEN
        v_duration_weeks := GREATEST(
          1,
          ROUND(
            (v_order.rental_end_date::date - v_order.rental_start_date::date)::numeric / 7
          )
        );
        v_new_price := COALESCE(v_listing.rental_weekly_price, 0) * v_duration_weeks;

      WHEN 'month' THEN
        v_duration_months := GREATEST(
          1,
          ROUND(
            (v_order.rental_end_date::date - v_order.rental_start_date::date)::numeric / 30
          )
        );
        v_new_price := COALESCE(v_listing.rental_monthly_price, 0) * v_duration_months;

      ELSE
        -- Unknown rate type — keep existing price as a safe fallback
        v_new_price := v_order.total_price;
    END CASE;

  ELSE
    -- No rate_type stored (legacy orders) — keep existing price
    v_new_price := v_order.total_price;
  END IF;

  -- Revert to pending, clear the snapshot, and sync prices
  UPDATE public.orders
  SET
    status           = 'pending',
    listing_snapshot = NULL,
    total_price      = v_new_price,
    -- Always sync deposit from current listing (applies to both types)
    deposit_amount   = COALESCE(v_listing.deposit_amount, 0),
    updated_at       = now()
  WHERE id = p_order_id;

  -- Notify the seller so they know the buyer re-entered the queue.
  -- NOTE: action_url matches Flutter GoRouter path for TransactionManagementScreen.
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
    'total_price', v_new_price
  );
END;
$$;

GRANT EXECUTE ON FUNCTION public.accept_listing_changes(uuid) TO authenticated;

COMMENT ON FUNCTION public.accept_listing_changes IS
'Buyer accepts listing changes: clears listing_snapshot, reverts invalidated
order to pending, syncs total_price to current listing prices (sale: listing.price,
rental: rate × original_duration), and notifies the seller.
(Migration 00180: added rental_rate_type-based price recalculation)';

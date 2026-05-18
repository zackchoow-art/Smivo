-- Migration 00178: Fix accept_listing_changes seller notification action_url
--
-- The previous action_url '/seller/transactions/{listing_id}' did not match
-- any registered GoRouter route in the Flutter app. The correct deep-link path
-- for the Manage Transactions page is '/listing/:id/transactions'.
-- This migration replaces the function body with the corrected URL only.

CREATE OR REPLACE FUNCTION public.accept_listing_changes(p_order_id uuid)
RETURNS jsonb
LANGUAGE plpgsql SECURITY DEFINER
SET search_path = ''
AS $$
DECLARE
  v_order RECORD;
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
    RETURN jsonb_build_object('success', true, 'note', 'Order is not invalidated — no action taken');
  END IF;

  -- Revert to pending and clear the snapshot
  UPDATE public.orders
  SET
    status           = 'pending',
    listing_snapshot = NULL,
    updated_at       = now()
  WHERE id = p_order_id;

  -- Notify the seller so they know the buyer re-entered the queue.
  -- NOTE: action_url matches the Flutter GoRouter path for TransactionManagementScreen:
  -- AppRoutes.transactionManagementPath = '/listing/:id/transactions'
  -- Clicking the push notification will deep-link directly to that page.
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

  RETURN jsonb_build_object('success', true, 'status', 'pending');
END;
$$;

GRANT EXECUTE ON FUNCTION public.accept_listing_changes(uuid) TO authenticated;

COMMENT ON FUNCTION public.accept_listing_changes IS
'Buyer accepts listing changes: clears listing_snapshot and reverts
invalidated order back to pending so the seller can re-accept.
Sends a notification to the seller with a deep-link to Manage Transactions.
(Migration 00178: corrected action_url from /seller/transactions to /listing/{id}/transactions)';

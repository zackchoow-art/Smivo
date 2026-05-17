-- ============================================================
-- Migration 00176: listing_snapshot + accept_listing_changes RPC
-- ============================================================
-- When a seller edits a listing, pending orders are set to
-- 'invalidated' (migration 00171). This migration adds a
-- listing_snapshot column so the state of the listing AT THE
-- MOMENT OF INVALIDATION is preserved for buyer diff display.
--
-- Buyers who had a pending offer can see what changed and then
-- call accept_listing_changes() to clear the snapshot and
-- revert their order to 'pending' so the seller can re-accept.
-- ============================================================

-- 1. Add snapshot column (nullable — only populated on invalidation)
ALTER TABLE public.orders
  ADD COLUMN IF NOT EXISTS listing_snapshot jsonb;

COMMENT ON COLUMN public.orders.listing_snapshot IS
'Snapshot of key listing fields captured at the moment the order
was invalidated (seller edited the listing). Null for all other
statuses. Used by the buyer detail screen to show a before/after
diff so buyers know exactly what changed. Cleared when the buyer
calls accept_listing_changes().';

-- ============================================================
-- 2. RPC: accept_listing_changes
-- ============================================================
-- Called by the buyer from the listing detail screen after
-- reviewing the diff. Transitions the order from 'invalidated'
-- back to 'pending' and clears the snapshot so the buyer's
-- offer re-enters the seller's queue.
--
-- Security notes:
--   - SECURITY DEFINER: needs to bypass RLS on orders table
--     because buyers can only read/update their own rows and
--     the status filter is enforced inside the function.
--   - Validates that the caller IS the buyer_id of the order.
--   - Only invalidated orders are accepted; all other statuses
--     are a no-op to prevent replay attacks.
-- ============================================================

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

  -- Insert a notification for the seller so they know the buyer
  -- has re-entered the queue and can act on it again.
  INSERT INTO public.notifications
    (user_id, type, title, body, action_type, action_url)
  SELECT
    v_order.seller_id,
    'order_placed',
    'Buyer Re-submitted Offer',
    COALESCE(up.display_name, 'A buyer') ||
      ' has reviewed your updates and re-submitted their offer.',
    'route',
    '/seller/transactions/' || v_order.listing_id::text
  FROM public.user_profiles up
  WHERE up.id = auth.uid();

  RETURN jsonb_build_object('success', true, 'status', 'pending');
END;
$$;

GRANT EXECUTE ON FUNCTION public.accept_listing_changes(uuid) TO authenticated;

COMMENT ON FUNCTION public.accept_listing_changes IS
'Buyer accepts listing changes: clears listing_snapshot and reverts
invalidated order back to pending so the seller can re-accept.
Sends a notification to the seller. (Migration 00176)';

NOTIFY pgrst, 'reload schema';

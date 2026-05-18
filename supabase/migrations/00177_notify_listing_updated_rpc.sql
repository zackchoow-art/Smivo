-- ============================================================
-- Migration 00177: notify_listing_updated RPC
-- ============================================================
-- When a seller edits a listing, buyers who have pending or
-- invalidated orders AND users who saved the listing should
-- receive an in-app notification.
--
-- This RPC replaces the previous client-side INSERT approach in
-- listing_repository.dart. The notifications table has no INSERT
-- RLS policy (by design — all inserts must come from server-side
-- SECURITY DEFINER functions to prevent spoofed notifications).
-- This function is the authoritative, safe insertion point.
--
-- Security notes:
--   - SECURITY DEFINER: bypasses RLS to write to notifications.
--   - Validates that the caller IS the seller of the listing.
--   - Superusers (is_platform_sysadmin) may also call this for
--     admin-initiated listing edits.
--   - No-op if no eligible recipients exist.
-- ============================================================

CREATE OR REPLACE FUNCTION public.notify_listing_updated(
  p_listing_id   uuid,
  p_listing_title text
)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = ''
AS $$
DECLARE
  v_seller_id uuid;
  v_recipient_ids uuid[];
BEGIN
  -- Verify the caller owns this listing (or is a sysadmin).
  SELECT seller_id INTO v_seller_id
  FROM public.listings
  WHERE id = p_listing_id;

  IF NOT FOUND THEN
    RAISE EXCEPTION 'Listing not found: %', p_listing_id;
  END IF;

  IF v_seller_id != auth.uid() AND NOT public.is_platform_sysadmin() THEN
    RAISE EXCEPTION 'Unauthorized: only the listing owner may trigger this notification';
  END IF;

  -- Collect buyer IDs from pending/invalidated orders for this listing.
  -- Also collect user IDs who have saved the listing.
  -- Use ARRAY_AGG with DISTINCT to deduplicate across both sources.
  SELECT ARRAY(
    SELECT DISTINCT recipient_id FROM (
      -- Buyers with active (pending/invalidated) orders
      SELECT buyer_id AS recipient_id
      FROM public.orders
      WHERE listing_id = p_listing_id
        AND status IN ('pending', 'invalidated')

      UNION

      -- Users who saved the listing
      SELECT user_id AS recipient_id
      FROM public.saved_listings
      WHERE listing_id = p_listing_id
    ) AS combined
    -- Exclude the seller themselves from the recipient list
    WHERE recipient_id IS NOT NULL
      AND recipient_id != v_seller_id
  ) INTO v_recipient_ids;

  -- No recipients — nothing to do.
  IF array_length(v_recipient_ids, 1) IS NULL THEN
    RETURN;
  END IF;

  -- Batch-insert one notification per recipient.
  -- action_type = 'route' signals the push Edge Function to treat
  -- action_url as a deep-link destination (not a plain alert).
  INSERT INTO public.notifications
    (user_id, type, title, body, action_type, action_url)
  SELECT
    unnest(v_recipient_ids),
    'listing_updated',
    'Listing Updated',
    '"' || p_listing_title || '" has been updated by the seller. Tap to view the changes.',
    'route',
    '/listing/' || p_listing_id::text;
END;
$$;

-- Grant execute to authenticated users so the Flutter client can call
-- this via _client.rpc(). The SECURITY DEFINER + ownership check inside
-- the function ensures only the listing owner can trigger it.
GRANT EXECUTE ON FUNCTION public.notify_listing_updated(uuid, text) TO authenticated;

COMMENT ON FUNCTION public.notify_listing_updated IS
'Notifies all buyers with pending/invalidated orders and users who saved
the listing that the listing has been updated. Validates the caller is
the listing owner or a sysadmin. (Migration 00177)';

-- Add listing_updated to the notifications type CHECK constraint.
-- The original constraint in 00008 did not include this type.
ALTER TABLE public.notifications
  DROP CONSTRAINT IF EXISTS notifications_type_check;

ALTER TABLE public.notifications
  ADD CONSTRAINT notifications_type_check CHECK (type IN (
    'order_placed',
    'order_accepted',
    'order_cancelled',
    'order_delivered',
    'order_completed',
    'listing_updated',
    'system'
  ));

NOTIFY pgrst, 'reload schema';

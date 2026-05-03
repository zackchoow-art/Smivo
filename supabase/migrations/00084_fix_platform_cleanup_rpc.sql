-- ============================================================
-- Migration 00084: Fix clear_platform_test_data RPC
-- ============================================================
-- Same issue as 00083: missing FK-dependent tables that block
-- DELETE on parent tables (listing_views, user_blocks,
-- moderation_queue, notifications with chat_room_id).
-- ============================================================

CREATE OR REPLACE FUNCTION public.clear_platform_test_data()
RETURNS jsonb LANGUAGE plpgsql SECURITY DEFINER AS $$
BEGIN
  -- NOTE: Sysadmin only — checked against admin_users
  IF NOT public.is_platform_sysadmin() THEN
    RAISE EXCEPTION 'Permission denied: sysadmin only';
  END IF;

  INSERT INTO public.admin_audit_logs (admin_id, action, target_type, target_id, payload)
  VALUES (auth.uid(), 'platform_data_purge', 'platform', 'all',
    jsonb_build_object('note', 'Pre-launch platform-wide test data purge', 'timestamp', now()));

  -- Order matters: children before parents

  -- Order-linked
  DELETE FROM public.rental_extensions;
  DELETE FROM public.order_evidence;

  -- Chat-linked
  DELETE FROM public.messages;

  -- Listing-linked (must come before listings)
  DELETE FROM public.listing_views;
  DELETE FROM public.moderation_queue;
  DELETE FROM public.listing_moderation_notices;
  DELETE FROM public.moderation_drafts;
  DELETE FROM public.saved_listings;
  DELETE FROM public.listing_images;

  -- Chat rooms and orders reference listings
  DELETE FROM public.chat_rooms;
  DELETE FROM public.orders;

  -- Now safe to delete listings
  DELETE FROM public.listings;

  -- User-linked
  DELETE FROM public.user_blocks;
  DELETE FROM public.content_reports;
  DELETE FROM public.user_feedbacks;
  DELETE FROM public.contribution_ledger;
  DELETE FROM public.notifications;
  DELETE FROM public.user_bans;
  DELETE FROM public.user_active_sessions;
  DELETE FROM public.user_heartbeats;
  DELETE FROM public.hourly_active_users;

  RETURN jsonb_build_object('status', 'success', 'scope', 'platform', 'purged_at', now());
END;
$$;

GRANT EXECUTE ON FUNCTION public.clear_platform_test_data() TO authenticated;

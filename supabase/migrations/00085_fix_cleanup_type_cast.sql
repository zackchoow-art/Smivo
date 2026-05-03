-- ============================================================
-- Migration 00085: Fix cleanup RPCs (consolidated)
-- ============================================================
-- Fixes from 00083/00084:
--   1. moderation_queue.target_id is uuid, not text — no cast needed
--   2. content_reports must be deleted BEFORE listings/chat_rooms
--      due to ON DELETE SET NULL causing unique constraint violations
--   3. admin_audit_logs.target_id is uuid — cannot insert text 'all'
--   4. p_school_id is already uuid — no ::text cast needed
-- ============================================================

-- ── School-scoped cleanup ──────────────────────────────────────
DROP FUNCTION IF EXISTS public.clear_school_test_data(uuid);
CREATE FUNCTION public.clear_school_test_data(p_school_id uuid)
RETURNS jsonb LANGUAGE plpgsql SECURITY DEFINER AS $$
DECLARE
  v_listing_ids uuid[]; v_user_ids uuid[]; v_order_ids uuid[]; v_room_ids uuid[];
BEGIN
  IF NOT public.is_platform_sysadmin() THEN RAISE EXCEPTION 'Permission denied: sysadmin only'; END IF;
  SELECT array_agg(id) INTO v_listing_ids FROM public.listings WHERE school_id = p_school_id;
  SELECT array_agg(id) INTO v_user_ids FROM public.user_profiles WHERE school_id = p_school_id;
  IF v_listing_ids IS NOT NULL THEN
    SELECT array_agg(id) INTO v_order_ids FROM public.orders WHERE listing_id = ANY(v_listing_ids);
    SELECT array_agg(id) INTO v_room_ids FROM public.chat_rooms WHERE listing_id = ANY(v_listing_ids);
    IF v_order_ids IS NOT NULL THEN
      DELETE FROM public.rental_extensions WHERE order_id = ANY(v_order_ids);
      DELETE FROM public.order_evidence WHERE order_id = ANY(v_order_ids);
    END IF;
    IF v_room_ids IS NOT NULL THEN
      DELETE FROM public.messages WHERE chat_room_id = ANY(v_room_ids);
      DELETE FROM public.notifications WHERE chat_room_id = ANY(v_room_ids);
      DELETE FROM public.content_reports WHERE chat_room_id = ANY(v_room_ids);
    END IF;
    -- NOTE: content_reports before listings/chat_rooms to avoid ON DELETE SET NULL unique violations
    IF v_user_ids IS NOT NULL THEN
      DELETE FROM public.content_reports WHERE reporter_id = ANY(v_user_ids) OR reported_user_id = ANY(v_user_ids);
    END IF;
    DELETE FROM public.content_reports WHERE listing_id = ANY(v_listing_ids);
    DELETE FROM public.listing_views WHERE listing_id = ANY(v_listing_ids);
    DELETE FROM public.moderation_queue WHERE target_id = ANY(v_listing_ids);
    DELETE FROM public.chat_rooms WHERE listing_id = ANY(v_listing_ids);
    DELETE FROM public.orders WHERE listing_id = ANY(v_listing_ids);
    DELETE FROM public.saved_listings WHERE listing_id = ANY(v_listing_ids);
    DELETE FROM public.listing_images WHERE listing_id = ANY(v_listing_ids);
    DELETE FROM public.listing_moderation_notices WHERE listing_id = ANY(v_listing_ids);
    DELETE FROM public.listings WHERE id = ANY(v_listing_ids);
  END IF;
  IF v_user_ids IS NOT NULL THEN
    DELETE FROM public.user_blocks WHERE user_id = ANY(v_user_ids) OR blocked_user_id = ANY(v_user_ids);
    DELETE FROM public.content_reports WHERE reporter_id = ANY(v_user_ids) OR reported_user_id = ANY(v_user_ids);
    DELETE FROM public.user_feedbacks WHERE user_id = ANY(v_user_ids);
    DELETE FROM public.contribution_ledger WHERE user_id = ANY(v_user_ids);
    DELETE FROM public.notifications WHERE user_id = ANY(v_user_ids);
    DELETE FROM public.user_bans WHERE user_id = ANY(v_user_ids);
    DELETE FROM public.user_active_sessions WHERE user_id = ANY(v_user_ids);
    DELETE FROM public.user_heartbeats WHERE user_id = ANY(v_user_ids);
  END IF;
  -- NOTE: target_id is uuid — use p_school_id directly, no ::text cast
  INSERT INTO public.admin_audit_logs (admin_id, action, target_type, target_id, payload)
  VALUES (auth.uid(), 'school_data_purge', 'school', p_school_id,
    jsonb_build_object('school_id', p_school_id, 'timestamp', now()));
  RETURN jsonb_build_object('status', 'success', 'scope', 'school', 'school_id', p_school_id, 'purged_at', now());
END;
$$;
GRANT EXECUTE ON FUNCTION public.clear_school_test_data(uuid) TO authenticated;

-- ── Platform-wide cleanup ──────────────────────────────────────
DROP FUNCTION IF EXISTS public.clear_platform_test_data();
CREATE FUNCTION public.clear_platform_test_data()
RETURNS jsonb LANGUAGE plpgsql SECURITY DEFINER AS $$
BEGIN
  IF NOT public.is_platform_sysadmin() THEN RAISE EXCEPTION 'Permission denied: sysadmin only'; END IF;
  -- NOTE: target_id is uuid — use nil UUID as placeholder for platform-wide scope
  INSERT INTO public.admin_audit_logs (admin_id, action, target_type, target_id, payload)
  VALUES (auth.uid(), 'platform_data_purge', 'platform', '00000000-0000-0000-0000-000000000000'::uuid,
    jsonb_build_object('note', 'Pre-launch platform-wide test data purge', 'timestamp', now()));
  DELETE FROM public.rental_extensions;
  DELETE FROM public.order_evidence;
  DELETE FROM public.messages;
  -- NOTE: content_reports before listings/chat_rooms to avoid ON DELETE SET NULL unique violations
  DELETE FROM public.content_reports;
  DELETE FROM public.listing_views;
  DELETE FROM public.moderation_queue;
  DELETE FROM public.listing_moderation_notices;
  DELETE FROM public.moderation_drafts;
  DELETE FROM public.saved_listings;
  DELETE FROM public.listing_images;
  DELETE FROM public.chat_rooms;
  DELETE FROM public.orders;
  DELETE FROM public.listings;
  DELETE FROM public.user_blocks;
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

NOTIFY pgrst, 'reload schema';

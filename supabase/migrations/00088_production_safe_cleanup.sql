-- ============================================================
-- Migration 00088: Production-safe school-scoped cleanup
-- ============================================================
-- Migration 00086/00087 used full-table deletes (WHERE true)
-- for pre-launch convenience. This migration restores proper
-- school-scoped deletion so the function is safe for production
-- use with multiple schools.
--
-- Changes:
--   1. user_feedbacks: delete only for school users (v_user_ids)
--   2. contribution_ledger: delete only for school users
--   3. admin_audit_logs: NO LONGER DELETED — audit trail must
--      be preserved in production
-- ============================================================

DROP FUNCTION IF EXISTS public.clear_school_test_data(uuid);
CREATE FUNCTION public.clear_school_test_data(p_school_id uuid)
RETURNS jsonb LANGUAGE plpgsql SECURITY DEFINER AS $$
DECLARE
  v_listing_ids uuid[]; v_user_ids uuid[]; v_order_ids uuid[]; v_room_ids uuid[];
BEGIN
  IF NOT public.is_platform_sysadmin() THEN RAISE EXCEPTION 'Permission denied: sysadmin only'; END IF;

  SELECT array_agg(id) INTO v_listing_ids FROM public.listings WHERE school_id = p_school_id;
  SELECT array_agg(id) INTO v_user_ids FROM public.user_profiles WHERE school_id = p_school_id;

  -- ── Order & chat-linked data ─────────────────────────────────
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

  -- ── User-linked data (school-scoped via v_user_ids) ──────────
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

  -- NOTE: admin_audit_logs are intentionally NOT deleted.
  -- Audit trail must be preserved in production for compliance.

  -- Record this cleanup action in the audit log
  INSERT INTO public.admin_audit_logs (admin_id, action, target_type, target_id, payload)
  VALUES (auth.uid(), 'school_data_purge', 'school', p_school_id,
    jsonb_build_object('school_id', p_school_id, 'timestamp', now()));

  RETURN jsonb_build_object('status', 'success', 'scope', 'school', 'school_id', p_school_id, 'purged_at', now());
END;
$$;
GRANT EXECUTE ON FUNCTION public.clear_school_test_data(uuid) TO authenticated;

NOTIFY pgrst, 'reload schema';

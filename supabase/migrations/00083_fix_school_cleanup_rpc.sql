-- ============================================================
-- Migration 00083: Fix clear_school_test_data RPC
-- ============================================================
-- Previous version was missing FK-dependent tables:
--   - listing_views       (references listings)
--   - user_blocks         (references user_profiles × 2 columns)
--   - moderation_queue    (references listings/users by target_id)
--   - notifications with chat_room_id (references chat_rooms)
-- These caused 409 Conflict (FK violation) when cleanup was called.
-- ============================================================

CREATE OR REPLACE FUNCTION public.clear_school_test_data(p_school_id uuid)
RETURNS jsonb LANGUAGE plpgsql SECURITY DEFINER AS $$
DECLARE
  v_listing_ids uuid[];
  v_user_ids    uuid[];
  v_order_ids   uuid[];
  v_room_ids    uuid[];
BEGIN
  -- NOTE: Sysadmin only — checked against admin_users
  IF NOT public.is_platform_sysadmin() THEN
    RAISE EXCEPTION 'Permission denied: sysadmin only';
  END IF;

  SELECT array_agg(id) INTO v_listing_ids
    FROM public.listings WHERE school_id = p_school_id;

  SELECT array_agg(id) INTO v_user_ids
    FROM public.user_profiles WHERE school_id = p_school_id;

  -- ── Orders and chat rooms linked to listings ─────────────────
  IF v_listing_ids IS NOT NULL THEN
    SELECT array_agg(id) INTO v_order_ids
      FROM public.orders WHERE listing_id = ANY(v_listing_ids);
    SELECT array_agg(id) INTO v_room_ids
      FROM public.chat_rooms WHERE listing_id = ANY(v_listing_ids);

    IF v_order_ids IS NOT NULL THEN
      DELETE FROM public.rental_extensions WHERE order_id  = ANY(v_order_ids);
      DELETE FROM public.order_evidence     WHERE order_id  = ANY(v_order_ids);
    END IF;

    IF v_room_ids IS NOT NULL THEN
      DELETE FROM public.messages      WHERE chat_room_id = ANY(v_room_ids);
      -- NOTE: notifications.chat_room_id added in migration 00064
      DELETE FROM public.notifications WHERE chat_room_id = ANY(v_room_ids);
    END IF;

    -- listing_views references listings ON DELETE CASCADE but we delete explicitly
    DELETE FROM public.listing_views              WHERE listing_id = ANY(v_listing_ids);
    -- moderation_queue stores target_id as text uuid
    DELETE FROM public.moderation_queue           WHERE target_id = ANY(
      SELECT unnest(v_listing_ids)::text
    );
    DELETE FROM public.chat_rooms                 WHERE listing_id = ANY(v_listing_ids);
    DELETE FROM public.orders                     WHERE listing_id = ANY(v_listing_ids);
    DELETE FROM public.saved_listings             WHERE listing_id = ANY(v_listing_ids);
    DELETE FROM public.listing_images             WHERE listing_id = ANY(v_listing_ids);
    DELETE FROM public.listing_moderation_notices WHERE listing_id = ANY(v_listing_ids);
    DELETE FROM public.listings                   WHERE id         = ANY(v_listing_ids);
  END IF;

  -- ── User-linked data ─────────────────────────────────────────
  IF v_user_ids IS NOT NULL THEN
    -- NOTE: user_blocks has FK on both user_id AND blocked_user_id
    DELETE FROM public.user_blocks         WHERE user_id         = ANY(v_user_ids)
                                              OR  blocked_user_id = ANY(v_user_ids);
    -- NOTE: content_reports has FK on both reporter_id AND reported_user_id
    DELETE FROM public.content_reports     WHERE reporter_id     = ANY(v_user_ids)
                                              OR  reported_user_id = ANY(v_user_ids);
    DELETE FROM public.user_feedbacks      WHERE user_id         = ANY(v_user_ids);
    DELETE FROM public.contribution_ledger WHERE user_id         = ANY(v_user_ids);
    DELETE FROM public.notifications       WHERE user_id         = ANY(v_user_ids);
    DELETE FROM public.user_bans           WHERE user_id         = ANY(v_user_ids);
    DELETE FROM public.user_active_sessions WHERE user_id        = ANY(v_user_ids);
    DELETE FROM public.user_heartbeats     WHERE user_id         = ANY(v_user_ids);
  END IF;

  INSERT INTO public.admin_audit_logs (admin_id, action, target_type, target_id, payload)
  VALUES (auth.uid(), 'school_data_purge', 'school', p_school_id::text,
    jsonb_build_object('school_id', p_school_id, 'timestamp', now()));

  RETURN jsonb_build_object('status', 'success', 'scope', 'school',
    'school_id', p_school_id, 'purged_at', now());
END;
$$;

GRANT EXECUTE ON FUNCTION public.clear_school_test_data(uuid) TO authenticated;

-- ============================================================
-- Migration 00174: Debug carpool cleanup — add RAISE NOTICE
-- ============================================================
-- The carpool data was not being deleted after 00173. This migration
-- adds detailed RAISE NOTICE statements to clear_school_test_data so
-- we can see exactly which branches are taken and how many rows are
-- affected in each step.
-- ============================================================

DROP FUNCTION IF EXISTS public.clear_school_test_data(uuid);
CREATE FUNCTION public.clear_school_test_data(p_school_id uuid)
RETURNS jsonb LANGUAGE plpgsql SECURITY DEFINER AS $$
DECLARE
  v_listing_ids    uuid[];
  v_user_ids       uuid[];
  v_order_ids      uuid[];
  v_room_ids       uuid[];
  v_trip_ids       uuid[];
  v_group_room_ids uuid[];
  v_affected       int;
BEGIN
  IF NOT public.is_platform_sysadmin() THEN
    RAISE EXCEPTION 'Permission denied: sysadmin only';
  END IF;

  RAISE NOTICE '[cleanup] school_id=%', p_school_id;

  -- Collect IDs
  SELECT array_agg(id) INTO v_listing_ids FROM public.listings      WHERE school_id = p_school_id;
  SELECT array_agg(id) INTO v_user_ids    FROM public.user_profiles WHERE school_id = p_school_id;

  RAISE NOTICE '[cleanup] listing_ids count=%', coalesce(array_length(v_listing_ids, 1), 0);
  RAISE NOTICE '[cleanup] user_ids count=%',    coalesce(array_length(v_user_ids, 1), 0);

  -- ── Order & 1-on-1 chat ──────────────────────────────────────
  IF v_listing_ids IS NOT NULL THEN
    SELECT array_agg(id) INTO v_order_ids FROM public.orders     WHERE listing_id = ANY(v_listing_ids);
    SELECT array_agg(id) INTO v_room_ids  FROM public.chat_rooms WHERE listing_id = ANY(v_listing_ids);

    RAISE NOTICE '[cleanup] order_ids count=%',     coalesce(array_length(v_order_ids, 1), 0);
    RAISE NOTICE '[cleanup] chat_room_ids count=%', coalesce(array_length(v_room_ids, 1), 0);

    IF v_order_ids IS NOT NULL THEN
      DELETE FROM public.rental_extensions WHERE order_id = ANY(v_order_ids);
      GET DIAGNOSTICS v_affected = ROW_COUNT;
      RAISE NOTICE '[cleanup] deleted rental_extensions=%', v_affected;

      DELETE FROM public.order_evidence WHERE order_id = ANY(v_order_ids);
      GET DIAGNOSTICS v_affected = ROW_COUNT;
      RAISE NOTICE '[cleanup] deleted order_evidence=%', v_affected;
    END IF;

    IF v_room_ids IS NOT NULL THEN
      DELETE FROM public.messages      WHERE chat_room_id = ANY(v_room_ids);
      GET DIAGNOSTICS v_affected = ROW_COUNT;
      RAISE NOTICE '[cleanup] deleted messages=%', v_affected;

      DELETE FROM public.notifications WHERE chat_room_id = ANY(v_room_ids);
      DELETE FROM public.content_reports WHERE chat_room_id = ANY(v_room_ids);
    END IF;

    IF v_user_ids IS NOT NULL THEN
      DELETE FROM public.content_reports
        WHERE reporter_id = ANY(v_user_ids) OR reported_user_id = ANY(v_user_ids);
    END IF;
    DELETE FROM public.content_reports WHERE listing_id = ANY(v_listing_ids);

    DELETE FROM public.listing_views              WHERE listing_id = ANY(v_listing_ids);
    DELETE FROM public.moderation_queue           WHERE target_id  = ANY(v_listing_ids);
    DELETE FROM public.chat_rooms                 WHERE listing_id = ANY(v_listing_ids);
    DELETE FROM public.orders                     WHERE listing_id = ANY(v_listing_ids);
    DELETE FROM public.saved_listings             WHERE listing_id = ANY(v_listing_ids);
    DELETE FROM public.listing_images             WHERE listing_id = ANY(v_listing_ids);
    DELETE FROM public.listing_moderation_notices WHERE listing_id = ANY(v_listing_ids);
    DELETE FROM public.listings                   WHERE id         = ANY(v_listing_ids);
  END IF;

  -- ── Carpool & group-chat ──────────────────────────────────────
  -- NOTE: carpool_trips has NO school_id column; trips are scoped by the
  -- creator's user_id. We first collect all trips where any school user
  -- is the creator OR a member, then cascade-delete all child records.
  IF v_user_ids IS NOT NULL THEN
    -- Trips created by school users.
    SELECT array_agg(DISTINCT id) INTO v_trip_ids
    FROM public.carpool_trips
    WHERE creator_id = ANY(v_user_ids);

    RAISE NOTICE '[cleanup] trips created by school users=%',
      coalesce(array_length(v_trip_ids, 1), 0);

    -- Trips where school users are members (union with above).
    SELECT array_agg(DISTINCT ct.id) INTO v_trip_ids
    FROM public.carpool_trips ct
    WHERE ct.creator_id = ANY(v_user_ids)
       OR ct.id IN (
           SELECT trip_id FROM public.carpool_members
           WHERE user_id = ANY(v_user_ids)
         );

    RAISE NOTICE '[cleanup] total trips (creator OR member) count=%',
      coalesce(array_length(v_trip_ids, 1), 0);

    IF v_trip_ids IS NOT NULL THEN
      -- Group chat rooms linked to these trips.
      SELECT array_agg(id) INTO v_group_room_ids
      FROM public.group_chat_rooms WHERE trip_id = ANY(v_trip_ids);

      RAISE NOTICE '[cleanup] group_chat_rooms count=%',
        coalesce(array_length(v_group_room_ids, 1), 0);

      IF v_group_room_ids IS NOT NULL THEN
        DELETE FROM public.group_messages     WHERE room_id = ANY(v_group_room_ids);
        GET DIAGNOSTICS v_affected = ROW_COUNT;
        RAISE NOTICE '[cleanup] deleted group_messages=%', v_affected;

        DELETE FROM public.group_chat_members WHERE room_id = ANY(v_group_room_ids);
        GET DIAGNOSTICS v_affected = ROW_COUNT;
        RAISE NOTICE '[cleanup] deleted group_chat_members (by room)=%', v_affected;

        DELETE FROM public.group_chat_rooms   WHERE id      = ANY(v_group_room_ids);
        GET DIAGNOSTICS v_affected = ROW_COUNT;
        RAISE NOTICE '[cleanup] deleted group_chat_rooms=%', v_affected;
      END IF;

      DELETE FROM public.carpool_reviews WHERE trip_id = ANY(v_trip_ids);
      GET DIAGNOSTICS v_affected = ROW_COUNT;
      RAISE NOTICE '[cleanup] deleted carpool_reviews=%', v_affected;

      DELETE FROM public.carpool_votes WHERE proposal_id IN (
        SELECT id FROM public.carpool_proposals WHERE trip_id = ANY(v_trip_ids)
      );
      GET DIAGNOSTICS v_affected = ROW_COUNT;
      RAISE NOTICE '[cleanup] deleted carpool_votes=%', v_affected;

      DELETE FROM public.carpool_proposals WHERE trip_id = ANY(v_trip_ids);
      GET DIAGNOSTICS v_affected = ROW_COUNT;
      RAISE NOTICE '[cleanup] deleted carpool_proposals=%', v_affected;

      DELETE FROM public.carpool_members WHERE trip_id = ANY(v_trip_ids);
      GET DIAGNOSTICS v_affected = ROW_COUNT;
      RAISE NOTICE '[cleanup] deleted carpool_members=%', v_affected;

      DELETE FROM public.carpool_trips WHERE id = ANY(v_trip_ids);
      GET DIAGNOSTICS v_affected = ROW_COUNT;
      RAISE NOTICE '[cleanup] deleted carpool_trips=%', v_affected;
    END IF;

    -- Clean up memberships / reviews this user has in OTHER schools' trips.
    DELETE FROM public.group_chat_members WHERE user_id    = ANY(v_user_ids);
    GET DIAGNOSTICS v_affected = ROW_COUNT;
    RAISE NOTICE '[cleanup] deleted orphan group_chat_members=%', v_affected;

    DELETE FROM public.carpool_members   WHERE user_id    = ANY(v_user_ids);
    GET DIAGNOSTICS v_affected = ROW_COUNT;
    RAISE NOTICE '[cleanup] deleted orphan carpool_members=%', v_affected;

    DELETE FROM public.carpool_reviews   WHERE reviewer_id = ANY(v_user_ids);
    DELETE FROM public.carpool_votes     WHERE voter_id    = ANY(v_user_ids);
    DELETE FROM public.carpool_proposals WHERE proposer_id = ANY(v_user_ids);
  ELSE
    RAISE NOTICE '[cleanup] v_user_ids IS NULL — skipping carpool cleanup';
  END IF;

  -- ── User-linked data ──────────────────────────────────────────
  IF v_user_ids IS NOT NULL THEN
    DELETE FROM public.user_blocks
      WHERE user_id = ANY(v_user_ids) OR blocked_user_id = ANY(v_user_ids);
    DELETE FROM public.content_reports
      WHERE reporter_id = ANY(v_user_ids) OR reported_user_id = ANY(v_user_ids);
    DELETE FROM public.notifications WHERE user_id = ANY(v_user_ids);
    DELETE FROM public.user_bans     WHERE user_id = ANY(v_user_ids);
    DELETE FROM public.user_active_sessions WHERE user_id = ANY(v_user_ids);
    DELETE FROM public.user_heartbeats      WHERE user_id = ANY(v_user_ids);
  END IF;

  -- ── Pre-launch globals ────────────────────────────────────────
  DELETE FROM public.user_feedbacks      WHERE true;
  DELETE FROM public.contribution_ledger WHERE true;
  DELETE FROM public.admin_audit_logs    WHERE true;

  INSERT INTO public.admin_audit_logs (admin_id, action, target_type, target_id, payload)
  VALUES (auth.uid(), 'school_data_purge', 'school', p_school_id,
    jsonb_build_object(
      'school_id', p_school_id,
      'timestamp', now(),
      'debug', 'v00174'
    ));

  RAISE NOTICE '[cleanup] done';

  RETURN jsonb_build_object(
    'status',    'success',
    'scope',     'school',
    'school_id', p_school_id,
    'purged_at', now()
  );
END;
$$;

GRANT EXECUTE ON FUNCTION public.clear_school_test_data(uuid) TO authenticated;

COMMENT ON FUNCTION public.clear_school_test_data IS
'v00174 — school-scoped test data purge with full RAISE NOTICE debug output.
Includes carpool trips, group chats, and all related child records.';

NOTIFY pgrst, 'reload schema';

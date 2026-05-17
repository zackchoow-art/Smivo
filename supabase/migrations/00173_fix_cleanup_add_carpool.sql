-- ============================================================
-- Migration 00173: Add carpool data to test data cleanup RPCs
-- ============================================================
-- The clear_school_test_data and clear_platform_test_data RPCs
-- were written before the carpool schema (00145+) was introduced.
-- Neither function deletes any of the 9 carpool/group-chat tables,
-- so test runs left all carpool data intact.
--
-- Tables added (FK-safe deletion order, children before parents):
--   group_messages
--   group_chat_members
--   group_chat_rooms
--   carpool_reviews
--   carpool_votes
--   carpool_proposals
--   carpool_members
--   carpool_trips
-- ============================================================

-- ── 1. clear_school_test_data ─────────────────────────────────────────

DROP FUNCTION IF EXISTS public.clear_school_test_data(uuid);
CREATE FUNCTION public.clear_school_test_data(p_school_id uuid)
RETURNS jsonb LANGUAGE plpgsql SECURITY DEFINER AS $$
DECLARE
  v_listing_ids   uuid[];
  v_user_ids      uuid[];
  v_order_ids     uuid[];
  v_room_ids      uuid[];
  v_trip_ids      uuid[];
  v_group_room_ids uuid[];
BEGIN
  IF NOT public.is_platform_sysadmin() THEN
    RAISE EXCEPTION 'Permission denied: sysadmin only';
  END IF;

  SELECT array_agg(id) INTO v_listing_ids FROM public.listings        WHERE school_id = p_school_id;
  SELECT array_agg(id) INTO v_user_ids    FROM public.user_profiles   WHERE school_id = p_school_id;

  -- ── Order & chat-linked data ──────────────────────────────────
  IF v_listing_ids IS NOT NULL THEN
    SELECT array_agg(id) INTO v_order_ids FROM public.orders     WHERE listing_id = ANY(v_listing_ids);
    SELECT array_agg(id) INTO v_room_ids  FROM public.chat_rooms WHERE listing_id = ANY(v_listing_ids);

    IF v_order_ids IS NOT NULL THEN
      DELETE FROM public.rental_extensions WHERE order_id = ANY(v_order_ids);
      DELETE FROM public.order_evidence    WHERE order_id = ANY(v_order_ids);
    END IF;

    IF v_room_ids IS NOT NULL THEN
      DELETE FROM public.messages      WHERE chat_room_id = ANY(v_room_ids);
      DELETE FROM public.notifications WHERE chat_room_id = ANY(v_room_ids);
      DELETE FROM public.content_reports WHERE chat_room_id = ANY(v_room_ids);
    END IF;

    IF v_user_ids IS NOT NULL THEN
      DELETE FROM public.content_reports
        WHERE reporter_id = ANY(v_user_ids) OR reported_user_id = ANY(v_user_ids);
    END IF;
    DELETE FROM public.content_reports WHERE listing_id = ANY(v_listing_ids);

    DELETE FROM public.listing_views             WHERE listing_id = ANY(v_listing_ids);
    DELETE FROM public.moderation_queue          WHERE target_id  = ANY(v_listing_ids);
    DELETE FROM public.chat_rooms                WHERE listing_id = ANY(v_listing_ids);
    DELETE FROM public.orders                    WHERE listing_id = ANY(v_listing_ids);
    DELETE FROM public.saved_listings            WHERE listing_id = ANY(v_listing_ids);
    DELETE FROM public.listing_images            WHERE listing_id = ANY(v_listing_ids);
    DELETE FROM public.listing_moderation_notices WHERE listing_id = ANY(v_listing_ids);
    DELETE FROM public.listings                  WHERE id         = ANY(v_listing_ids);
  END IF;

  -- ── Carpool & group-chat data (scoped to school users) ────────
  -- NOTE: Carpool trips are associated with users (creator_id), not with a
  -- school_id column, so we scope deletion to users belonging to this school.
  IF v_user_ids IS NOT NULL THEN
    SELECT array_agg(id) INTO v_trip_ids FROM public.carpool_trips
    WHERE creator_id = ANY(v_user_ids);

    -- Also include trips where school users are members (non-creator).
    SELECT array_agg(DISTINCT ct.id) INTO v_trip_ids
    FROM public.carpool_trips ct
    WHERE ct.id = ANY(v_trip_ids)
       OR ct.creator_id = ANY(v_user_ids)
       OR ct.id IN (
           SELECT trip_id FROM public.carpool_members
           WHERE user_id = ANY(v_user_ids)
         );

    IF v_trip_ids IS NOT NULL THEN
      SELECT array_agg(id) INTO v_group_room_ids
      FROM public.group_chat_rooms WHERE trip_id = ANY(v_trip_ids);

      IF v_group_room_ids IS NOT NULL THEN
        DELETE FROM public.group_messages    WHERE room_id = ANY(v_group_room_ids);
        DELETE FROM public.group_chat_members WHERE room_id = ANY(v_group_room_ids);
        DELETE FROM public.group_chat_rooms   WHERE id      = ANY(v_group_room_ids);
      END IF;

      DELETE FROM public.carpool_reviews  WHERE trip_id = ANY(v_trip_ids);
      DELETE FROM public.carpool_votes    WHERE proposal_id IN (
        SELECT id FROM public.carpool_proposals WHERE trip_id = ANY(v_trip_ids)
      );
      DELETE FROM public.carpool_proposals WHERE trip_id = ANY(v_trip_ids);
      DELETE FROM public.carpool_members   WHERE trip_id = ANY(v_trip_ids);
      DELETE FROM public.carpool_trips     WHERE id      = ANY(v_trip_ids);
    END IF;

    -- Also clean up group chat memberships the user holds in OTHER school trips.
    DELETE FROM public.group_chat_members WHERE user_id = ANY(v_user_ids);
    DELETE FROM public.carpool_members    WHERE user_id = ANY(v_user_ids);
    DELETE FROM public.carpool_reviews    WHERE reviewer_id = ANY(v_user_ids);
    DELETE FROM public.carpool_votes      WHERE voter_id    = ANY(v_user_ids);
    DELETE FROM public.carpool_proposals  WHERE proposer_id = ANY(v_user_ids);
  END IF;

  -- ── User-linked data ──────────────────────────────────────────
  IF v_user_ids IS NOT NULL THEN
    DELETE FROM public.user_blocks     WHERE user_id = ANY(v_user_ids) OR blocked_user_id = ANY(v_user_ids);
    DELETE FROM public.content_reports WHERE reporter_id = ANY(v_user_ids) OR reported_user_id = ANY(v_user_ids);
    DELETE FROM public.notifications   WHERE user_id = ANY(v_user_ids);
    DELETE FROM public.user_bans       WHERE user_id = ANY(v_user_ids);
    DELETE FROM public.user_active_sessions WHERE user_id = ANY(v_user_ids);
    DELETE FROM public.user_heartbeats WHERE user_id = ANY(v_user_ids);
  END IF;

  -- ── Pre-launch globals ────────────────────────────────────────
  DELETE FROM public.user_feedbacks       WHERE true;
  DELETE FROM public.contribution_ledger  WHERE true;
  DELETE FROM public.admin_audit_logs     WHERE true;

  INSERT INTO public.admin_audit_logs (admin_id, action, target_type, target_id, payload)
  VALUES (auth.uid(), 'school_data_purge', 'school', p_school_id,
    jsonb_build_object('school_id', p_school_id, 'timestamp', now()));

  RETURN jsonb_build_object(
    'status',     'success',
    'scope',      'school',
    'school_id',  p_school_id,
    'purged_at',  now()
  );
END;
$$;

GRANT EXECUTE ON FUNCTION public.clear_school_test_data(uuid) TO authenticated;

COMMENT ON FUNCTION public.clear_school_test_data IS
'Purge all test data belonging to the given school, including carpool trips,
group chats, group messages, and all related child records. Sysadmin only.';


-- ── 2. clear_platform_test_data ───────────────────────────────────────

CREATE OR REPLACE FUNCTION public.clear_platform_test_data()
RETURNS jsonb LANGUAGE plpgsql SECURITY DEFINER AS $$
BEGIN
  IF NOT public.is_platform_sysadmin() THEN
    RAISE EXCEPTION 'Permission denied: sysadmin only';
  END IF;

  INSERT INTO public.admin_audit_logs (admin_id, action, target_type, target_id, payload)
  VALUES (auth.uid(), 'platform_data_purge', 'platform', 'all',
    jsonb_build_object('note', 'Pre-launch platform-wide test data purge', 'timestamp', now()));

  -- Order matters: children must be deleted before parents.

  -- ── Carpool & group-chat (all new tables from migration 00145+) ──
  -- NOTE: These tables did not exist when the original cleanup RPC was
  -- written, so they were never included. Added here to fix the gap.
  DELETE FROM public.group_messages      WHERE true;
  DELETE FROM public.group_chat_members  WHERE true;
  DELETE FROM public.group_chat_rooms    WHERE true;
  DELETE FROM public.carpool_reviews     WHERE true;
  DELETE FROM public.carpool_votes       WHERE true;
  DELETE FROM public.carpool_proposals   WHERE true;
  DELETE FROM public.carpool_members     WHERE true;
  DELETE FROM public.carpool_trips       WHERE true;

  -- ── Order-linked ─────────────────────────────────────────────
  DELETE FROM public.rental_extensions WHERE true;
  DELETE FROM public.order_evidence    WHERE true;

  -- ── 1-on-1 chat ──────────────────────────────────────────────
  DELETE FROM public.messages WHERE true;

  -- ── Listing-linked ───────────────────────────────────────────
  DELETE FROM public.listing_views              WHERE true;
  DELETE FROM public.moderation_queue           WHERE true;
  DELETE FROM public.listing_moderation_notices WHERE true;
  DELETE FROM public.moderation_drafts          WHERE true;
  DELETE FROM public.saved_listings             WHERE true;
  DELETE FROM public.listing_images             WHERE true;
  DELETE FROM public.chat_rooms                 WHERE true;
  DELETE FROM public.orders                     WHERE true;
  DELETE FROM public.listings                   WHERE true;

  -- ── User-linked ───────────────────────────────────────────────
  DELETE FROM public.user_blocks         WHERE true;
  DELETE FROM public.content_reports     WHERE true;
  DELETE FROM public.user_feedbacks      WHERE true;
  DELETE FROM public.contribution_ledger WHERE true;
  DELETE FROM public.notifications       WHERE true;
  DELETE FROM public.user_bans           WHERE true;
  DELETE FROM public.user_active_sessions WHERE true;
  DELETE FROM public.user_heartbeats     WHERE true;
  DELETE FROM public.hourly_active_users WHERE true;

  RETURN jsonb_build_object('status', 'success', 'scope', 'platform', 'purged_at', now());
END;
$$;

GRANT EXECUTE ON FUNCTION public.clear_platform_test_data() TO authenticated;

COMMENT ON FUNCTION public.clear_platform_test_data IS
'Platform-wide test data purge (sysadmin only).
Includes all carpool/group-chat tables added in migration 00145+.
Deletion order respects FK dependencies (children before parents).';

NOTIFY pgrst, 'reload schema';

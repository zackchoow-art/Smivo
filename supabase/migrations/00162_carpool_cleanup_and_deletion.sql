-- ============================================================
-- Migration 00162: Add carpool/group-chat data to cleanup RPCs
--                  and account deletion functions
-- ============================================================
-- Tables missed by existing cleanup & deletion functions:
--   carpool_trips, carpool_members, carpool_proposals,
--   carpool_votes, carpool_reviews,
--   group_chat_rooms, group_chat_members, group_messages
--
-- This migration updates FOUR functions:
--   1. clear_school_test_data()     — school-scoped cleanup
--   2. clear_platform_test_data()   — platform-wide cleanup
--   3. delete_own_account()         — user self-deletion (soft-delete)
--   4. admin_graceful_delete_user() — admin-initiated deletion
-- ============================================================


-- ═══════════════════════════════════════════════════════════════
-- 1. School-scoped cleanup
-- ═══════════════════════════════════════════════════════════════

DROP FUNCTION IF EXISTS public.clear_school_test_data(uuid);
CREATE FUNCTION public.clear_school_test_data(p_school_id uuid)
RETURNS jsonb LANGUAGE plpgsql SECURITY DEFINER AS $$
DECLARE
  v_listing_ids  uuid[];
  v_user_ids     uuid[];
  v_order_ids    uuid[];
  v_room_ids     uuid[];
  v_message_ids  uuid[];
  v_trip_ids     uuid[];
  v_group_room_ids uuid[];
BEGIN
  IF NOT public.is_platform_sysadmin() THEN
    RAISE EXCEPTION 'Permission denied: sysadmin only';
  END IF;

  -- ── Collect entity IDs scoped to this school ──────────────────
  SELECT array_agg(id) INTO v_listing_ids
    FROM public.listings WHERE school_id = p_school_id;

  SELECT array_agg(id) INTO v_user_ids
    FROM public.user_profiles WHERE school_id = p_school_id;

  -- Carpool trips scoped to this school
  SELECT array_agg(id) INTO v_trip_ids
    FROM public.carpool_trips WHERE school_id = p_school_id;

  -- ── Order & chat-linked data ──────────────────────────────────
  IF v_listing_ids IS NOT NULL THEN
    SELECT array_agg(id) INTO v_order_ids
      FROM public.orders WHERE listing_id = ANY(v_listing_ids);
    SELECT array_agg(id) INTO v_room_ids
      FROM public.chat_rooms WHERE listing_id = ANY(v_listing_ids);

    IF v_room_ids IS NOT NULL THEN
      SELECT array_agg(id) INTO v_message_ids
        FROM public.messages WHERE chat_room_id = ANY(v_room_ids);
    END IF;

    -- Order-linked children
    IF v_order_ids IS NOT NULL THEN
      DELETE FROM public.user_review_tag_links
        WHERE review_id IN (
          SELECT id FROM public.user_reviews WHERE order_id = ANY(v_order_ids)
        );
      DELETE FROM public.user_reviews WHERE order_id = ANY(v_order_ids);
      DELETE FROM public.rental_extensions WHERE order_id = ANY(v_order_ids);
      DELETE FROM public.order_evidence WHERE order_id = ANY(v_order_ids);
    END IF;

    -- Chat-linked children
    IF v_room_ids IS NOT NULL THEN
      DELETE FROM public.messages WHERE chat_room_id = ANY(v_room_ids);
      DELETE FROM public.notifications WHERE chat_room_id = ANY(v_room_ids);
      DELETE FROM public.content_reports WHERE chat_room_id = ANY(v_room_ids);
    END IF;

    IF v_user_ids IS NOT NULL THEN
      DELETE FROM public.content_reports
        WHERE reporter_id = ANY(v_user_ids)
           OR reported_user_id = ANY(v_user_ids);
    END IF;
    DELETE FROM public.content_reports WHERE listing_id = ANY(v_listing_ids);

    -- Moderation data
    DELETE FROM public.backend_moderation_logs
      WHERE target_id = ANY(v_listing_ids)
         OR (v_message_ids IS NOT NULL AND target_id = ANY(v_message_ids));
    DELETE FROM public.moderation_tasks
      WHERE (target_type = 'listing'  AND target_id = ANY(v_listing_ids))
         OR (v_message_ids IS NOT NULL AND target_type = 'message' AND target_id = ANY(v_message_ids));
    DELETE FROM public.moderation_queue WHERE target_id = ANY(v_listing_ids);
    DELETE FROM public.moderation_drafts WHERE college_id = p_school_id;

    -- Listing-linked tables
    DELETE FROM public.listing_views WHERE listing_id = ANY(v_listing_ids);
    DELETE FROM public.chat_rooms WHERE listing_id = ANY(v_listing_ids);
    DELETE FROM public.orders WHERE listing_id = ANY(v_listing_ids);
    DELETE FROM public.saved_listings WHERE listing_id = ANY(v_listing_ids);
    DELETE FROM public.listing_images WHERE listing_id = ANY(v_listing_ids);
    DELETE FROM public.listing_moderation_notices WHERE listing_id = ANY(v_listing_ids);
    DELETE FROM public.listings WHERE id = ANY(v_listing_ids);
  END IF;

  -- ── Carpool data (school-scoped via v_trip_ids) ───────────────
  IF v_trip_ids IS NOT NULL THEN
    -- Group chat rooms linked to carpool trips
    SELECT array_agg(id) INTO v_group_room_ids
      FROM public.group_chat_rooms WHERE trip_id = ANY(v_trip_ids);

    IF v_group_room_ids IS NOT NULL THEN
      DELETE FROM public.group_messages WHERE room_id = ANY(v_group_room_ids);
      DELETE FROM public.group_chat_members WHERE room_id = ANY(v_group_room_ids);
      DELETE FROM public.group_chat_rooms WHERE id = ANY(v_group_room_ids);
    END IF;

    -- Carpool children (must precede carpool_trips deletion)
    DELETE FROM public.carpool_reviews WHERE trip_id = ANY(v_trip_ids);
    DELETE FROM public.carpool_votes
      WHERE proposal_id IN (
        SELECT id FROM public.carpool_proposals WHERE trip_id = ANY(v_trip_ids)
      );
    DELETE FROM public.carpool_proposals WHERE trip_id = ANY(v_trip_ids);
    DELETE FROM public.carpool_members WHERE trip_id = ANY(v_trip_ids);
    DELETE FROM public.carpool_trips WHERE id = ANY(v_trip_ids);
  END IF;

  -- ── User-linked data (school-scoped via v_user_ids) ───────────
  IF v_user_ids IS NOT NULL THEN
    DELETE FROM public.user_blocks
      WHERE user_id = ANY(v_user_ids) OR blocked_user_id = ANY(v_user_ids);
    DELETE FROM public.content_reports
      WHERE reporter_id = ANY(v_user_ids) OR reported_user_id = ANY(v_user_ids);
    DELETE FROM public.backend_moderation_logs WHERE user_id = ANY(v_user_ids);
    DELETE FROM public.moderation_tasks
      WHERE target_type = 'profile' AND target_id = ANY(v_user_ids);
    DELETE FROM public.user_feedbacks WHERE user_id = ANY(v_user_ids);
    DELETE FROM public.contribution_ledger WHERE user_id = ANY(v_user_ids);
    DELETE FROM public.notifications WHERE user_id = ANY(v_user_ids);
    DELETE FROM public.user_bans WHERE user_id = ANY(v_user_ids);
    DELETE FROM public.user_active_sessions WHERE user_id = ANY(v_user_ids);
    DELETE FROM public.user_heartbeats WHERE user_id = ANY(v_user_ids);
    DELETE FROM public.hourly_active_users WHERE user_id = ANY(v_user_ids);
    DELETE FROM public.user_saved_locations WHERE user_id = ANY(v_user_ids);
    DELETE FROM public.user_review_tag_links
      WHERE review_id IN (
        SELECT id FROM public.user_reviews
        WHERE reviewer_id = ANY(v_user_ids) OR target_user_id = ANY(v_user_ids)
      );
    DELETE FROM public.user_reviews
      WHERE reviewer_id = ANY(v_user_ids) OR target_user_id = ANY(v_user_ids);

    -- Carpool reviews authored by school users (catch cross-school trips)
    DELETE FROM public.carpool_reviews
      WHERE reviewer_id = ANY(v_user_ids) OR reviewee_id = ANY(v_user_ids);
  END IF;

  -- School-scoped push jobs
  DELETE FROM public.push_jobs WHERE college_id = p_school_id;

  -- Record this cleanup action in the audit log
  INSERT INTO public.admin_audit_logs (admin_id, action, target_type, target_id, payload)
  VALUES (auth.uid(), 'school_data_purge', 'school', p_school_id,
    jsonb_build_object('school_id', p_school_id, 'timestamp', now()));

  RETURN jsonb_build_object(
    'status', 'success', 'scope', 'school',
    'school_id', p_school_id, 'purged_at', now()
  );
END;
$$;
GRANT EXECUTE ON FUNCTION public.clear_school_test_data(uuid) TO authenticated;


-- ═══════════════════════════════════════════════════════════════
-- 2. Platform-wide cleanup
-- ═══════════════════════════════════════════════════════════════

DROP FUNCTION IF EXISTS public.clear_platform_test_data();
CREATE FUNCTION public.clear_platform_test_data()
RETURNS jsonb LANGUAGE plpgsql SECURITY DEFINER AS $$
BEGIN
  IF NOT public.is_platform_sysadmin() THEN
    RAISE EXCEPTION 'Permission denied: sysadmin only';
  END IF;

  INSERT INTO public.admin_audit_logs (admin_id, action, target_type, target_id, payload)
  VALUES (auth.uid(), 'platform_data_purge', 'platform', '00000000-0000-0000-0000-000000000000'::uuid,
    jsonb_build_object('note', 'Pre-launch platform-wide test data purge', 'timestamp', now()));

  -- Order matters: children before parents

  -- Review system (must precede orders)
  DELETE FROM public.user_review_tag_links;
  DELETE FROM public.user_reviews;

  -- Order-linked
  DELETE FROM public.rental_extensions;
  DELETE FROM public.order_evidence;

  -- Chat-linked
  DELETE FROM public.messages;

  -- Content reports before listings/chat_rooms
  DELETE FROM public.content_reports;

  -- Moderation data
  DELETE FROM public.backend_moderation_logs;
  DELETE FROM public.moderation_tasks;
  DELETE FROM public.moderation_queue;
  DELETE FROM public.listing_moderation_notices;
  DELETE FROM public.moderation_drafts;

  -- Listing-linked
  DELETE FROM public.listing_views;
  DELETE FROM public.saved_listings;
  DELETE FROM public.listing_images;

  -- Chat rooms and orders reference listings
  DELETE FROM public.chat_rooms;
  DELETE FROM public.orders;

  -- Now safe to delete listings
  DELETE FROM public.listings;

  -- ── Carpool data (children → parents) ─────────────────────────
  DELETE FROM public.group_messages;
  DELETE FROM public.group_chat_members;
  DELETE FROM public.group_chat_rooms;
  DELETE FROM public.carpool_reviews;
  DELETE FROM public.carpool_votes;
  DELETE FROM public.carpool_proposals;
  DELETE FROM public.carpool_members;
  DELETE FROM public.carpool_trips;

  -- User-linked
  DELETE FROM public.user_blocks;
  DELETE FROM public.user_feedbacks;
  DELETE FROM public.contribution_ledger;
  DELETE FROM public.notifications;
  DELETE FROM public.user_bans;
  DELETE FROM public.user_active_sessions;
  DELETE FROM public.user_heartbeats;
  DELETE FROM public.hourly_active_users;
  DELETE FROM public.user_saved_locations;

  -- Push notification jobs
  DELETE FROM public.push_jobs;

  -- Usage counters
  DELETE FROM public.image_moderation_usage;

  RETURN jsonb_build_object('status', 'success', 'scope', 'platform', 'purged_at', now());
END;
$$;
GRANT EXECUTE ON FUNCTION public.clear_platform_test_data() TO authenticated;


-- ═══════════════════════════════════════════════════════════════
-- 3. User self-deletion (soft-delete) — add carpool handling
-- ═══════════════════════════════════════════════════════════════

CREATE OR REPLACE FUNCTION public.delete_own_account()
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, auth
AS $$
DECLARE
  v_uid  uuid := auth.uid();
  v_room RECORD;
  v_group_room RECORD;
  v_original_email text;
BEGIN
  IF v_uid IS NULL THEN
    RAISE EXCEPTION 'Not authenticated';
  END IF;

  SELECT email INTO v_original_email
  FROM public.user_profiles
  WHERE id = v_uid;

  -- A. Delist all active/reserved listings
  UPDATE public.listings
  SET status = 'inactive', updated_at = now()
  WHERE seller_id = v_uid AND status IN ('active', 'reserved');

  -- B. Cancel all pending/confirmed orders
  UPDATE public.orders
  SET status = 'cancelled', cancelled_by = v_uid, updated_at = now()
  WHERE (buyer_id = v_uid OR seller_id = v_uid)
    AND status IN ('pending', 'confirmed');

  -- C. Cancel active rentals
  UPDATE public.orders
  SET rental_status = NULL, status = 'cancelled',
      cancelled_by = v_uid, updated_at = now()
  WHERE (buyer_id = v_uid OR seller_id = v_uid)
    AND rental_status IN ('active', 'return_requested', 'returned');

  -- D. Send farewell message to every 1-on-1 chat room
  FOR v_room IN
    SELECT id FROM public.chat_rooms
    WHERE buyer_id = v_uid OR seller_id = v_uid
  LOOP
    INSERT INTO public.messages (
      chat_room_id, sender_id, content, message_type, created_at, updated_at
    ) VALUES (
      v_room.id, v_uid,
      '⚠️ This user has deleted their account. Messages can no longer be delivered.',
      'system', now(), now()
    );
    UPDATE public.chat_rooms
    SET last_message_at = now(), updated_at = now()
    WHERE id = v_room.id;
  END LOOP;

  -- D2. Handle carpool: send farewell to group chats, mark as left,
  --     restore available seats for active trips
  FOR v_group_room IN
    SELECT gcr.id AS room_id, cm.trip_id, cm.status AS member_status,
           ct.status AS trip_status
    FROM public.group_chat_members gcm
    JOIN public.group_chat_rooms gcr ON gcr.id = gcm.room_id
    JOIN public.carpool_members cm ON cm.trip_id = gcr.trip_id AND cm.user_id = v_uid
    JOIN public.carpool_trips ct ON ct.id = cm.trip_id
    WHERE gcm.user_id = v_uid
  LOOP
    -- Send farewell message to group chat
    INSERT INTO public.group_messages (
      room_id, sender_id, content, message_type
    ) VALUES (
      v_group_room.room_id, v_uid,
      '⚠️ This user has deleted their account.',
      'system'
    );

    -- Restore seat if member was approved and trip is still joinable
    IF v_group_room.member_status = 'approved'
       AND v_group_room.trip_status IN ('active', 'inactive', 'confirmed') THEN
      UPDATE public.carpool_trips
      SET available_seats = available_seats + 1
      WHERE id = v_group_room.trip_id;
    END IF;
  END LOOP;

  -- Mark all carpool memberships as 'left'
  UPDATE public.carpool_members
  SET status = 'left', cancelled_at = now()
  WHERE user_id = v_uid AND status IN ('pending', 'approved');

  -- Cancel trips created by this user (if still active/inactive/confirmed)
  UPDATE public.carpool_trips
  SET status = 'cancelled', updated_at = now()
  WHERE creator_id = v_uid
    AND status IN ('active', 'inactive', 'confirmed');

  -- Remove from group chats
  DELETE FROM public.group_chat_members WHERE user_id = v_uid;

  -- Clean up carpool votes and proposals by this user
  DELETE FROM public.carpool_votes WHERE voter_id = v_uid;
  DELETE FROM public.carpool_proposals WHERE proposer_id = v_uid;

  -- E. Clean up non-essential data (privacy)
  DELETE FROM public.saved_listings WHERE user_id = v_uid;
  DELETE FROM public.notifications WHERE user_id = v_uid;
  DELETE FROM public.user_feedbacks WHERE user_id = v_uid;
  DELETE FROM public.user_active_sessions WHERE user_id = v_uid;
  DELETE FROM public.user_heartbeats WHERE user_id = v_uid;
  DELETE FROM public.hourly_active_users WHERE user_id = v_uid;
  DELETE FROM public.admin_roles WHERE user_id = v_uid;
  DELETE FROM public.school_admins WHERE user_id = v_uid;
  DELETE FROM public.user_blocks
    WHERE user_id = v_uid OR blocked_user_id = v_uid;
  DELETE FROM public.user_bans WHERE user_id = v_uid;

  -- F. Anonymize user profile (keeps row for FK references)
  UPDATE public.user_profiles
  SET display_name = 'Deleted User',
      avatar_url = NULL,
      email = 'deleted_' || v_uid::text || '@deleted.smivo.io',
      is_verified = false,
      onesignal_player_id = NULL,
      push_notifications_enabled = false,
      push_messages = false,
      push_order_updates = false,
      push_campus_announcements = false,
      push_announcements = false,
      email_notifications_enabled = false,
      email_messages = false,
      email_order_updates = false,
      email_campus_announcements = false,
      email_announcements = false,
      deleted_at = now(),
      updated_at = now()
  WHERE id = v_uid;

  -- G. Disable auth account
  UPDATE auth.users
  SET banned_until = '9999-12-31 23:59:59+00'::timestamptz,
      email = 'deleted_' || v_uid::text || '@deleted.smivo.io',
      encrypted_password = '',
      raw_user_meta_data = jsonb_build_object(
        'deleted', true,
        'deleted_at', now()::text,
        'original_email', v_original_email
      ),
      updated_at = now()
  WHERE id = v_uid;

  -- H. Force logout all devices
  DELETE FROM auth.refresh_tokens WHERE session_id IN (
    SELECT id FROM auth.sessions WHERE user_id = v_uid
  );
  DELETE FROM auth.sessions WHERE user_id = v_uid;

  -- I. Delete auth identity (frees email for re-registration)
  DELETE FROM auth.identities WHERE user_id = v_uid;

END;
$$;

GRANT EXECUTE ON FUNCTION public.delete_own_account() TO authenticated;

COMMENT ON FUNCTION public.delete_own_account IS
'Graceful account deletion: (A) delist listings, (B-C) cancel orders,
(D) farewell messages to 1-on-1 chats, (D2) farewell to group chats +
leave carpool trips + cancel owned trips, (E) cleanup privacy data,
(F) anonymize profile, (G) ban auth, (H) force logout, (I) delete identity.
Completed orders, chat history, and carpool trip records preserved.';


-- ═══════════════════════════════════════════════════════════════
-- 4. Admin graceful delete user — add carpool handling
-- ═══════════════════════════════════════════════════════════════

CREATE OR REPLACE FUNCTION public.admin_graceful_delete_user(p_user_id uuid)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, auth
AS $$
DECLARE
  v_caller_id uuid := auth.uid();
  v_room RECORD;
  v_group_room RECORD;
  v_original_email text;
  v_display_name text;
BEGIN
  IF NOT is_admin_user() THEN
    RAISE EXCEPTION 'Unauthorized: admin role required';
  END IF;

  SELECT email, display_name
  INTO v_original_email, v_display_name
  FROM public.user_profiles
  WHERE id = p_user_id;

  IF v_original_email IS NULL THEN
    RAISE EXCEPTION 'User not found: %', p_user_id;
  END IF;

  IF v_original_email LIKE 'deleted_%@deleted.smivo.io' THEN
    RETURN jsonb_build_object('success', false, 'error', 'User is already deleted');
  END IF;

  -- A. Delist listings
  UPDATE public.listings
  SET status = 'inactive', updated_at = now()
  WHERE seller_id = p_user_id AND status IN ('active', 'reserved');

  -- B. Cancel pending/confirmed orders
  UPDATE public.orders
  SET status = 'cancelled', cancelled_by = p_user_id, updated_at = now()
  WHERE (buyer_id = p_user_id OR seller_id = p_user_id)
    AND status IN ('pending', 'confirmed');

  -- C. Cancel active rentals
  UPDATE public.orders
  SET rental_status = NULL, status = 'cancelled',
      cancelled_by = p_user_id, updated_at = now()
  WHERE (buyer_id = p_user_id OR seller_id = p_user_id)
    AND rental_status IN ('active', 'return_requested', 'returned');

  -- D. Farewell to 1-on-1 chat rooms
  FOR v_room IN
    SELECT id FROM public.chat_rooms
    WHERE buyer_id = p_user_id OR seller_id = p_user_id
  LOOP
    INSERT INTO public.messages (
      chat_room_id, sender_id, content, message_type, created_at, updated_at
    ) VALUES (
      v_room.id, p_user_id,
      '⚠️ This account has been removed by the platform. Messages can no longer be delivered.',
      'system', now(), now()
    );
    UPDATE public.chat_rooms
    SET last_message_at = now(), updated_at = now()
    WHERE id = v_room.id;
  END LOOP;

  -- D2. Handle carpool: farewell to group chats, leave trips, cancel owned trips
  FOR v_group_room IN
    SELECT gcr.id AS room_id, cm.trip_id, cm.status AS member_status,
           ct.status AS trip_status
    FROM public.group_chat_members gcm
    JOIN public.group_chat_rooms gcr ON gcr.id = gcm.room_id
    JOIN public.carpool_members cm ON cm.trip_id = gcr.trip_id AND cm.user_id = p_user_id
    JOIN public.carpool_trips ct ON ct.id = cm.trip_id
    WHERE gcm.user_id = p_user_id
  LOOP
    INSERT INTO public.group_messages (
      room_id, sender_id, content, message_type
    ) VALUES (
      v_group_room.room_id, p_user_id,
      '⚠️ This account has been removed by the platform.',
      'system'
    );

    IF v_group_room.member_status = 'approved'
       AND v_group_room.trip_status IN ('active', 'inactive', 'confirmed') THEN
      UPDATE public.carpool_trips
      SET available_seats = available_seats + 1
      WHERE id = v_group_room.trip_id;
    END IF;
  END LOOP;

  UPDATE public.carpool_members
  SET status = 'left', cancelled_at = now()
  WHERE user_id = p_user_id AND status IN ('pending', 'approved');

  UPDATE public.carpool_trips
  SET status = 'cancelled', updated_at = now()
  WHERE creator_id = p_user_id
    AND status IN ('active', 'inactive', 'confirmed');

  DELETE FROM public.group_chat_members WHERE user_id = p_user_id;
  DELETE FROM public.carpool_votes WHERE voter_id = p_user_id;
  DELETE FROM public.carpool_proposals WHERE proposer_id = p_user_id;

  -- E. Clean up non-essential data
  DELETE FROM public.saved_listings WHERE user_id = p_user_id;
  DELETE FROM public.notifications WHERE user_id = p_user_id;
  DELETE FROM public.user_feedbacks WHERE user_id = p_user_id;
  DELETE FROM public.user_active_sessions WHERE user_id = p_user_id;
  DELETE FROM public.user_heartbeats WHERE user_id = p_user_id;
  DELETE FROM public.hourly_active_users WHERE user_id = p_user_id;
  DELETE FROM public.admin_roles WHERE user_id = p_user_id;
  DELETE FROM public.school_admins WHERE user_id = p_user_id;
  DELETE FROM public.user_blocks
    WHERE user_id = p_user_id OR blocked_user_id = p_user_id;
  DELETE FROM public.user_bans WHERE user_id = p_user_id;

  -- F. Anonymize user profile
  UPDATE public.user_profiles
  SET display_name = 'Deleted User',
      avatar_url = NULL,
      email = 'deleted_' || p_user_id::text || '@deleted.smivo.io',
      is_verified = false,
      onesignal_player_id = NULL,
      push_notifications_enabled = false,
      push_messages = false,
      push_order_updates = false,
      push_campus_announcements = false,
      push_announcements = false,
      email_notifications_enabled = false,
      email_messages = false,
      email_order_updates = false,
      email_campus_announcements = false,
      email_announcements = false,
      deleted_at = now(),
      updated_at = now()
  WHERE id = p_user_id;

  -- G. Disable auth account
  UPDATE auth.users
  SET banned_until = '9999-12-31 23:59:59+00'::timestamptz,
      email = 'deleted_' || p_user_id::text || '@deleted.smivo.io',
      encrypted_password = '',
      raw_user_meta_data = jsonb_build_object(
        'deleted', true,
        'deleted_at', now()::text,
        'deleted_by_admin', v_caller_id::text,
        'original_email', v_original_email
      ),
      updated_at = now()
  WHERE id = p_user_id;

  -- H. Force logout
  DELETE FROM auth.refresh_tokens WHERE session_id IN (
    SELECT id FROM auth.sessions WHERE user_id = p_user_id
  );
  DELETE FROM auth.sessions WHERE user_id = p_user_id;

  -- I. Delete auth identity
  DELETE FROM auth.identities WHERE user_id = p_user_id;

  -- J. Audit log
  IF EXISTS (SELECT 1 FROM pg_tables WHERE schemaname = 'public' AND tablename = 'admin_audit_logs') THEN
    INSERT INTO public.admin_audit_logs (
      admin_id, action, target_type, target_id, payload
    ) VALUES (
      v_caller_id, 'admin_graceful_delete_user', 'user', p_user_id,
      jsonb_build_object(
        'deleted_by', v_caller_id,
        'deleted_at', now(),
        'original_email', v_original_email,
        'original_name', v_display_name,
        'method', 'graceful_soft_delete'
      )
    );
  END IF;

  RETURN jsonb_build_object(
    'success', true,
    'deleted_user_id', p_user_id,
    'original_email', v_original_email,
    'method', 'graceful_soft_delete'
  );

EXCEPTION WHEN OTHERS THEN
  RAISE EXCEPTION 'Failed to delete user %: %', p_user_id, SQLERRM;
END;
$$;

GRANT EXECUTE ON FUNCTION public.admin_graceful_delete_user(uuid) TO authenticated;

COMMENT ON FUNCTION public.admin_graceful_delete_user IS
'Admin graceful account deletion with carpool support.
Steps: (A) delist listings, (B-C) cancel orders, (D) farewell to 1-on-1 chats,
(D2) farewell to group chats + leave carpool trips + cancel owned trips,
(E) cleanup privacy data, (F) anonymize profile, (G) ban auth,
(H) force logout, (I) delete identity, (J) audit log.';


-- ═══════════════════════════════════════════════════════════════
-- Notify PostgREST to pick up schema changes
-- ═══════════════════════════════════════════════════════════════
NOTIFY pgrst, 'reload schema';

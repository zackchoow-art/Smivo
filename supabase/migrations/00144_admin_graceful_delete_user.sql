-- Migration 00144: Admin graceful delete user
-- ═══════════════════════════════════════════════════════════════
-- Problem: admin_delete_user() hard-deletes user_profiles + auth.users,
-- destroying FK references and marketplace history.
--
-- Fix: Create admin_graceful_delete_user() that performs the SAME
-- soft-delete + anonymization as delete_own_account() (migration 00142),
-- but accepts a target user_id parameter and requires admin auth.
-- Also writes an audit log entry recording which admin performed
-- the deletion.
--
-- The old admin_delete_user() is preserved as a fallback but should
-- no longer be called from the admin dashboard.
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
  v_original_email text;
  v_display_name text;
BEGIN
  -- ── Auth check: only admins can call this ──────────────────────
  IF NOT is_admin_user() THEN
    RAISE EXCEPTION 'Unauthorized: admin role required';
  END IF;

  -- Verify target user exists and is not already deleted
  SELECT email, display_name
  INTO v_original_email, v_display_name
  FROM public.user_profiles
  WHERE id = p_user_id;

  IF v_original_email IS NULL THEN
    RAISE EXCEPTION 'User not found: %', p_user_id;
  END IF;

  -- Already deleted?
  IF v_original_email LIKE 'deleted_%@deleted.smivo.io' THEN
    RETURN jsonb_build_object(
      'success', false,
      'error', 'User is already deleted'
    );
  END IF;

  -- ══════════════════════════════════════════════════════════════
  -- A. DELIST all active/reserved listings
  -- ══════════════════════════════════════════════════════════════
  UPDATE public.listings
  SET status = 'inactive', updated_at = now()
  WHERE seller_id = p_user_id AND status IN ('active', 'reserved');

  -- ══════════════════════════════════════════════════════════════
  -- B. CANCEL all pending/confirmed orders (sale + rental)
  -- ══════════════════════════════════════════════════════════════
  UPDATE public.orders
  SET status = 'cancelled', cancelled_by = p_user_id, updated_at = now()
  WHERE (buyer_id = p_user_id OR seller_id = p_user_id)
    AND status IN ('pending', 'confirmed');

  -- ══════════════════════════════════════════════════════════════
  -- C. CANCEL active rentals
  -- ══════════════════════════════════════════════════════════════
  UPDATE public.orders
  SET rental_status = NULL, status = 'cancelled',
      cancelled_by = p_user_id, updated_at = now()
  WHERE (buyer_id = p_user_id OR seller_id = p_user_id)
    AND rental_status IN ('active', 'return_requested', 'returned');

  -- ══════════════════════════════════════════════════════════════
  -- D. SEND farewell message to every chat room
  --    NOTE: Uses admin-specific message text to distinguish
  --    from user-initiated deletion.
  -- ══════════════════════════════════════════════════════════════
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

  -- ══════════════════════════════════════════════════════════════
  -- E. CLEAN UP non-essential data (privacy)
  -- ══════════════════════════════════════════════════════════════
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

  -- ══════════════════════════════════════════════════════════════
  -- F. ANONYMIZE user profile (keeps row for FK references)
  -- ══════════════════════════════════════════════════════════════
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

  -- ══════════════════════════════════════════════════════════════
  -- G. DISABLE auth account (ban + scramble credentials)
  -- ══════════════════════════════════════════════════════════════
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

  -- ══════════════════════════════════════════════════════════════
  -- H. FORCE LOGOUT all devices
  -- ══════════════════════════════════════════════════════════════
  DELETE FROM auth.refresh_tokens WHERE session_id IN (
    SELECT id FROM auth.sessions WHERE user_id = p_user_id
  );
  DELETE FROM auth.sessions WHERE user_id = p_user_id;

  -- ══════════════════════════════════════════════════════════════
  -- I. DELETE auth identity (frees email for re-registration)
  -- ══════════════════════════════════════════════════════════════
  DELETE FROM auth.identities WHERE user_id = p_user_id;

  -- ══════════════════════════════════════════════════════════════
  -- J. AUDIT LOG (record which admin performed this action)
  -- ══════════════════════════════════════════════════════════════
  IF EXISTS (SELECT 1 FROM pg_tables WHERE schemaname = 'public' AND tablename = 'admin_audit_logs') THEN
    INSERT INTO public.admin_audit_logs (
      admin_id, action, target_type, target_id, payload
    ) VALUES (
      v_caller_id,
      'admin_graceful_delete_user',
      'user',
      p_user_id,
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
'Admin version of graceful account deletion (soft-delete + anonymization).
Same logic as delete_own_account() but accepts a target user_id and requires
admin auth. Steps: (A) delist listings, (B-C) cancel orders, (D) farewell
messages, (E) cleanup privacy data, (F) anonymize profile, (G) ban auth,
(H) force logout, (I) delete identity, (J) audit log.
Completed orders and chat history preserved for counterparties.';

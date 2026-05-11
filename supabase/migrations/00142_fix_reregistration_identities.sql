-- Migration 00142: Fix re-registration by cleaning auth.identities
-- ═══════════════════════════════════════════════════════════════
-- Problem: delete_own_account() scrambles auth.users.email but
-- leaves auth.identities intact. Supabase Auth matches signup
-- emails against auth.identities FIRST, so the old email identity
-- blocks re-registration (triggers user_repeated_signup instead
-- of creating a new user).
--
-- Fix: Add step I to delete auth.identities for the user.
-- Also retroactively fix existing deleted users.
-- ═══════════════════════════════════════════════════════════════

-- ── Retroactive fix: clean identities for already-deleted users ──
DELETE FROM auth.identities
WHERE user_id IN (
  SELECT id FROM auth.users
  WHERE email LIKE 'deleted_%@deleted.smivo.io'
);

-- ── Redefine RPC with new step I ────────────────────────────────

CREATE OR REPLACE FUNCTION public.delete_own_account()
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, auth
AS $$
DECLARE
  v_uid  uuid := auth.uid();
  v_room RECORD;
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

  -- D. Send farewell message to every chat room
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

  -- E. Clean up non-essential data (privacy)
  DELETE FROM public.saved_listings WHERE user_id = v_uid;
  DELETE FROM public.notifications WHERE user_id = v_uid;
  DELETE FROM public.user_feedbacks WHERE user_id = v_uid;
  DELETE FROM public.user_active_sessions WHERE user_id = v_uid;
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

  -- G. Disable auth account (ban + scramble credentials)
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

  -- H. Force logout all devices (destroy sessions + refresh tokens)
  DELETE FROM auth.refresh_tokens WHERE session_id IN (
    SELECT id FROM auth.sessions WHERE user_id = v_uid
  );
  DELETE FROM auth.sessions WHERE user_id = v_uid;

  -- I. Delete auth identity (frees original email for re-registration)
  --    Supabase Auth matches signup emails against auth.identities.
  --    Without this, re-registration triggers user_repeated_signup
  --    instead of creating a new account.
  DELETE FROM auth.identities WHERE user_id = v_uid;

END;
$$;

GRANT EXECUTE ON FUNCTION public.delete_own_account() TO authenticated;

COMMENT ON FUNCTION public.delete_own_account IS
'Graceful account deletion: (A) delist listings, (B-C) cancel orders,
(D) farewell messages, (E) cleanup privacy data, (F) anonymize profile,
(G) ban auth, (H) force logout, (I) delete identity for re-registration.
Completed orders and chat history preserved for counterparties.';

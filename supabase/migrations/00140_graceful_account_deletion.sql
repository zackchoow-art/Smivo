-- Migration 00140: Graceful account deletion with data preservation
-- ═══════════════════════════════════════════════════════════════════════
-- Problem: delete_own_account() hard-deletes everything, destroying
-- completed order history and active transactions without warning.
--
-- New behavior:
-- 1. Delist all active listings (status → 'inactive')
-- 2. Cancel all pending/confirmed orders (set cancelled_by)
-- 3. Cancel all active rental orders
-- 4. Send farewell message to every chat room
-- 5. Anonymize user profile (PII removal)
-- 6. Disable auth account (ban + scramble email)
-- 7. Completed/historical orders are preserved for the counterparty
--
-- Strategy: Soft-delete. Instead of DELETE FROM user_profiles/auth.users
-- (which would CASCADE-destroy orders, chat_rooms, messages), we:
-- - Keep user_profiles row but anonymize it
-- - Keep auth.users row but ban it and scramble email
-- - This preserves all FK references naturally
-- ═══════════════════════════════════════════════════════════════════════

-- ── Step 1: Add deleted_at column to user_profiles ──────────────────
-- This flag lets the app distinguish between active and deleted users.
ALTER TABLE public.user_profiles
  ADD COLUMN IF NOT EXISTS deleted_at timestamptz;

-- Index for efficient "is this user deleted?" checks
CREATE INDEX IF NOT EXISTS idx_user_profiles_deleted
  ON public.user_profiles (deleted_at)
  WHERE deleted_at IS NOT NULL;


-- ── Step 2: Rewrite delete_own_account() as graceful soft-delete ────

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
  -- Safety check
  IF v_uid IS NULL THEN
    RAISE EXCEPTION 'Not authenticated';
  END IF;

  -- Grab original email for audit
  SELECT email INTO v_original_email
  FROM public.user_profiles
  WHERE id = v_uid;

  -- ══════════════════════════════════════════════════════════════
  -- A. DELIST all active/reserved listings
  -- ══════════════════════════════════════════════════════════════
  UPDATE public.listings
  SET status = 'inactive',
      updated_at = now()
  WHERE seller_id = v_uid
    AND status IN ('active', 'reserved');

  -- ══════════════════════════════════════════════════════════════
  -- B. CANCEL all pending/confirmed orders (sale + rental)
  --    Both as buyer and as seller
  -- ══════════════════════════════════════════════════════════════
  UPDATE public.orders
  SET status = 'cancelled',
      cancelled_by = v_uid,
      updated_at = now()
  WHERE (buyer_id = v_uid OR seller_id = v_uid)
    AND status IN ('pending', 'confirmed');

  -- ══════════════════════════════════════════════════════════════
  -- C. CANCEL active rentals (rental_status in active states)
  --    These are confirmed orders with an active rental period
  -- ══════════════════════════════════════════════════════════════
  UPDATE public.orders
  SET rental_status = NULL,
      status = 'cancelled',
      cancelled_by = v_uid,
      updated_at = now()
  WHERE (buyer_id = v_uid OR seller_id = v_uid)
    AND rental_status IN ('active', 'return_requested', 'returned');

  -- ══════════════════════════════════════════════════════════════
  -- D. SEND farewell message to every chat room
  --    Uses the deleting user's own ID as sender (profile still
  --    exists at this point). message_type = 'system' so the
  --    app can style it differently.
  -- ══════════════════════════════════════════════════════════════
  FOR v_room IN
    SELECT id FROM public.chat_rooms
    WHERE buyer_id = v_uid OR seller_id = v_uid
  LOOP
    INSERT INTO public.messages (
      chat_room_id, sender_id, content, message_type, created_at, updated_at
    ) VALUES (
      v_room.id,
      v_uid,
      '⚠️ This user has deleted their account. Messages can no longer be delivered.',
      'system',
      now(),
      now()
    );

    -- Update chat room's last_message_at so it appears at top
    UPDATE public.chat_rooms
    SET last_message_at = now(),
        updated_at = now()
    WHERE id = v_room.id;
  END LOOP;

  -- ══════════════════════════════════════════════════════════════
  -- E. CLEAN UP non-essential data (privacy)
  -- ══════════════════════════════════════════════════════════════

  -- Saved listings (user's own saves — privacy)
  DELETE FROM public.saved_listings WHERE user_id = v_uid;

  -- Notifications (user's own — no longer needed)
  DELETE FROM public.notifications WHERE user_id = v_uid;

  -- User feedbacks
  DELETE FROM public.user_feedbacks WHERE user_id = v_uid;

  -- Active sessions / heartbeat
  DELETE FROM public.user_active_sessions WHERE user_id = v_uid;
  DELETE FROM public.hourly_active_users WHERE user_id = v_uid;

  -- Admin roles (if user was admin)
  DELETE FROM public.admin_roles WHERE user_id = v_uid;
  DELETE FROM public.school_admins WHERE user_id = v_uid;

  -- User blocks (both directions)
  DELETE FROM public.user_blocks
  WHERE user_id = v_uid OR blocked_user_id = v_uid;

  -- User bans (cleanup)
  DELETE FROM public.user_bans WHERE user_id = v_uid;

  -- ══════════════════════════════════════════════════════════════
  -- F. ANONYMIZE user profile (PII removal, keeps the row alive
  --    so all FK references continue to resolve)
  -- ══════════════════════════════════════════════════════════════
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

  -- ══════════════════════════════════════════════════════════════
  -- G. DISABLE auth account (ban + scramble credentials)
  --    This prevents login while keeping the auth.users row
  --    alive (user_profiles.id → auth.users.id FK constraint).
  --    The original email is freed up for potential re-registration.
  -- ══════════════════════════════════════════════════════════════
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

END;
$$;

-- Ensure grant is still in place
GRANT EXECUTE ON FUNCTION public.delete_own_account() TO authenticated;

COMMENT ON FUNCTION public.delete_own_account IS
'Graceful account deletion via soft-delete + anonymization.
Cancels active transactions, delists listings, sends farewell
messages to all chat rooms, anonymizes PII, and disables auth.
Completed orders and chat history are preserved for counterparties.';

-- ============================================================
-- check_chat_eligibility RPC
--
-- Called by the Flutter app before sending a chat message.
-- Returns a JSON object indicating:
--   is_blocked_by_recipient: sender is in the recipient's block list
--   recipient_is_muted:      recipient has an active 'chat_mute' ban
--   recipient_is_frozen:     recipient has an active 'account_freeze' ban
--
-- SECURITY DEFINER is required so that:
--   (a) the sender can look up the recipient's block list (normally RLS-hidden)
--   (b) the sender can look up the recipient's ban status
-- ============================================================

CREATE OR REPLACE FUNCTION public.check_chat_eligibility(
  p_sender_id    uuid,
  p_recipient_id uuid
)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = ''
AS $$
DECLARE
  v_is_blocked boolean;
  v_is_muted   boolean;
  v_is_frozen  boolean;
BEGIN
  -- 1. Check if the RECIPIENT has blocked the SENDER.
  --    Requires SECURITY DEFINER because user_blocks RLS only allows each
  --    user to read their own block list.
  SELECT EXISTS (
    SELECT 1
    FROM public.user_blocks
    WHERE user_id        = p_recipient_id
      AND blocked_user_id = p_sender_id
  ) INTO v_is_blocked;

  -- 2. Check if the recipient is chat-muted by the platform.
  SELECT public.is_user_restricted(p_recipient_id, 'chat_mute')
    INTO v_is_muted;

  -- 3. Check if the recipient's account is frozen (login banned).
  SELECT public.is_user_restricted(p_recipient_id, 'account_freeze')
    INTO v_is_frozen;

  RETURN jsonb_build_object(
    'is_blocked_by_recipient', v_is_blocked,
    'recipient_is_muted',      v_is_muted,
    'recipient_is_frozen',     v_is_frozen
  );
END;
$$;

-- Grant execute to authenticated users only (no anon access).
REVOKE ALL ON FUNCTION public.check_chat_eligibility(uuid, uuid) FROM PUBLIC;
GRANT  EXECUTE ON FUNCTION public.check_chat_eligibility(uuid, uuid) TO authenticated;

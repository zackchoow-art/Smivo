-- Migration 00073: Enforce chat mute on sender

-- 1. Update messages insert policy to block muted users
DROP POLICY IF EXISTS "Chat participants can send messages" ON public.messages;

CREATE POLICY "Chat participants can send messages"
  ON public.messages FOR INSERT
  WITH CHECK (
    auth.uid() = sender_id
    AND auth.uid() IN (
      SELECT buyer_id FROM public.chat_rooms WHERE id = chat_room_id
      UNION
      SELECT seller_id FROM public.chat_rooms WHERE id = chat_room_id
    )
    AND NOT public.is_user_restricted(auth.uid(), 'chat_mute')
  );

-- 2. Update check_chat_eligibility to return sender_is_muted
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
  v_is_blocked   boolean;
  v_is_muted     boolean;
  v_is_frozen    boolean;
  v_sender_muted boolean;
BEGIN
  -- 1. Check if SENDER is muted
  SELECT public.is_user_restricted(p_sender_id, 'chat_mute')
    INTO v_sender_muted;

  -- 2. Check if the RECIPIENT has blocked the SENDER.
  SELECT EXISTS (
    SELECT 1
    FROM public.user_blocks
    WHERE user_id        = p_recipient_id
      AND blocked_user_id = p_sender_id
  ) INTO v_is_blocked;

  -- 3. Check if the recipient is chat-muted by the platform.
  SELECT public.is_user_restricted(p_recipient_id, 'chat_mute')
    INTO v_is_muted;

  -- 4. Check if the recipient's account is frozen (login banned).
  SELECT public.is_user_restricted(p_recipient_id, 'account_freeze')
    INTO v_is_frozen;

  RETURN jsonb_build_object(
    'is_blocked_by_recipient', v_is_blocked,
    'recipient_is_muted',      v_is_muted,
    'recipient_is_frozen',     v_is_frozen,
    'sender_is_muted',         v_sender_muted
  );
END;
$$;

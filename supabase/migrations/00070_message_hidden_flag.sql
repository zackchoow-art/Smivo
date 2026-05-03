-- Migration 00070: Add is_hidden flag to messages table
-- Allows admins to hide reported/violating messages without deleting them.
-- Hidden messages are filtered from the client but preserved for audit.

-- 1. Add is_hidden column with safe default
ALTER TABLE public.messages
  ADD COLUMN IF NOT EXISTS is_hidden boolean NOT NULL DEFAULT false;

-- 2. Add hidden_reason for audit trail
ALTER TABLE public.messages
  ADD COLUMN IF NOT EXISTS hidden_reason text DEFAULT NULL;

-- 3. Index for efficient filtering in chat queries
CREATE INDEX IF NOT EXISTS idx_messages_hidden
  ON public.messages(chat_room_id, is_hidden)
  WHERE is_hidden = false;

-- 4. RPC for admins to hide specific messages by ID array
-- SECURITY DEFINER bypasses RLS so admin can always hide content.
CREATE OR REPLACE FUNCTION public.admin_hide_messages(
  message_ids uuid[],
  reason_text text DEFAULT 'Reported content removed by moderation'
)
RETURNS integer
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  affected_count integer;
BEGIN
  UPDATE public.messages
  SET
    is_hidden = true,
    hidden_reason = reason_text,
    updated_at = now()
  WHERE id = ANY(message_ids)
    AND is_hidden = false;

  GET DIAGNOSTICS affected_count = ROW_COUNT;
  RETURN affected_count;
END;
$$;

GRANT EXECUTE ON FUNCTION public.admin_hide_messages TO authenticated;

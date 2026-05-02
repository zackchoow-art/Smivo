-- ============================================================
-- user_active_sessions: tracks which chat room a user is
-- currently viewing, so the push-notification Edge Function
-- can skip sending a push when the recipient is already in
-- the conversation.
-- ============================================================

CREATE TABLE IF NOT EXISTS public.user_active_sessions (
  user_id        uuid PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  chat_room_id   uuid REFERENCES public.chat_rooms(id) ON DELETE SET NULL,
  updated_at     timestamptz NOT NULL DEFAULT now()
);

-- Only the authenticated user may read/write their own row.
ALTER TABLE public.user_active_sessions ENABLE ROW LEVEL SECURITY;

CREATE POLICY "users can manage their own session"
  ON public.user_active_sessions
  FOR ALL
  USING  (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

-- Index to let the Edge Function quickly look up by user_id
-- (primary key already covers this, but explicit for clarity).
COMMENT ON TABLE public.user_active_sessions IS
  'One row per logged-in user. chat_room_id is non-null only while the user has that chat room open.';

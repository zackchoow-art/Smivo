-- Add pin, archive, and manual unread override columns to chat_rooms.
-- These are per-room flags (not per-user), suitable for 1-on-1 chats.
ALTER TABLE public.chat_rooms
  ADD COLUMN IF NOT EXISTS is_pinned BOOLEAN NOT NULL DEFAULT false,
  ADD COLUMN IF NOT EXISTS is_archived BOOLEAN NOT NULL DEFAULT false,
  ADD COLUMN IF NOT EXISTS is_unread_override BOOLEAN NOT NULL DEFAULT false;

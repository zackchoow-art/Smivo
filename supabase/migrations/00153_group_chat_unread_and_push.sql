-- ============================================================
-- Group Chat: Unread Tracking + Push Notifications
-- ============================================================
-- 1. Add last_read_at to group_chat_members for per-user unread counts
-- 2. Add group_chat_room_id to user_active_sessions for in-room suppression
-- 3. Create trigger to generate notifications for group messages

-- ── 1. Unread tracking column ────────────────────────────────────────────────
ALTER TABLE public.group_chat_members
  ADD COLUMN IF NOT EXISTS last_read_at timestamptz DEFAULT now();

COMMENT ON COLUMN public.group_chat_members.last_read_at
  IS 'Timestamp of the last time this member opened the group chat. Messages after this time are considered unread.';

-- ── 2. Active session extension ──────────────────────────────────────────────
-- Add a separate column for group chat rooms so the push-notification
-- Edge Function can suppress pushes when the user is in a group chat.
ALTER TABLE public.user_active_sessions
  ADD COLUMN IF NOT EXISTS group_chat_room_id uuid;

COMMENT ON COLUMN public.user_active_sessions.group_chat_room_id
  IS 'The group chat room the user is currently viewing. Used for push suppression.';

-- ── 3. Trigger: group_messages INSERT → notifications for other members ──────
CREATE OR REPLACE FUNCTION public.notify_group_message()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = ''
AS $$
DECLARE
  v_room_name text;
  v_sender_name text;
  v_member RECORD;
BEGIN
  -- Get room name for the notification title
  SELECT name INTO v_room_name
  FROM public.group_chat_rooms
  WHERE id = NEW.room_id;

  -- Get sender display name
  SELECT coalesce(display_name, 'Someone') INTO v_sender_name
  FROM public.user_profiles
  WHERE id = NEW.sender_id;

  -- Insert a notification for every OTHER active member in the room
  FOR v_member IN
    SELECT user_id
    FROM public.group_chat_members
    WHERE room_id = NEW.room_id
      AND user_id != NEW.sender_id
  LOOP
    INSERT INTO public.notifications
      (user_id, type, title, body, action_type, action_url, chat_room_id)
    VALUES (
      v_member.user_id,
      'group_message',
      coalesce(v_room_name, 'Group Chat'),
      CASE
        WHEN NEW.message_type = 'image' THEN v_sender_name || ' sent a photo'
        ELSE v_sender_name || ': ' || coalesce(left(NEW.content, 100), 'New message')
      END,
      'route',
      '/group-chat/' || NEW.room_id::text,
      -- NOTE: Reuse the chat_room_id column for group rooms too.
      -- The push-notification Edge Function checks this for suppression.
      NULL
    );
  END LOOP;

  RETURN NEW;
END;
$$;

-- Attach trigger to group_messages table
DROP TRIGGER IF EXISTS trg_notify_group_message ON public.group_messages;
CREATE TRIGGER trg_notify_group_message
  AFTER INSERT ON public.group_messages
  FOR EACH ROW EXECUTE FUNCTION public.notify_group_message();

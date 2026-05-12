-- ============================================================
-- Fix: Add 'group_message' to notifications type CHECK constraint
-- and update trigger to include email_queued column
-- ============================================================

-- 1. Expand the CHECK constraint to include group_message
ALTER TABLE public.notifications
  DROP CONSTRAINT IF EXISTS notifications_type_check;
ALTER TABLE public.notifications
  ADD CONSTRAINT notifications_type_check CHECK (
    type = ANY (ARRAY[
      'order_placed', 'order_accepted', 'order_cancelled',
      'order_delivered', 'order_completed',
      'rental_reminder', 'rental_extension',
      'new_message', 'group_message', 'system'
    ])
  );

-- 2. Rebuild trigger with email_queued + exception handling
-- EXCEPTION block ensures a trigger failure never rolls back the message INSERT
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
    BEGIN
      INSERT INTO public.notifications
        (user_id, type, title, body, action_type, action_url, email_queued)
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
        false
      );
    EXCEPTION WHEN OTHERS THEN
      -- Log but never fail — message delivery takes priority
      RAISE LOG 'notify_group_message failed for user %: %', v_member.user_id, SQLERRM;
    END;
  END LOOP;

  RETURN NEW;
END;
$$;

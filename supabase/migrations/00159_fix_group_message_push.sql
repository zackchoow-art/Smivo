-- ============================================================
-- Fix group message push notification routing
-- ============================================================

-- 1. Update the trigger to use trip_id for action_url and pass room_id for suppression
CREATE OR REPLACE FUNCTION public.notify_group_message()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = ''
AS $$
DECLARE
  v_room_name text;
  v_trip_id uuid;
  v_sender_name text;
  v_member RECORD;
BEGIN
  -- Get room name and trip_id for the notification title & action url
  SELECT name, trip_id INTO v_room_name, v_trip_id
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
      '/group-chat/' || v_trip_id::text || '?room_id=' || NEW.room_id::text,
      -- Keep chat_room_id NULL because of the foreign key constraint to 1-on-1 chat_rooms
      NULL
    );
  END LOOP;

  RETURN NEW;
END;
$$;

-- 2. Update any existing notifications to use trip_id in their action_url with room_id as a query param
UPDATE public.notifications n
SET action_url = '/group-chat/' || gcr.trip_id::text || '?room_id=' || gcr.id::text
FROM public.group_chat_rooms gcr
WHERE n.type = 'group_message'
  AND n.action_url = '/group-chat/' || gcr.id::text;

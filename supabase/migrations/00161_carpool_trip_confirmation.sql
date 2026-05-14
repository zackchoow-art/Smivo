-- Migration 00161: Add confirmed status to carpool_trips and confirm_trip RPC

-- 1. Update the CHECK constraint on carpool_trips.status
ALTER TABLE public.carpool_trips DROP CONSTRAINT IF EXISTS carpool_trips_status_check;
ALTER TABLE public.carpool_trips ADD CONSTRAINT carpool_trips_status_check 
  CHECK (status IN ('active', 'inactive', 'confirmed', 'departed', 'completed', 'cancelled'));

-- 2. Add 'confirmed' to system_dictionaries
INSERT INTO public.system_dictionaries (dict_type, dict_key, dict_value, description, extra, display_order)
VALUES ('carpool_status', 'confirmed', 'Confirmed', 'Trip is locked and ready for departure', '{"icon": "lock", "color": "#2563EB"}', 2)
ON CONFLICT (dict_type, dict_key) DO UPDATE SET display_order = 2, extra = '{"icon": "lock", "color": "#2563EB"}';

-- Adjust display_order of others if needed
UPDATE public.system_dictionaries SET display_order = 3 WHERE dict_type = 'carpool_status' AND dict_key = 'inactive';
UPDATE public.system_dictionaries SET display_order = 4 WHERE dict_type = 'carpool_status' AND dict_key = 'departed';
UPDATE public.system_dictionaries SET display_order = 5 WHERE dict_type = 'carpool_status' AND dict_key = 'completed';
UPDATE public.system_dictionaries SET display_order = 6 WHERE dict_type = 'carpool_status' AND dict_key = 'cancelled';

-- 3. Create the confirm_carpool_trip RPC
CREATE OR REPLACE FUNCTION public.confirm_carpool_trip(p_trip_id uuid)
RETURNS void
LANGUAGE plpgsql SECURITY DEFINER AS $$
DECLARE
  v_creator_id uuid;
  v_group_room_id uuid;
  v_member record;
BEGIN
  -- 1. Verify trip exists and get creator
  SELECT creator_id INTO v_creator_id
  FROM public.carpool_trips
  WHERE id = p_trip_id AND status IN ('active', 'inactive');

  IF v_creator_id IS NULL THEN
    RAISE EXCEPTION 'Trip not found or not in a confirmable state (must be active or inactive)';
  END IF;

  IF v_creator_id != auth.uid() THEN
    RAISE EXCEPTION 'Only the trip creator can confirm the trip';
  END IF;

  -- 2. Update status to confirmed
  UPDATE public.carpool_trips
  SET status = 'confirmed', updated_at = now()
  WHERE id = p_trip_id;

  -- 3. Get group chat room
  SELECT id INTO v_group_room_id
  FROM public.group_chat_rooms
  WHERE trip_id = p_trip_id;

  -- 4. Insert system message into group chat
  IF v_group_room_id IS NOT NULL THEN
    INSERT INTO public.group_messages (room_id, sender_id, content, message_type)
    VALUES (v_group_room_id, v_creator_id, 'Trip has been confirmed. Cancellations are no longer permitted.', 'system');
  END IF;

  -- 5. Send notifications to all approved members (except creator)
  FOR v_member IN
    SELECT user_id FROM public.carpool_members
    WHERE trip_id = p_trip_id AND status = 'approved' AND user_id != v_creator_id
  LOOP
    INSERT INTO public.notifications (user_id, type, title, body, action_type, action_url)
    VALUES (
      v_member.user_id,
      'system',
      'Trip Confirmed',
      'Your carpool trip has been confirmed by the organizer. Cancellations are no longer permitted.',
      'route',
      '/carpool/' || p_trip_id
    );
  END LOOP;
END;
$$;

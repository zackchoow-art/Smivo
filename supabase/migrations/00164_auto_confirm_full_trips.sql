-- ============================================================
-- Migration 00164: Auto-confirm full auto-approve trips
-- ============================================================
-- Update join_carpool_trip RPC so that when an auto-approve trip
-- reaches 0 available seats, its status automatically changes to 'confirmed'.

CREATE OR REPLACE FUNCTION public.join_carpool_trip(
  p_trip_id uuid,
  p_user_id uuid
)
RETURNS jsonb
LANGUAGE plpgsql SECURITY DEFINER
SET search_path = ''
AS $$
DECLARE
  v_trip       RECORD;
  v_blocker    uuid;
  v_member_id  uuid;
  v_room_id    uuid;
BEGIN
  -- 1. Validate trip exists and is joinable
  SELECT * INTO v_trip FROM public.carpool_trips WHERE id = p_trip_id;
  IF NOT FOUND THEN
    RETURN jsonb_build_object('success', false, 'error', 'Trip not found');
  END IF;
  IF v_trip.status != 'active' THEN
    RETURN jsonb_build_object('success', false, 'error', 'Trip is no longer accepting passengers');
  END IF;
  IF v_trip.available_seats <= 0 THEN
    RETURN jsonb_build_object('success', false, 'error', 'No available seats');
  END IF;
  IF v_trip.creator_id = p_user_id THEN
    RETURN jsonb_build_object('success', false, 'error', 'You are the creator of this trip');
  END IF;

  -- 2. Check for existing membership
  IF EXISTS (
    SELECT 1 FROM public.carpool_members
    WHERE trip_id = p_trip_id AND user_id = p_user_id AND status NOT IN ('rejected', 'left', 'kicked')
  ) THEN
    RETURN jsonb_build_object('success', false, 'error', 'You have already applied or joined this trip');
  END IF;

  -- 3. N×N user_blocks safety check: applicant vs ALL approved members
  -- Check if any approved member has blocked the applicant
  SELECT ub.user_id INTO v_blocker
  FROM public.user_blocks ub
  JOIN public.carpool_members cm ON cm.user_id = ub.user_id
  WHERE cm.trip_id = p_trip_id
    AND cm.status = 'approved'
    AND ub.blocked_user_id = p_user_id
  LIMIT 1;

  IF v_blocker IS NOT NULL THEN
    RETURN jsonb_build_object('success', false, 'error', 'Unable to join this trip due to safety restrictions');
  END IF;

  -- Check if the applicant has blocked any approved member
  SELECT ub.blocked_user_id INTO v_blocker
  FROM public.user_blocks ub
  JOIN public.carpool_members cm ON cm.user_id = ub.blocked_user_id
  WHERE cm.trip_id = p_trip_id
    AND cm.status = 'approved'
    AND ub.user_id = p_user_id
  LIMIT 1;

  IF v_blocker IS NOT NULL THEN
    RETURN jsonb_build_object('success', false, 'error', 'Unable to join this trip due to safety restrictions');
  END IF;

  -- 4. Check closing time
  IF v_trip.closing_time IS NOT NULL AND now() > v_trip.closing_time THEN
    RETURN jsonb_build_object('success', false, 'error', 'Registration for this trip has closed');
  END IF;

  -- 5. Insert membership
  IF v_trip.approval_mode = 'auto' THEN
    -- Auto-approve: directly add as member
    INSERT INTO public.carpool_members (trip_id, user_id, role, status, joined_at)
    VALUES (p_trip_id, p_user_id, 'member', 'approved', now())
    ON CONFLICT (trip_id, user_id) DO UPDATE
      SET status = 'approved', joined_at = now()
    RETURNING id INTO v_member_id;

    -- Decrement available seats and auto-confirm if full
    UPDATE public.carpool_trips
    SET available_seats = available_seats - 1,
        status = CASE WHEN available_seats - 1 <= 0 THEN 'confirmed' ELSE status END
    WHERE id = p_trip_id;

    -- Add to group chat
    SELECT id INTO v_room_id FROM public.group_chat_rooms WHERE trip_id = p_trip_id;
    IF v_room_id IS NOT NULL THEN
      INSERT INTO public.group_chat_members (room_id, user_id)
      VALUES (v_room_id, p_user_id)
      ON CONFLICT (room_id, user_id) DO NOTHING;

      -- System message announcing new member
      INSERT INTO public.group_messages (room_id, sender_id, content, message_type)
      VALUES (v_room_id, p_user_id,
        (SELECT COALESCE(display_name, email) FROM public.user_profiles WHERE id = p_user_id) || ' joined the trip!',
        'system');
    END IF;

    RETURN jsonb_build_object('success', true, 'status', 'approved', 'member_id', v_member_id);
  ELSE
    -- Manual approval: create pending request
    INSERT INTO public.carpool_members (trip_id, user_id, role, status)
    VALUES (p_trip_id, p_user_id, 'member', 'pending')
    ON CONFLICT (trip_id, user_id) DO UPDATE
      SET status = 'pending'
    RETURNING id INTO v_member_id;

    RETURN jsonb_build_object('success', true, 'status', 'pending', 'member_id', v_member_id);
  END IF;
END;
$$;

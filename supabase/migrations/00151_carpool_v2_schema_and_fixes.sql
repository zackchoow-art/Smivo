-- ============================================================
-- Migration 00151: Carpool V2 Schema + Bug Fixes
-- ============================================================
-- 1. Fix blocker_id bug in join_carpool_trip RPC
--    (user_blocks columns: user_id / blocked_user_id,
--     NOT blocker_id / blocked_id)
-- 2. Add new columns: estimated_total_price,
--    departure_description, destination_description
-- 3. Add cancellation tracking to carpool_members
-- 4. Widen total_seats constraint from 1-4 to 1-9
-- 5. Fix Chinese text in trigger function
-- 6. Update leave_carpool_trip to record cancellation timing
-- ============================================================


-- ═══════════════════════════════════════════════════════════════
-- 1. New columns on carpool_trips
-- ═══════════════════════════════════════════════════════════════

ALTER TABLE public.carpool_trips
  ADD COLUMN IF NOT EXISTS estimated_total_price numeric(10,2),
  ADD COLUMN IF NOT EXISTS departure_description text,
  ADD COLUMN IF NOT EXISTS destination_description text;

COMMENT ON COLUMN public.carpool_trips.estimated_total_price
  IS 'Estimated total trip cost (split among all passengers + creator)';
COMMENT ON COLUMN public.carpool_trips.departure_description
  IS 'Short human-friendly label for departure (e.g. Smith College)';
COMMENT ON COLUMN public.carpool_trips.destination_description
  IS 'Short human-friendly label for destination (e.g. Bradley Airport)';


-- ═══════════════════════════════════════════════════════════════
-- 2. Cancellation tracking on carpool_members
-- ═══════════════════════════════════════════════════════════════

ALTER TABLE public.carpool_members
  ADD COLUMN IF NOT EXISTS cancelled_at timestamptz,
  ADD COLUMN IF NOT EXISTS cancel_lead_time_minutes integer;

COMMENT ON COLUMN public.carpool_members.cancelled_at
  IS 'Timestamp when member cancelled/left the trip';
COMMENT ON COLUMN public.carpool_members.cancel_lead_time_minutes
  IS 'Minutes between cancellation and scheduled departure (risk metric)';


-- ═══════════════════════════════════════════════════════════════
-- 3. Widen total_seats constraint from 1-4 to 1-9
-- ═══════════════════════════════════════════════════════════════

ALTER TABLE public.carpool_trips
  DROP CONSTRAINT IF EXISTS carpool_trips_total_seats_check;
ALTER TABLE public.carpool_trips
  ADD CONSTRAINT carpool_trips_total_seats_check
    CHECK (total_seats BETWEEN 1 AND 9);


-- ═══════════════════════════════════════════════════════════════
-- 4. Fix join_carpool_trip RPC — correct user_blocks column names
--    OLD (wrong): ub.blocker_id, ub.blocked_id
--    NEW (correct): ub.user_id, ub.blocked_user_id
-- ═══════════════════════════════════════════════════════════════

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
  -- FIX: user_blocks columns are user_id (blocker) and blocked_user_id (blocked)
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

    -- Decrement available seats
    UPDATE public.carpool_trips
    SET available_seats = available_seats - 1
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


-- ═══════════════════════════════════════════════════════════════
-- 5. Update leave_carpool_trip — record cancellation timing
-- ═══════════════════════════════════════════════════════════════

CREATE OR REPLACE FUNCTION public.leave_carpool_trip(
  p_trip_id uuid,
  p_user_id uuid
)
RETURNS jsonb
LANGUAGE plpgsql SECURITY DEFINER
SET search_path = ''
AS $$
DECLARE
  v_member  RECORD;
  v_trip    RECORD;
  v_room_id uuid;
  v_lead_minutes integer;
BEGIN
  SELECT * INTO v_member
  FROM public.carpool_members
  WHERE trip_id = p_trip_id AND user_id = p_user_id AND status = 'approved';

  IF NOT FOUND THEN
    RETURN jsonb_build_object('success', false, 'error', 'Not a member of this trip');
  END IF;

  -- Creator cannot leave their own trip (they should cancel instead)
  IF v_member.role = 'creator' THEN
    RETURN jsonb_build_object('success', false, 'error', 'Trip creator cannot leave. Cancel the trip instead.');
  END IF;

  -- Get trip for departure_time to calculate lead time
  SELECT * INTO v_trip FROM public.carpool_trips WHERE id = p_trip_id;

  -- Calculate cancellation lead time in minutes
  v_lead_minutes := EXTRACT(EPOCH FROM (v_trip.departure_time - now()))::integer / 60;

  -- Mark as left with cancellation metadata
  UPDATE public.carpool_members
  SET status = 'left',
      cancelled_at = now(),
      cancel_lead_time_minutes = v_lead_minutes
  WHERE trip_id = p_trip_id AND user_id = p_user_id;

  -- Increment available seats
  UPDATE public.carpool_trips
  SET available_seats = available_seats + 1
  WHERE id = p_trip_id;

  -- Remove from group chat
  SELECT id INTO v_room_id FROM public.group_chat_rooms WHERE trip_id = p_trip_id;
  IF v_room_id IS NOT NULL THEN
    DELETE FROM public.group_chat_members
    WHERE room_id = v_room_id AND user_id = p_user_id;

    INSERT INTO public.group_messages (room_id, sender_id, content, message_type)
    VALUES (v_room_id, p_user_id,
      (SELECT COALESCE(display_name, email) FROM public.user_profiles WHERE id = p_user_id) || ' left the trip.',
      'system');
  END IF;

  RETURN jsonb_build_object('success', true, 'lead_time_minutes', v_lead_minutes);
END;
$$;


-- ═══════════════════════════════════════════════════════════════
-- 6. Fix Chinese text in trip creation trigger
-- ═══════════════════════════════════════════════════════════════

CREATE OR REPLACE FUNCTION public.on_carpool_trip_created()
RETURNS TRIGGER
LANGUAGE plpgsql SECURITY DEFINER
SET search_path = ''
AS $$
DECLARE
  v_room_id uuid;
  v_room_name text;
BEGIN
  -- Insert creator as first approved member
  INSERT INTO public.carpool_members (trip_id, user_id, role, status, joined_at)
  VALUES (NEW.id, NEW.creator_id, 'creator', 'approved', now());

  -- Build room name from descriptions (preferred) or addresses (fallback)
  v_room_name := COALESCE(NEW.departure_description, LEFT(NEW.departure_address, 20))
    || ' → '
    || COALESCE(NEW.destination_description, LEFT(NEW.destination_address, 20));

  -- Create the group chat room for this trip
  INSERT INTO public.group_chat_rooms (trip_id, name, created_by)
  VALUES (NEW.id, v_room_name, NEW.creator_id)
  RETURNING id INTO v_room_id;

  -- Add creator to the group chat
  INSERT INTO public.group_chat_members (room_id, user_id)
  VALUES (v_room_id, NEW.creator_id);

  -- Send system welcome message
  INSERT INTO public.group_messages (room_id, sender_id, content, message_type)
  VALUES (v_room_id, NEW.creator_id, 'Trip created! Waiting for passengers to join.', 'system');

  RETURN NEW;
END;
$$;


-- ═══════════════════════════════════════════════════════════════
-- 7. Notify PostgREST to pick up schema changes
-- ═══════════════════════════════════════════════════════════════
NOTIFY pgrst, 'reload schema';

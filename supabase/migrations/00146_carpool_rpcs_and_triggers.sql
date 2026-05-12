-- ============================================================
-- Migration 00146: Carpool RPC Functions & Triggers
-- ============================================================
-- Business logic functions:
--   1. Auto-insert creator as first member on trip creation
--   2. Auto-create group chat room on trip creation
--   3. join_carpool_trip — with user_blocks N×N safety check
--   4. accept_carpool_member — approve + add to group chat
--   5. leave_carpool_trip — leave + free seat + remove from chat
--   6. cast_carpool_vote — vote + consensus check + auto-apply
--   7. Seat management triggers (full → inactive, freed → active)
-- ============================================================


-- ═══════════════════════════════════════════════════════════════
-- 1. Auto-insert creator as approved member on trip creation
-- ═══════════════════════════════════════════════════════════════

CREATE OR REPLACE FUNCTION public.on_carpool_trip_created()
RETURNS TRIGGER
LANGUAGE plpgsql SECURITY DEFINER
SET search_path = ''
AS $$
DECLARE
  v_room_id uuid;
BEGIN
  -- Insert creator as first approved member
  INSERT INTO public.carpool_members (trip_id, user_id, role, status, joined_at)
  VALUES (NEW.id, NEW.creator_id, 'creator', 'approved', now());

  -- Create the group chat room for this trip
  INSERT INTO public.group_chat_rooms (trip_id, name, created_by)
  VALUES (NEW.id, '拼车: ' || LEFT(NEW.departure_address, 20) || ' → ' || LEFT(NEW.destination_address, 20), NEW.creator_id)
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

CREATE TRIGGER trg_carpool_trip_created
  AFTER INSERT ON public.carpool_trips
  FOR EACH ROW EXECUTE FUNCTION public.on_carpool_trip_created();


-- ═══════════════════════════════════════════════════════════════
-- 2. join_carpool_trip — safe join with user_blocks N×N check
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
  -- Check if any approved member has blocked the applicant
  SELECT ub.blocker_id INTO v_blocker
  FROM public.user_blocks ub
  JOIN public.carpool_members cm ON cm.user_id = ub.blocker_id
  WHERE cm.trip_id = p_trip_id
    AND cm.status = 'approved'
    AND ub.blocked_id = p_user_id
  LIMIT 1;

  IF v_blocker IS NOT NULL THEN
    RETURN jsonb_build_object('success', false, 'error', 'Unable to join this trip due to safety restrictions');
  END IF;

  -- Check if the applicant has blocked any approved member
  SELECT ub.blocked_id INTO v_blocker
  FROM public.user_blocks ub
  JOIN public.carpool_members cm ON cm.user_id = ub.blocked_id
  WHERE cm.trip_id = p_trip_id
    AND cm.status = 'approved'
    AND ub.blocker_id = p_user_id
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
-- 3. accept_carpool_member — creator approves a join request
-- ═══════════════════════════════════════════════════════════════

CREATE OR REPLACE FUNCTION public.accept_carpool_member(p_member_id uuid)
RETURNS jsonb
LANGUAGE plpgsql SECURITY DEFINER
SET search_path = ''
AS $$
DECLARE
  v_member  RECORD;
  v_trip    RECORD;
  v_room_id uuid;
BEGIN
  SELECT * INTO v_member FROM public.carpool_members WHERE id = p_member_id;
  IF NOT FOUND THEN
    RETURN jsonb_build_object('success', false, 'error', 'Member not found');
  END IF;
  IF v_member.status != 'pending' THEN
    RETURN jsonb_build_object('success', false, 'error', 'Request is no longer pending');
  END IF;

  SELECT * INTO v_trip FROM public.carpool_trips WHERE id = v_member.trip_id;
  -- Verify caller is trip creator
  IF v_trip.creator_id != auth.uid() THEN
    RETURN jsonb_build_object('success', false, 'error', 'Only the trip creator can approve members');
  END IF;
  IF v_trip.available_seats <= 0 THEN
    RETURN jsonb_build_object('success', false, 'error', 'No available seats');
  END IF;

  -- Approve the member
  UPDATE public.carpool_members
  SET status = 'approved', joined_at = now()
  WHERE id = p_member_id;

  -- Decrement available seats
  UPDATE public.carpool_trips
  SET available_seats = available_seats - 1
  WHERE id = v_member.trip_id;

  -- Add to group chat
  SELECT id INTO v_room_id FROM public.group_chat_rooms WHERE trip_id = v_member.trip_id;
  IF v_room_id IS NOT NULL THEN
    INSERT INTO public.group_chat_members (room_id, user_id)
    VALUES (v_room_id, v_member.user_id)
    ON CONFLICT (room_id, user_id) DO NOTHING;

    INSERT INTO public.group_messages (room_id, sender_id, content, message_type)
    VALUES (v_room_id, v_member.user_id,
      (SELECT COALESCE(display_name, email) FROM public.user_profiles WHERE id = v_member.user_id) || ' joined the trip!',
      'system');
  END IF;

  RETURN jsonb_build_object('success', true);
END;
$$;


-- ═══════════════════════════════════════════════════════════════
-- 4. leave_carpool_trip — member leaves voluntarily
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

  -- Mark as left
  UPDATE public.carpool_members
  SET status = 'left'
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

  RETURN jsonb_build_object('success', true);
END;
$$;


-- ═══════════════════════════════════════════════════════════════
-- 5. cast_carpool_vote — vote + consensus check + auto-apply
-- ═══════════════════════════════════════════════════════════════

CREATE OR REPLACE FUNCTION public.cast_carpool_vote(
  p_proposal_id uuid,
  p_voter_id    uuid,
  p_vote        text  -- 'approve' or 'reject'
)
RETURNS jsonb
LANGUAGE plpgsql SECURITY DEFINER
SET search_path = ''
AS $$
DECLARE
  v_proposal   RECORD;
  v_trip       RECORD;
  v_new_votes  integer;
  v_room_id    uuid;
BEGIN
  -- Validate inputs
  IF p_vote NOT IN ('approve', 'reject') THEN
    RETURN jsonb_build_object('success', false, 'error', 'Invalid vote value');
  END IF;

  SELECT * INTO v_proposal FROM public.carpool_proposals WHERE id = p_proposal_id;
  IF NOT FOUND THEN
    RETURN jsonb_build_object('success', false, 'error', 'Proposal not found');
  END IF;
  IF v_proposal.status != 'pending' THEN
    RETURN jsonb_build_object('success', false, 'error', 'Proposal is no longer pending');
  END IF;

  -- Verify voter is an approved member (and not the proposer)
  IF NOT EXISTS (
    SELECT 1 FROM public.carpool_members
    WHERE trip_id = v_proposal.trip_id AND user_id = p_voter_id AND status = 'approved'
  ) THEN
    RETURN jsonb_build_object('success', false, 'error', 'You are not a member of this trip');
  END IF;
  IF v_proposal.proposer_id = p_voter_id THEN
    RETURN jsonb_build_object('success', false, 'error', 'You cannot vote on your own proposal');
  END IF;

  -- Check expiry
  IF v_proposal.expires_at IS NOT NULL AND now() > v_proposal.expires_at THEN
    UPDATE public.carpool_proposals SET status = 'expired' WHERE id = p_proposal_id;
    RETURN jsonb_build_object('success', false, 'error', 'Proposal has expired');
  END IF;

  -- Insert vote (unique constraint prevents double-voting)
  INSERT INTO public.carpool_votes (proposal_id, voter_id, vote)
  VALUES (p_proposal_id, p_voter_id, p_vote);

  -- If rejected: any single rejection fails the whole proposal (unanimous required)
  IF p_vote = 'reject' THEN
    UPDATE public.carpool_proposals SET status = 'rejected' WHERE id = p_proposal_id;
    RETURN jsonb_build_object('success', true, 'proposal_status', 'rejected');
  END IF;

  -- Count approve votes
  SELECT COUNT(*) INTO v_new_votes
  FROM public.carpool_votes
  WHERE proposal_id = p_proposal_id AND vote = 'approve';

  UPDATE public.carpool_proposals SET current_votes = v_new_votes WHERE id = p_proposal_id;

  -- Check if consensus reached
  IF v_new_votes >= v_proposal.required_votes THEN
    UPDATE public.carpool_proposals SET status = 'approved' WHERE id = p_proposal_id;

    SELECT * INTO v_trip FROM public.carpool_trips WHERE id = v_proposal.trip_id;

    -- Apply the proposal
    CASE v_proposal.proposal_type
      WHEN 'change_time' THEN
        UPDATE public.carpool_trips
        SET departure_time = v_proposal.new_value::timestamptz
        WHERE id = v_proposal.trip_id;

      WHEN 'change_departure' THEN
        UPDATE public.carpool_trips
        SET departure_address = v_proposal.new_value
        WHERE id = v_proposal.trip_id;

      WHEN 'change_destination' THEN
        UPDATE public.carpool_trips
        SET destination_address = v_proposal.new_value
        WHERE id = v_proposal.trip_id;

      WHEN 'kick_member' THEN
        -- Kick the target user
        UPDATE public.carpool_members
        SET status = 'kicked'
        WHERE trip_id = v_proposal.trip_id AND user_id = v_proposal.target_user_id;

        -- Free up the seat
        UPDATE public.carpool_trips
        SET available_seats = available_seats + 1
        WHERE id = v_proposal.trip_id;

        -- Remove from group chat
        SELECT id INTO v_room_id FROM public.group_chat_rooms WHERE trip_id = v_proposal.trip_id;
        IF v_room_id IS NOT NULL THEN
          DELETE FROM public.group_chat_members
          WHERE room_id = v_room_id AND user_id = v_proposal.target_user_id;

          INSERT INTO public.group_messages (room_id, sender_id, content, message_type)
          VALUES (v_room_id, v_proposal.proposer_id,
            (SELECT COALESCE(display_name, email) FROM public.user_profiles WHERE id = v_proposal.target_user_id)
              || ' was removed from the trip by vote.',
            'system');
        END IF;
    END CASE;

    RETURN jsonb_build_object('success', true, 'proposal_status', 'approved');
  END IF;

  RETURN jsonb_build_object('success', true, 'proposal_status', 'pending', 'votes_so_far', v_new_votes);
END;
$$;


-- ═══════════════════════════════════════════════════════════════
-- 6. Seat management trigger — auto inactive/active
-- ═══════════════════════════════════════════════════════════════

CREATE OR REPLACE FUNCTION public.carpool_seat_management()
RETURNS TRIGGER
LANGUAGE plpgsql SECURITY DEFINER
SET search_path = ''
AS $$
BEGIN
  -- When available_seats drops to 0, set trip to inactive
  IF NEW.available_seats = 0 AND NEW.status = 'active' THEN
    NEW.status := 'inactive';
  END IF;

  -- When a seat is freed and trip was inactive (full), reactivate
  IF NEW.available_seats > 0 AND OLD.available_seats = 0 AND OLD.status = 'inactive' THEN
    NEW.status := 'active';
  END IF;

  RETURN NEW;
END;
$$;

CREATE TRIGGER trg_carpool_seat_management
  BEFORE UPDATE ON public.carpool_trips
  FOR EACH ROW
  WHEN (OLD.available_seats IS DISTINCT FROM NEW.available_seats)
  EXECUTE FUNCTION public.carpool_seat_management();


-- ═══════════════════════════════════════════════════════════════
-- 7. Carpool notification types in system_dictionaries
-- ═══════════════════════════════════════════════════════════════

INSERT INTO public.system_dictionaries (dict_type, dict_key, dict_value, description, extra, display_order)
VALUES
  ('notification_type', 'carpool_join_request',   'Join Request',     'Someone wants to join your trip',      NULL, 10),
  ('notification_type', 'carpool_join_approved',   'Join Approved',    'Your join request was approved',       NULL, 11),
  ('notification_type', 'carpool_join_rejected',   'Join Rejected',    'Your join request was rejected',       NULL, 12),
  ('notification_type', 'carpool_member_left',     'Member Left',      'A member left your trip',              NULL, 13),
  ('notification_type', 'carpool_trip_cancelled',  'Trip Cancelled',   'A trip you joined was cancelled',      NULL, 14),
  ('notification_type', 'carpool_proposal_created','New Proposal',     'A change was proposed for your trip',  NULL, 15),
  ('notification_type', 'carpool_vote_result',     'Vote Result',      'A proposal was approved or rejected',  NULL, 16),
  ('notification_type', 'carpool_trip_departed',   'Trip Departed',    'Your trip has departed',               NULL, 17)
ON CONFLICT (dict_type, dict_key) DO NOTHING;


-- ═══════════════════════════════════════════════════════════════
-- 8. Realtime — enable for carpool_members (status changes)
-- ═══════════════════════════════════════════════════════════════

ALTER PUBLICATION supabase_realtime ADD TABLE public.carpool_members;
ALTER PUBLICATION supabase_realtime ADD TABLE public.carpool_proposals;

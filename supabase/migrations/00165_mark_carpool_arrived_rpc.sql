-- ============================================================
-- Migration 00165: RPC for any participant to mark trip arrived
-- ============================================================
-- Allows the creator or any approved member to confirm arrival
-- once the trip is 'confirmed'.

CREATE OR REPLACE FUNCTION public.mark_carpool_arrived(p_trip_id uuid)
RETURNS void
LANGUAGE plpgsql SECURITY DEFINER
SET search_path = ''
AS $$
DECLARE
  v_trip RECORD;
  v_is_participant boolean;
BEGIN
  -- 1. Check if user is participant
  SELECT (auth.uid() = creator_id OR public.is_carpool_member(id))
  INTO v_is_participant
  FROM public.carpool_trips
  WHERE id = p_trip_id;

  IF NOT v_is_participant THEN
    RAISE EXCEPTION 'Only participants can mark the trip as arrived';
  END IF;

  -- 2. Verify status
  SELECT * INTO v_trip FROM public.carpool_trips WHERE id = p_trip_id;
  IF v_trip.status != 'confirmed' AND v_trip.status != 'departed' THEN
    RAISE EXCEPTION 'Trip must be confirmed or departed to mark as arrived';
  END IF;

  -- 3. Update status
  UPDATE public.carpool_trips
  SET status = 'arrived'
  WHERE id = p_trip_id;
END;
$$;

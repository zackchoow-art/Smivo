-- Add snapshot column to carpool_members
ALTER TABLE public.carpool_members
ADD COLUMN IF NOT EXISTS last_acknowledged_snapshot jsonb;

-- Trigger function to handle trip edits
CREATE OR REPLACE FUNCTION public.handle_carpool_trip_update()
RETURNS TRIGGER AS $$
BEGIN
  -- Only trigger on manual edits (not status changes like departed/arrived/cancelled)
  IF NEW.status = OLD.status AND (
     NEW.departure_time IS DISTINCT FROM OLD.departure_time OR
     NEW.departure_address IS DISTINCT FROM OLD.departure_address OR
     NEW.destination_address IS DISTINCT FROM OLD.destination_address OR
     NEW.total_seats IS DISTINCT FROM OLD.total_seats OR
     NEW.luggage_limit IS DISTINCT FROM OLD.luggage_limit OR
     NEW.estimated_total_price IS DISTINCT FROM OLD.estimated_total_price OR
     NEW.note IS DISTINCT FROM OLD.note
  ) THEN
  
    -- Prevent reducing total_seats below currently approved members
    -- (total_seats - available_seats) is the number of approved members
    IF NEW.total_seats < (OLD.total_seats - OLD.available_seats) THEN
      RAISE EXCEPTION 'Total seats cannot be less than the number of currently approved members.';
    END IF;

    -- Automatically adjust available_seats based on the delta of total_seats
    NEW.available_seats = OLD.available_seats + (NEW.total_seats - OLD.total_seats);

    -- Snapshot the OLD state for members who don't have one (meaning they were up-to-date before this edit)
    UPDATE public.carpool_members
    SET last_acknowledged_snapshot = jsonb_build_object(
      'departure_time', OLD.departure_time,
      'departure_address', OLD.departure_address,
      'departure_description', OLD.departure_description,
      'destination_address', OLD.destination_address,
      'destination_description', OLD.destination_description,
      'total_seats', OLD.total_seats,
      'luggage_limit', OLD.luggage_limit,
      'estimated_total_price', OLD.estimated_total_price,
      'note', OLD.note
    )
    WHERE trip_id = NEW.id 
      AND user_id != NEW.creator_id 
      AND status IN ('pending', 'approved')
      AND last_acknowledged_snapshot IS NULL;
      
    -- Notify all active members about the edit
    INSERT INTO public.notifications (
      user_id, type, title, body, data
    )
    SELECT 
      user_id,
      'system_message',
      'Trip Updated',
      'The organizer has modified the trip details. Please review and accept the changes.',
      jsonb_build_object('trip_id', NEW.id, 'action_url', '/carpool/' || NEW.id)
    FROM public.carpool_members
    WHERE trip_id = NEW.id 
      AND user_id != NEW.creator_id 
      AND status IN ('pending', 'approved');

  END IF;
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Attach trigger to carpool_trips
DROP TRIGGER IF EXISTS trg_carpool_trip_update ON public.carpool_trips;
CREATE TRIGGER trg_carpool_trip_update
BEFORE UPDATE ON public.carpool_trips
FOR EACH ROW
EXECUTE FUNCTION public.handle_carpool_trip_update();

-- RPC for a member to accept the changes
CREATE OR REPLACE FUNCTION public.accept_carpool_trip_changes(p_trip_id uuid)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  UPDATE public.carpool_members
  SET last_acknowledged_snapshot = NULL
  WHERE trip_id = p_trip_id AND user_id = auth.uid();
  
  RETURN jsonb_build_object('success', true);
END;
$$;

-- Add cost settlement fields to carpool_trips.
-- These allow the trip creator to record the actual total cost after arrival,
-- so all passengers can see their calculated individual share.
ALTER TABLE public.carpool_trips
  ADD COLUMN IF NOT EXISTS actual_total_cost numeric(10,2),
  ADD COLUMN IF NOT EXISTS settled_at timestamptz;

COMMENT ON COLUMN public.carpool_trips.actual_total_cost
  IS 'Actual total cost entered by creator after arrival';
COMMENT ON COLUMN public.carpool_trips.settled_at
  IS 'Timestamp when the creator confirmed the final cost';

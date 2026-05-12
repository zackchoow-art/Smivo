-- ============================================================
-- Add carpool_trips to Realtime publication for live list updates
-- ============================================================

ALTER PUBLICATION supabase_realtime ADD TABLE public.carpool_trips;

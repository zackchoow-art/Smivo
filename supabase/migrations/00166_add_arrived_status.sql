-- Migration 00166: Add arrived status to carpool_trips check constraint
-- This fixes the error when participants mark a trip as arrived

-- 1. Update the CHECK constraint on carpool_trips.status
ALTER TABLE public.carpool_trips DROP CONSTRAINT IF EXISTS carpool_trips_status_check;
ALTER TABLE public.carpool_trips ADD CONSTRAINT carpool_trips_status_check 
  CHECK (status IN ('active', 'inactive', 'confirmed', 'departed', 'arrived', 'completed', 'cancelled'));

-- 2. Add 'arrived' to system_dictionaries
INSERT INTO public.system_dictionaries (dict_type, dict_key, dict_value, description, extra, display_order)
VALUES ('carpool_status', 'arrived', 'Arrived', 'Trip has arrived at destination', '{"icon": "place", "color": "#10B981"}', 5)
ON CONFLICT (dict_type, dict_key) DO UPDATE SET display_order = 5, extra = '{"icon": "place", "color": "#10B981"}';

-- Adjust display_order of others if needed
UPDATE public.system_dictionaries SET display_order = 6 WHERE dict_type = 'carpool_status' AND dict_key = 'completed';
UPDATE public.system_dictionaries SET display_order = 7 WHERE dict_type = 'carpool_status' AND dict_key = 'cancelled';

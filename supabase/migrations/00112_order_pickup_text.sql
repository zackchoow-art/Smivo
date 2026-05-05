-- 00112: Add text columns for order snapshotting
ALTER TABLE public.orders
ADD COLUMN pickup_location_name text;

-- Backfill existing orders so they don't break
UPDATE public.orders o
SET pickup_location_name = p.name
FROM public.pickup_locations p
WHERE o.pickup_location_id = p.id;

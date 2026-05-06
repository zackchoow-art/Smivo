-- Migration 00121: Add custom_pickup_note column to listings
--
-- When a seller selects "Other (Specify in Chat)" as the pickup location,
-- this column stores the seller's custom meeting spot text to be shown
-- in listing detail and order flow.

ALTER TABLE public.listings
  ADD COLUMN IF NOT EXISTS custom_pickup_note text;

COMMENT ON COLUMN public.listings.custom_pickup_note IS
  'Free-text custom pickup location note, shown when pickup_location is Other.';

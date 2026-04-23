-- 00018: Add pickup_location_id to orders for location snapshot
ALTER TABLE orders
  ADD COLUMN pickup_location_id uuid REFERENCES pickup_locations(id);

-- NOTE: This is nullable because existing orders don't have it,
-- and sale orders from before this migration were created without it.

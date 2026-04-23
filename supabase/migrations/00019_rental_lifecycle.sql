-- ════════════════════════════════════════════════════════════
-- 00019: Rental Lifecycle States
--
-- Adds a rental_status column to orders for tracking the post-delivery
-- lifecycle of rental orders: active → return_requested → returned → 
-- deposit_refunded
-- ════════════════════════════════════════════════════════════

-- Add rental status enum-like column
ALTER TABLE public.orders
  ADD COLUMN IF NOT EXISTS rental_status text
  DEFAULT NULL
  CHECK (rental_status IS NULL OR rental_status IN (
    'active', 'return_requested', 'returned', 'deposit_refunded'
  ));

-- Add deposit refunded timestamp
ALTER TABLE public.orders
  ADD COLUMN IF NOT EXISTS deposit_refunded_at timestamptz DEFAULT NULL;

-- Add return requested timestamp
ALTER TABLE public.orders
  ADD COLUMN IF NOT EXISTS return_requested_at timestamptz DEFAULT NULL;

COMMENT ON COLUMN public.orders.rental_status IS 
  'Lifecycle state for rental orders after delivery is confirmed. NULL for sale orders.';

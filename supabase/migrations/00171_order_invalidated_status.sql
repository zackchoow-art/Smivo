-- 00171_order_invalidated_status.sql
-- Add 'invalidated' order status for listings that have been modified by the seller.
-- Invalidated orders remain visible to buyers in their pending area but cannot proceed
-- until the buyer re-submits a new offer.

-- 1. Expand the status check constraint to include 'invalidated'
ALTER TABLE orders DROP CONSTRAINT IF EXISTS orders_status_check;
ALTER TABLE orders ADD CONSTRAINT orders_status_check
  CHECK (status IN ('pending', 'confirmed', 'completed', 'cancelled', 'missed', 'invalidated'));

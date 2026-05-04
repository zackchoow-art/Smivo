-- Migration: 00098_prevent_duplicate_pending_orders
-- Description: Prevent a buyer from creating multiple pending orders for the same listing.
-- This solves the issue of duplicate submissions caused by double clicking the Request button.

SET search_path = '';

-- Create a unique partial index that ensures a buyer can only have one 'pending' order per listing.
CREATE UNIQUE INDEX IF NOT EXISTS unique_pending_order_per_buyer_listing 
ON public.orders (buyer_id, listing_id) 
WHERE status = 'pending';

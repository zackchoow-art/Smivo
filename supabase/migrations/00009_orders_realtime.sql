-- ============================================================
-- Smivo — Enable Realtime on Orders Table
-- ============================================================
-- Allows order status changes to push to clients via 
-- Supabase Realtime so buyer/seller screens stay in sync 
-- when the other party accepts, cancels, or completes an order.
-- ============================================================

alter publication supabase_realtime add table public.orders;

-- ============================================================
-- Smivo — Enable Realtime on listings
-- ============================================================
-- Allows listing changes (create, accept-order-reserved, 
-- complete-order-sold, cancel-back-to-active) to push to 
-- all connected clients so the home feed updates without 
-- manual refresh.
-- ============================================================

alter publication supabase_realtime add table public.listings;

-- ════════════════════════════════════════════════════════════
-- 00034: Allow order participants to read listing data
--
-- When a listing is sold/rented, its status changes from 'active'.
-- Buyers with orders for that listing could no longer read it
-- (images, prices), because the old RLS only allowed
-- status='active' OR seller_id=current_user.
-- This fix adds an EXISTS check for order participants.
-- ════════════════════════════════════════════════════════════

DROP POLICY IF EXISTS "Active listings are publicly readable" ON public.listings;

CREATE POLICY "Listings readable by public or order participants"
  ON public.listings FOR SELECT
  USING (
    status = 'active'
    OR auth.uid() = seller_id
    OR EXISTS (
      SELECT 1 FROM public.orders o
      WHERE o.listing_id = listings.id
        AND (o.buyer_id = auth.uid() OR o.seller_id = auth.uid())
    )
  );

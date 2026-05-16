-- ============================================================
-- Migration 00163: Fix carpool_reviews RLS policies
-- ============================================================
-- ROOT CAUSE:
--   The original policies strictly checked `carpool_members`, but
--   in older test data (and safely across versions), the creator
--   might not be properly registered in `carpool_members`.
--   This caused fetchTripReviews to return empty for the creator,
--   and submitReviews to silently fail RLS constraints for the creator.
--
-- FIX:
--   Use the previously established helper functions:
--   `public.carpool_trip_creator(trip_id)`
--   `public.is_carpool_member(trip_id)`
--   This ensures robust evaluation without recursing.
-- ============================================================

DROP POLICY IF EXISTS "Trip members can read reviews" ON public.carpool_reviews;
CREATE POLICY "Trip members can read reviews"
  ON public.carpool_reviews FOR SELECT
  USING (
    auth.uid() = public.carpool_trip_creator(trip_id)
    OR public.is_carpool_member(trip_id)
  );

DROP POLICY IF EXISTS "Members can create their own reviews" ON public.carpool_reviews;
CREATE POLICY "Members can create their own reviews"
  ON public.carpool_reviews FOR INSERT
  WITH CHECK (
    reviewer_id = auth.uid()
    AND (
      auth.uid() = public.carpool_trip_creator(trip_id)
      OR public.is_carpool_member(trip_id)
    )
  );

-- ============================================================
-- Migration 00168: Fix carpool_reviews foreign keys
-- ============================================================
-- ROOT CAUSE:
--   carpool_reviews referenced `auth.users(id)` for reviewer_id and reviewee_id.
--   However, PostgREST query uses `user_profiles!reviewer_id(*)` to join user info.
--   Without a direct foreign key to `public.user_profiles`, PostgREST cannot
--   resolve the relationship, throwing PGRST200 on `fetchTripReviews`.
--   This error was previously swallowed by AsyncValue.guard, causing the
--   frontend to fail silently and allow the user to repeatedly submit
--   reviews, running into unique constraint errors.
--
-- FIX:
--   Change the foreign keys to reference `public.user_profiles(id)`.
-- ============================================================

ALTER TABLE public.carpool_reviews
  DROP CONSTRAINT IF EXISTS carpool_reviews_reviewer_id_fkey,
  DROP CONSTRAINT IF EXISTS carpool_reviews_reviewee_id_fkey;

ALTER TABLE public.carpool_reviews
  ADD CONSTRAINT carpool_reviews_reviewer_id_fkey
    FOREIGN KEY (reviewer_id) REFERENCES public.user_profiles(id) ON DELETE CASCADE,
  ADD CONSTRAINT carpool_reviews_reviewee_id_fkey
    FOREIGN KEY (reviewee_id) REFERENCES public.user_profiles(id) ON DELETE CASCADE;

-- Notify PostgREST to reload the schema cache so the relationship is recognized
NOTIFY pgrst, 'reload schema';

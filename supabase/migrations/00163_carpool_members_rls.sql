-- ============================================================
-- Migration 00163: Fix carpool_members RLS to show joined members
-- ============================================================
-- ROOT CAUSE:
--   The "Trip participants can read members" policy restricted SELECT
--   so that non-participants (guests or pending members) could not
--   see who had already joined. This caused the UI to show "0 joined"
--   even when there were approved passengers in the carpool.
--
-- FIX:
--   Update the policy so that everyone can see 'approved' members.
--   Creators and the members themselves can still see all of their
--   own membership records (e.g. pending, rejected, left).
-- ============================================================

DROP POLICY IF EXISTS "Trip participants can read members" ON public.carpool_members;

CREATE POLICY "Public can read approved members, participants can read all"
  ON public.carpool_members FOR SELECT
  USING (
    status = 'approved'
    OR auth.uid() = public.carpool_trip_creator(trip_id)
    OR auth.uid() = user_id
  );

-- Notify PostgREST to reload schema
NOTIFY pgrst, 'reload schema';

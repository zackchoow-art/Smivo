-- ============================================================
-- Migration 00150: Fix carpool_trips infinite RLS recursion
-- ============================================================
-- ROOT CAUSE:
--   carpool_trips "Members can read their trips" policy does:
--     SELECT 1 FROM carpool_members WHERE ...
--   carpool_members "Trip participants can read members" policy does:
--     SELECT creator_id FROM carpool_trips WHERE ...
--   This cross-table reference creates an infinite recursion loop.
--
-- FIX:
--   1. Create a SECURITY DEFINER helper to check membership
--      from carpool_trips policies (bypasses carpool_members RLS).
--   2. Create a SECURITY DEFINER helper to get trip creator_id
--      (bypasses carpool_trips RLS).
--   3. Replace recursive policies with helper-based ones.
-- ============================================================


-- ─── 1. Helper: check if current user is an approved member ──
--    Used by carpool_trips RLS to avoid querying carpool_members
--    through its own RLS (which would recurse back to carpool_trips).

CREATE OR REPLACE FUNCTION public.is_carpool_member(p_trip_id uuid)
RETURNS boolean
LANGUAGE sql STABLE SECURITY DEFINER
SET search_path = ''
AS $$
  SELECT EXISTS (
    SELECT 1 FROM public.carpool_members
    WHERE trip_id = p_trip_id AND user_id = auth.uid() AND status = 'approved'
  );
$$;


-- ─── 2. Helper: get trip creator_id without triggering trips RLS ──
--    Used by carpool_members RLS to check creator without recursion.

CREATE OR REPLACE FUNCTION public.carpool_trip_creator(p_trip_id uuid)
RETURNS uuid
LANGUAGE sql STABLE SECURITY DEFINER
SET search_path = ''
AS $$
  SELECT creator_id FROM public.carpool_trips WHERE id = p_trip_id;
$$;


-- ─── 3. Fix carpool_trips "Members can read their trips" ─────
--    Old policy directly queried carpool_members (caused recursion).
--    New policy uses SECURITY DEFINER helper.

DROP POLICY IF EXISTS "Members can read their trips" ON public.carpool_trips;
CREATE POLICY "Members can read their trips"
  ON public.carpool_trips FOR SELECT
  USING (public.is_carpool_member(id));


-- ─── 4. Fix carpool_members "Trip participants can read members" ──
--    Old policy did: SELECT creator_id FROM carpool_trips WHERE id = trip_id
--    which triggered carpool_trips RLS → back to carpool_members RLS.
--    New policy uses SECURITY DEFINER helper.

DROP POLICY IF EXISTS "Trip participants can read members" ON public.carpool_members;
CREATE POLICY "Trip participants can read members"
  ON public.carpool_members FOR SELECT
  USING (
    auth.uid() = public.carpool_trip_creator(trip_id)
    OR public.is_carpool_member(trip_id)
    OR auth.uid() = user_id
  );


-- ─── 5. Fix carpool_members "Creator or self can update" ─────
--    Same recursion risk: SELECT creator_id FROM carpool_trips.

DROP POLICY IF EXISTS "Creator or self can update membership" ON public.carpool_members;
CREATE POLICY "Creator or self can update membership"
  ON public.carpool_members FOR UPDATE
  USING (
    auth.uid() = user_id
    OR auth.uid() = public.carpool_trip_creator(trip_id)
  );

-- ============================================================
-- Smivo — Sync schools.name → user_profiles.school
-- ============================================================
-- Problem: user_profiles.school is a denormalized (snapshot)
-- text column populated at registration time. When an admin
-- renames a school via the admin dashboard, this column is NOT
-- updated, causing the Home page to show the stale school name.
--
-- Fix: Add a BEFORE UPDATE trigger on public.schools that
-- propagates name changes to all matching user_profiles rows.
-- Also backfill any existing mismatches immediately.
-- ============================================================

-- ── 1. Trigger function ──────────────────────────────────────

CREATE OR REPLACE FUNCTION public.sync_school_name_to_profiles()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = ''
AS $$
BEGIN
  -- NOTE: Only run when the name has actually changed to avoid
  -- unnecessary writes on every school UPDATE (e.g. toggling is_active).
  IF NEW.name IS DISTINCT FROM OLD.name THEN
    UPDATE public.user_profiles
    SET
      school     = NEW.name,
      updated_at = now()
    WHERE school_id = NEW.id;
  END IF;

  RETURN NEW;
END;
$$;

-- ── 2. Attach trigger to schools table ───────────────────────

-- Drop existing trigger first (idempotent re-run safety).
DROP TRIGGER IF EXISTS trg_sync_school_name_to_profiles ON public.schools;

CREATE TRIGGER trg_sync_school_name_to_profiles
  AFTER UPDATE ON public.schools
  FOR EACH ROW
  EXECUTE FUNCTION public.sync_school_name_to_profiles();

-- ── 3. Backfill: fix any existing stale school names ─────────
-- Covers all users whose profile.school doesn't match the
-- current schools.name (e.g. from prior manual renames).

UPDATE public.user_profiles up
SET
  school     = s.name,
  updated_at = now()
FROM public.schools s
WHERE up.school_id = s.id
  AND up.school IS DISTINCT FROM s.name;

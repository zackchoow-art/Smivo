-- Migration 00130: Add lift tracking fields to user_bans table
-- Fixes Bug 4: useLiftBan tries to write lifted_at/lifted_by/lift_reason
-- but these columns did not exist, causing the lift button to silently fail.

ALTER TABLE public.user_bans
  ADD COLUMN IF NOT EXISTS lifted_at  timestamptz DEFAULT NULL,
  ADD COLUMN IF NOT EXISTS lifted_by  uuid        DEFAULT NULL REFERENCES auth.users(id) ON DELETE SET NULL,
  ADD COLUMN IF NOT EXISTS lift_reason text        DEFAULT NULL;

-- Index for quickly finding active (not-yet-lifted) bans
CREATE INDEX IF NOT EXISTS idx_user_bans_lifted_at
  ON public.user_bans(lifted_at)
  WHERE lifted_at IS NULL;

COMMENT ON COLUMN public.user_bans.lifted_at   IS 'Timestamp when this ban was manually lifted by an admin. NULL = still active.';
COMMENT ON COLUMN public.user_bans.lifted_by   IS 'Admin user ID who lifted the ban.';
COMMENT ON COLUMN public.user_bans.lift_reason IS 'Admin-provided reason for lifting the ban early.';

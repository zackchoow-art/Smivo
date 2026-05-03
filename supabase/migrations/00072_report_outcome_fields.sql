-- Migration 00072: Report outcome fields for app-side display
-- Adds structured outcome fields to content_reports so the app can show:
--   1. Reporter: what action was taken against the offender + reward points
--   2. Reported user: whether they were penalised (warn/restrict only; dismiss is invisible)
--
-- These fields are written by admin hooks when resolving reports.

-- ─── 1. Add outcome fields to content_reports ──────────────────────────────

ALTER TABLE public.content_reports
  ADD COLUMN IF NOT EXISTS action_taken text
    CHECK (action_taken IN ('warn', 'restrict', 'none')),
  ADD COLUMN IF NOT EXISTS reporter_reward_points integer NOT NULL DEFAULT 0;

-- NOTE: action_taken = 'warn'     → reported user gets a warning
--       action_taken = 'restrict' → reported user gets an account restriction
--       action_taken = 'none'     → status=resolved but no penalty (edge case)
--       NULL                      → status is still pending/reviewed/dismissed

-- ─── 2. RLS: allow reported user to see their own penalty records ───────────
-- We only reveal records where the report was actioned (resolved + warn/restrict).
-- Dismissed reports are invisible to the reported user.

CREATE POLICY "Reported users can view penalties against them"
  ON public.content_reports FOR SELECT
  USING (
    auth.uid() = reported_user_id
    AND status = 'resolved'
    AND action_taken IN ('warn', 'restrict')
  );

-- ─── 3. Index for efficient lookup from the app ─────────────────────────────

CREATE INDEX IF NOT EXISTS idx_content_reports_reported_user_actioned
  ON public.content_reports (reported_user_id, status, action_taken)
  WHERE status = 'resolved' AND action_taken IN ('warn', 'restrict');

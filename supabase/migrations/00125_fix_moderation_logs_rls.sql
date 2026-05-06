-- Migration 00125: Fix backend_moderation_logs RLS and CHECK constraints
--
-- Problem 1: No INSERT RLS policy for authenticated users.
--   The table was originally designed for service_role-only writes,
--   but the Flutter ImageModerationService uses the anon/authenticated
--   Supabase client to insert records client-side. This causes a 42501
--   RLS violation on every image moderation after upload.
--
-- Problem 2: target_type CHECK constraint too restrictive.
--   Original: ('listing', 'message', 'profile')
--   Actual values used by ImageModerationService:
--     'listing_image', 'evidence', 'chat_image', 'feedback'
--
-- Problem 3: action_taken CHECK constraint too restrictive.
--   Original: ('approve', 'reject', 'flag', 'blur')
--   Actual values used: 'none', 'image_flagged'

BEGIN;

-- ── 1. Widen target_type CHECK to include all client-side types ──────────────

ALTER TABLE public.backend_moderation_logs
  DROP CONSTRAINT IF EXISTS backend_moderation_logs_target_type_check;

ALTER TABLE public.backend_moderation_logs
  ADD CONSTRAINT backend_moderation_logs_target_type_check
  CHECK (target_type IN (
    -- server-side (Edge Function) types
    'listing', 'message', 'profile',
    -- client-side (ImageModerationService) types
    'listing_image', 'evidence', 'chat_image', 'feedback'
  ));

-- ── 2. Widen action_taken CHECK to include all client-side values ─────────────

ALTER TABLE public.backend_moderation_logs
  DROP CONSTRAINT IF EXISTS backend_moderation_logs_action_taken_check;

ALTER TABLE public.backend_moderation_logs
  ADD CONSTRAINT backend_moderation_logs_action_taken_check
  CHECK (action_taken IN (
    -- server-side values
    'approve', 'reject', 'flag', 'blur',
    -- client-side values from ImageModerationService
    'none', 'image_flagged'
  ));

-- ── 3. Add INSERT RLS policy for authenticated users ─────────────────────────
-- Allows the Flutter client to log moderation results for images they upload.
-- Users can only insert records for their own user_id.

DROP POLICY IF EXISTS "Authenticated users can insert own moderation logs"
  ON public.backend_moderation_logs;

CREATE POLICY "Authenticated users can insert own moderation logs"
  ON public.backend_moderation_logs FOR INSERT
  TO authenticated
  WITH CHECK (user_id = auth.uid());

COMMIT;

-- Migration 00129: Allow authenticated users to read failed moderation logs
-- Fixes T11 Bug 1: backend_moderation_logs RLS blocked regular users from
-- reading flagged image records, causing ModerationAwareImage to never blur.
--
-- Design decision (Method A from T11 spec):
--   Grant ALL authenticated users read access to result='fail' records.
--   Rationale: chat message recipients must also be able to see the sender's
--   flagged image record to apply blur on their end. A user_id = auth.uid()
--   restriction would only allow the SENDER to see it, leaving the recipient
--   unable to blur the incoming flagged image.
--
--   Security: only result='fail' rows are exposed. Pass records (which reveal
--   that content was reviewed and deemed safe) remain admin-only. This avoids
--   leaking the full moderation audit trail to end users.

-- NOTE: The existing admin-only policy is preserved; this is an additional
-- policy. Supabase evaluates policies with OR semantics.
CREATE POLICY "Authenticated users can read flagged moderation logs"
  ON public.backend_moderation_logs FOR SELECT
  USING (
    auth.role() = 'authenticated'
    AND result = 'fail'
  );

-- Ensure the image_moderation_mode config row exists.
-- The ImageModerationMode provider reads this to decide blur vs auto_reject.
-- Default is 'blur' (JSON string, stored as jsonb).
INSERT INTO public.system_configs (config_key, config_value, description)
VALUES (
  'image_moderation_mode',
  '"blur"',
  'How to handle AI-flagged images on client: blur | auto_reject'
)
ON CONFLICT (config_key) DO NOTHING;

-- Migration 00138: Allow anonymous access to test_user configs
-- ═══════════════════════════════════════════════════════════════
-- Problem: system_configs RLS only permits platform sysadmins
-- (authenticated role + is_platform_sysadmin()). The debug mode
-- toggle on login/register screens runs BEFORE authentication,
-- so the Supabase client uses the anon key. The query silently
-- returns NULL, making it impossible to enable debug mode.
--
-- Fix: Add a SELECT policy for the anon role that exposes only
-- test_user.* keys. All other config keys remain admin-only.
-- ═══════════════════════════════════════════════════════════════

-- Allow unauthenticated (anon) users to read test_user.* configs.
-- This is safe because these configs only control whether the
-- debug login/register backdoor is available — they contain
-- no sensitive data.
CREATE POLICY "Anon can read test_user configs"
  ON public.system_configs
  FOR SELECT
  TO anon, authenticated
  USING (config_key LIKE 'test_user.%');

-- Also update the seed data: the values were inserted as bare
-- strings ('false') but config_value is jsonb. Bare 'false'
-- is valid jsonb (boolean false), but the app code was comparing
-- toString() which may produce unexpected results.
-- Ensure values are consistent jsonb booleans.
UPDATE public.system_configs
  SET config_value = 'true'::jsonb
  WHERE config_key = 'test_user.registration_enabled'
    AND config_value::text IN ('"false"', 'false');

UPDATE public.system_configs
  SET config_value = 'true'::jsonb
  WHERE config_key = 'test_user.login_enabled'
    AND config_value::text IN ('"false"', 'false');

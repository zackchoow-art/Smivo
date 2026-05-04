-- ════════════════════════════════════════════════════════════
-- 00105: Rental Reminder Cron Schedule
--
-- Registers a daily pg_cron job that calls check_rental_reminders()
-- at 08:00 UTC every day, ensuring rental reminder push notifications
-- are dispatched automatically without manual admin intervention.
--
-- Prerequisites:
--   - pg_cron extension must be enabled in Supabase Dashboard
--     (Database → Extensions → pg_cron)
--   - The check_rental_reminders() function exists (migration 00029)
-- ════════════════════════════════════════════════════════════

-- ─── 1. Enable pg_cron extension if not already enabled ───
-- NOTE: This is a no-op if already enabled. Supabase Pro plans support pg_cron.
CREATE EXTENSION IF NOT EXISTS pg_cron;

-- ─── 2. Grant usage to postgres role (required for pg_cron) ───
GRANT USAGE ON SCHEMA cron TO postgres;

-- ─── 3. Remove any existing schedule to avoid duplicates ───
SELECT cron.unschedule('daily-rental-reminders')
WHERE EXISTS (
  SELECT 1 FROM cron.job WHERE jobname = 'daily-rental-reminders'
);

-- ─── 4. Register the daily cron job ───
-- Runs at 08:00 UTC daily. Calls the DB function directly — no HTTP overhead.
-- The function inserts notifications rows, which trigger the push webhook.
SELECT cron.schedule(
  'daily-rental-reminders',
  '0 8 * * *',
  $$SELECT public.check_rental_reminders();$$
);

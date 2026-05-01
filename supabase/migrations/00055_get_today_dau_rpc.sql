-- Migration 00055: Create RPC function for today's DAU count
--
-- The hourly_active_users table stores raw heartbeat rows:
--   id, user_id, school_id, hour_bucket, platform, created_at
--
-- PostgREST cannot do COUNT(DISTINCT user_id), so we wrap it in an RPC.

CREATE OR REPLACE FUNCTION public.get_today_dau()
RETURNS bigint
LANGUAGE sql
SECURITY DEFINER
STABLE
SET search_path = public
AS $$
  SELECT COUNT(DISTINCT user_id)
  FROM public.hourly_active_users
  WHERE hour_bucket >= date_trunc('day', now() AT TIME ZONE 'UTC');
$$;

-- Grant execute to authenticated users (admin check is done at app level)
GRANT EXECUTE ON FUNCTION public.get_today_dau() TO authenticated;

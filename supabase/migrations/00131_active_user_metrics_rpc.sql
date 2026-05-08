-- Migration 00131: Enhanced active user metrics RPC (DAU, WAU, MAU)
--
-- Calculates rolling window active user counts:
--   DAU: Unique users in past 24 hours
--   WAU: Unique users in past 7 days
--   MAU: Unique users in past 30 days
--
-- Supports school-scoped filtering.

CREATE OR REPLACE FUNCTION public.get_active_user_metrics(p_school_id uuid DEFAULT NULL)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
STABLE
SET search_path = public
AS $$
DECLARE
  v_dau bigint;
  v_wau bigint;
  v_mau bigint;
BEGIN
  -- DAU (Past 24 hours)
  SELECT COUNT(DISTINCT user_id) INTO v_dau
  FROM public.hourly_active_users
  WHERE hour_bucket >= (now() - interval '24 hours')
    AND (p_school_id IS NULL OR school_id = p_school_id);

  -- WAU (Past 7 days)
  SELECT COUNT(DISTINCT user_id) INTO v_wau
  FROM public.hourly_active_users
  WHERE hour_bucket >= (now() - interval '7 days')
    AND (p_school_id IS NULL OR school_id = p_school_id);

  -- MAU (Past 30 days)
  SELECT COUNT(DISTINCT user_id) INTO v_mau
  FROM public.hourly_active_users
  WHERE hour_bucket >= (now() - interval '30 days')
    AND (p_school_id IS NULL OR school_id = p_school_id);

  RETURN jsonb_build_object(
    'dau', v_dau,
    'wau', v_wau,
    'mau', v_mau,
    'timestamp', now()
  );
END;
$$;

GRANT EXECUTE ON FUNCTION public.get_active_user_metrics(uuid) TO authenticated;

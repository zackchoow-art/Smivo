-- Migration 00137: Fix DAU metrics by adding trigger to heartbeats
-- Ensures analytics aggregate even when App writes directly to table.

CREATE OR REPLACE FUNCTION public.trg_sync_heartbeat_to_analytics()
RETURNS trigger AS $$
DECLARE
  v_bucket timestamptz := date_trunc('hour', NEW.last_seen_at);
  v_school_id uuid;
BEGIN
  -- Get user's school
  SELECT school_id INTO v_school_id
  FROM public.user_profiles WHERE id = NEW.user_id;

  IF v_school_id IS NOT NULL THEN
    INSERT INTO public.hourly_active_users (user_id, school_id, hour_bucket, platform)
    VALUES (NEW.user_id, v_school_id, v_bucket, NEW.platform)
    ON CONFLICT (user_id, hour_bucket) DO NOTHING;
  END IF;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Cleanup existing trigger if exists to avoid duplication
DROP TRIGGER IF EXISTS trg_heartbeat_analytics_sync ON public.user_heartbeats;

CREATE TRIGGER trg_heartbeat_analytics_sync
    AFTER INSERT OR UPDATE ON public.user_heartbeats
    FOR EACH ROW
    EXECUTE FUNCTION public.trg_sync_heartbeat_to_analytics();

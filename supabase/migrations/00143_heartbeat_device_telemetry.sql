ALTER TABLE public.user_heartbeats
  ADD COLUMN IF NOT EXISTS build_number text,
  ADD COLUMN IF NOT EXISTS device_model text,
  ADD COLUMN IF NOT EXISTS os_version text,
  ADD COLUMN IF NOT EXISTS ip_address inet,
  ADD COLUMN IF NOT EXISTS locale text;

COMMENT ON COLUMN public.user_heartbeats.app_version IS 'Semantic version e.g. 1.2.0';
COMMENT ON COLUMN public.user_heartbeats.build_number IS 'Build number e.g. 42';
COMMENT ON COLUMN public.user_heartbeats.device_model IS 'Device model e.g. iPhone 15 Pro, Pixel 8';
COMMENT ON COLUMN public.user_heartbeats.os_version IS 'OS + version e.g. iOS 17.4, Android 14';
COMMENT ON COLUMN public.user_heartbeats.ip_address IS 'Client IP from request headers';
COMMENT ON COLUMN public.user_heartbeats.locale IS 'Device locale e.g. en_US, zh_CN';

CREATE OR REPLACE FUNCTION public.capture_client_ip()
RETURNS trigger
LANGUAGE plpgsql
AS $$
BEGIN
  -- NOTE: inet_client_addr() returns the real client IP as seen by PostgreSQL.
  -- For Supabase, this is the PostgREST/API gateway IP, so we also check 
  -- the request header. If neither works, fall back to NULL.
  NEW.ip_address := COALESCE(
    (split_part(
      current_setting('request.headers', true)::json->>'x-forwarded-for',
      ',', 1
    )::text)::inet,
    inet_client_addr()
  );
  RETURN NEW;
END;
$$;

CREATE TRIGGER trg_capture_client_ip
  BEFORE INSERT OR UPDATE ON public.user_heartbeats
  FOR EACH ROW EXECUTE FUNCTION capture_client_ip();

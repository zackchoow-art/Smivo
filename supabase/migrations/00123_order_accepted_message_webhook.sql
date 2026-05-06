-- Migration 00123: Trigger webhook for order-accepted-message Edge Function
--
-- Creates a PostgreSQL AFTER UPDATE trigger on public.orders that fires
-- net.http_post to the order-accepted-message Edge Function whenever an
-- order's status changes to 'confirmed'.
--
-- Security model:
--   - The Edge Function was deployed with --no-verify-jwt, so any valid
--     JWT (including anon key) is accepted as the Authorization header.
--   - Inside the Edge Function, SUPABASE_SERVICE_ROLE_KEY (auto-injected
--     by the Supabase runtime) is used to bypass RLS for DB operations.
--   - This matches the same pattern used by webhook_call_moderate_content.
--
-- NOTE: The trigger fires on ALL status UPDATE events but includes an
-- early-exit guard (NEW.status = 'confirmed') to avoid HTTP calls for
-- unrelated updates. The Edge Function has a duplicate check for safety.

CREATE OR REPLACE FUNCTION public.trigger_order_accepted_message()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = ''
AS $$
DECLARE
  v_url text;
  v_key text;
  v_passphrase text;
  v_encrypted  text;
BEGIN
  -- Only fire when status transitions TO 'confirmed'.
  IF NEW.status IS DISTINCT FROM 'confirmed' OR OLD.status = 'confirmed' THEN
    RETURN NEW;
  END IF;

  -- Read the Supabase URL from platform_secrets (same as moderate-content webhook).
  v_passphrase := COALESCE(
    current_setting('app.secret_passphrase', true),
    'smivo-default-passphrase-change-in-production'
  );

  SELECT secret_value_encrypted INTO v_encrypted
  FROM public.platform_secrets
  WHERE secret_key = 'supabase_url';

  IF v_encrypted IS NOT NULL THEN
    v_url := extensions.pgp_sym_decrypt(v_encrypted::bytea, v_passphrase);
  ELSE
    -- Hardcoded fallback — matches the project URL.
    v_url := 'https://sztrbkfdcldwaifjkkol.supabase.co';
  END IF;

  -- Try service_role_key first; fall back to anon key.
  -- The Edge Function is deployed with --no-verify-jwt, so anon key works.
  -- The Edge Function itself uses SUPABASE_SERVICE_ROLE_KEY for DB access.
  SELECT secret_value_encrypted INTO v_encrypted
  FROM public.platform_secrets
  WHERE secret_key = 'supabase_service_role_key';

  IF v_encrypted IS NOT NULL THEN
    v_key := extensions.pgp_sym_decrypt(v_encrypted::bytea, v_passphrase);
  ELSE
    -- Fallback to anon key (safe because Edge Function uses its own service role key internally)
    v_key := 'sb_publishable_uF2gSam0yvMjVEswqwYWcA_i67ROBxj';
  END IF;

  -- Fire async HTTP POST (non-blocking via pg_net)
  PERFORM net.http_post(
    url     := v_url || '/functions/v1/order-accepted-message',
    body    := jsonb_build_object(
      'type',       'UPDATE',
      'record',     to_jsonb(NEW),
      'old_record', to_jsonb(OLD)
    ),
    headers := jsonb_build_object(
      'Content-Type',  'application/json',
      'Authorization', 'Bearer ' || v_key
    )
  );

  RETURN NEW;
END;
$$;

-- Attach trigger to orders table
DROP TRIGGER IF EXISTS on_order_confirmed_send_message ON public.orders;
CREATE TRIGGER on_order_confirmed_send_message
  AFTER UPDATE OF status ON public.orders
  FOR EACH ROW
  EXECUTE FUNCTION public.trigger_order_accepted_message();

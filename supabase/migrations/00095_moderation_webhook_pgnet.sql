-- ============================================================
-- Migration 00095: Database Webhook via pg_net
-- ============================================================
-- Configures a Postgres trigger on moderation_tasks that uses
-- pg_net to call the moderate-content Edge Function whenever
-- a new task is inserted.
--
-- pg_net sends an async HTTP POST, which is ideal for webhook
-- patterns — the trigger doesn't block on the response.
--
-- Authentication: Uses the Supabase anon key for the HTTP call.
-- The Edge Function itself uses SUPABASE_SERVICE_ROLE_KEY from
-- its own environment, so the caller's auth level is irrelevant
-- — the function is already privileged.
-- ============================================================

-- ═══════════════════════════════════════════════════════════════
-- 1. Store the Supabase URL in platform_secrets
-- ═══════════════════════════════════════════════════════════════

DO $$
DECLARE
  v_passphrase text;
  v_encrypted  text;
BEGIN
  v_passphrase := COALESCE(
    current_setting('app.secret_passphrase', true),
    'smivo-default-passphrase-change-in-production'
  );

  v_encrypted := pgp_sym_encrypt(
    'https://sztrbkfdcldwaifjkkol.supabase.co',
    v_passphrase
  );

  INSERT INTO public.platform_secrets (secret_key, secret_value_encrypted, description)
  VALUES ('supabase_url', v_encrypted, 'Supabase project URL for webhook calls')
  ON CONFLICT (secret_key)
  DO UPDATE SET
    secret_value_encrypted = EXCLUDED.secret_value_encrypted,
    description            = EXCLUDED.description,
    updated_at             = now();
END;
$$;

-- ═══════════════════════════════════════════════════════════════
-- 2. Trigger function: call moderate-content via pg_net
-- ═══════════════════════════════════════════════════════════════
-- NOTE: Uses the publishable anon key for the HTTP request.
-- This is safe because:
--   a) The Edge Function uses its own SUPABASE_SERVICE_ROLE_KEY internally
--   b) The Edge Function does NOT verify the caller's auth level
--   c) The anon key is already public (embedded in client apps)
--
-- If you want stricter auth, store the service_role_key in
-- platform_secrets with key 'supabase_service_role_key' and
-- update the Authorization header below to use it.

CREATE OR REPLACE FUNCTION public.webhook_call_moderate_content()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = ''
AS $$
DECLARE
  v_url        text;
  v_key        text;
  v_passphrase text;
  v_encrypted  text;
BEGIN
  -- Read the encryption passphrase
  v_passphrase := COALESCE(
    current_setting('app.secret_passphrase', true),
    'smivo-default-passphrase-change-in-production'
  );

  -- Decrypt Supabase URL
  SELECT secret_value_encrypted INTO v_encrypted
  FROM public.platform_secrets
  WHERE secret_key = 'supabase_url';

  IF v_encrypted IS NULL THEN
    RAISE WARNING '[webhook] supabase_url not found in platform_secrets — skipping';
    RETURN NEW;
  END IF;

  v_url := extensions.pgp_sym_decrypt(v_encrypted::bytea, v_passphrase);

  -- Try to use service_role_key if available; fallback to anon key
  SELECT secret_value_encrypted INTO v_encrypted
  FROM public.platform_secrets
  WHERE secret_key = 'supabase_service_role_key';

  IF v_encrypted IS NOT NULL THEN
    v_key := extensions.pgp_sym_decrypt(v_encrypted::bytea, v_passphrase);
  ELSE
    -- Fallback: use the publishable anon key (safe for internal webhook)
    v_key := 'sb_publishable_uF2gSam0yvMjVEswqwYWcA_i67ROBxj';
  END IF;

  -- Fire async HTTP POST to the Edge Function
  PERFORM net.http_post(
    url     := v_url || '/functions/v1/moderate-content',
    body    := jsonb_build_object(
      'record', jsonb_build_object(
        'id',          NEW.id,
        'target_type', NEW.target_type,
        'target_id',   NEW.target_id,
        'status',      NEW.status,
        'created_at',  NEW.created_at
      )
    ),
    headers := jsonb_build_object(
      'Content-Type',  'application/json',
      'Authorization', 'Bearer ' || v_key
    )
  );

  RETURN NEW;
END;
$$;

-- ═══════════════════════════════════════════════════════════════
-- 3. Attach trigger to moderation_tasks table
-- ═══════════════════════════════════════════════════════════════

DROP TRIGGER IF EXISTS on_moderation_task_webhook ON public.moderation_tasks;
CREATE TRIGGER on_moderation_task_webhook
  AFTER INSERT ON public.moderation_tasks
  FOR EACH ROW
  EXECUTE FUNCTION public.webhook_call_moderate_content();

NOTIFY pgrst, 'reload schema';

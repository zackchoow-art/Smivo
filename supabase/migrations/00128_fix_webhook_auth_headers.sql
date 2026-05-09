-- ============================================================
-- Migration 00128: Fix webhook authentication headers
-- ============================================================
-- ROOT CAUSE: Supabase's new API key format (sb_publishable_*)
-- is NOT a valid JWT. Edge Function relay rejects it with:
--   401 UNAUTHORIZED_INVALID_JWT_FORMAT
--
-- FIX: Add 'apikey' header alongside 'Authorization' for both
-- webhook functions. Combined with --no-verify-jwt deployment,
-- this ensures internal webhooks always authenticate correctly
-- regardless of key format.
--
-- Affected webhooks:
--   1. webhook_call_moderate_content (moderation_tasks INSERT)
--   2. trigger_order_accepted_message (orders status UPDATE)
-- ============================================================

BEGIN;

-- ═══════════════════════════════════════════════════════════════
-- 1. Fix moderate-content webhook
-- ═══════════════════════════════════════════════════════════════

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
    -- Fallback: use the publishable anon key
    v_key := 'sb_publishable_uF2gSam0yvMjVEswqwYWcA_i67ROBxj';
  END IF;

  -- Fire async HTTP POST to the Edge Function
  -- NOTE: Both 'apikey' and 'Authorization' headers are sent.
  -- 'apikey' works with non-JWT key formats (sb_publishable_*).
  -- 'Authorization' works when the key is a proper JWT.
  -- Combined with --no-verify-jwt deployment, this is belt-and-suspenders.
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
      'apikey',        v_key,
      'Authorization', 'Bearer ' || v_key
    )
  );

  RETURN NEW;
END;
$$;


-- ═══════════════════════════════════════════════════════════════
-- 2. Fix order-accepted-message webhook
-- ═══════════════════════════════════════════════════════════════

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
    v_url := 'https://sztrbkfdcldwaifjkkol.supabase.co';
  END IF;

  SELECT secret_value_encrypted INTO v_encrypted
  FROM public.platform_secrets
  WHERE secret_key = 'supabase_service_role_key';

  IF v_encrypted IS NOT NULL THEN
    v_key := extensions.pgp_sym_decrypt(v_encrypted::bytea, v_passphrase);
  ELSE
    v_key := 'sb_publishable_uF2gSam0yvMjVEswqwYWcA_i67ROBxj';
  END IF;

  -- Fire async HTTP POST (non-blocking via pg_net)
  -- NOTE: Same dual-header pattern as moderate-content webhook.
  PERFORM net.http_post(
    url     := v_url || '/functions/v1/order-accepted-message',
    body    := jsonb_build_object(
      'type',       'UPDATE',
      'record',     to_jsonb(NEW),
      'old_record', to_jsonb(OLD)
    ),
    headers := jsonb_build_object(
      'Content-Type',  'application/json',
      'apikey',        v_key,
      'Authorization', 'Bearer ' || v_key
    )
  );

  RETURN NEW;
END;
$$;

COMMIT;

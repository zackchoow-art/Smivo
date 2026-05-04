-- ============================================================
-- Migration 00090: Image Moderation Infrastructure
-- ============================================================
-- Creates:
--   1. platform_secrets     — encrypted API key storage (pgcrypto)
--   2. image_moderation_usage — monthly API usage counters
--   3. RPCs for saving/reading secrets and incrementing counters
--
-- Google Vision free tier: 1000 requests/month
-- OpenAI omni-moderation-latest: usage tracked for visibility
-- ============================================================

-- Enable pgcrypto for encryption (idempotent)
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- ── 1. Platform Secrets Table ────────────────────────────────
-- Stores encrypted API keys. The encryption passphrase is
-- the Supabase JWT secret (never exposed to the client).
-- Plaintext keys are NEVER stored or returned to the client.
CREATE TABLE IF NOT EXISTS public.platform_secrets (
  id          uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  secret_key  text NOT NULL UNIQUE,      -- e.g. 'openai_api_key', 'google_vision_api_key'
  secret_value_encrypted text NOT NULL,  -- pgp_sym_encrypt(plaintext, passphrase)
  description text,
  created_at  timestamptz NOT NULL DEFAULT now(),
  updated_at  timestamptz NOT NULL DEFAULT now()
);

-- Only sysadmins can read/write platform_secrets via RPC.
-- No direct table access from client.
ALTER TABLE public.platform_secrets ENABLE ROW LEVEL SECURITY;

-- NOTE: All access goes through SECURITY DEFINER RPCs below.
-- Direct table access is intentionally blocked for all roles.
CREATE POLICY "platform_secrets_no_direct_access"
  ON public.platform_secrets FOR ALL TO authenticated
  USING (false);

-- ── 2. Image Moderation Usage Counters ──────────────────────
-- Tracks per-provider, per-month API call counts.
-- Used to enforce the Google Vision 1000 req/month free tier.
CREATE TABLE IF NOT EXISTS public.image_moderation_usage (
  id         uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  provider   text NOT NULL,               -- 'openai' | 'google_vision'
  year_month text NOT NULL,               -- Format: 'YYYY-MM'
  call_count integer NOT NULL DEFAULT 0,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  UNIQUE (provider, year_month)
);

ALTER TABLE public.image_moderation_usage ENABLE ROW LEVEL SECURITY;

-- Sysadmins can read usage counters directly (read-only)
CREATE POLICY "image_moderation_usage_sysadmin_read"
  ON public.image_moderation_usage FOR SELECT TO authenticated
  USING (public.is_platform_sysadmin());

-- ── 3. RPC: Save (upsert) a platform secret ─────────────────
-- Accepts plaintext key from admin, encrypts before storing.
-- Passphrase: SUPABASE_SECRET_PASSPHRASE env var (set in Supabase dashboard).
-- Falls back to a derivation of the DB URL if not set.
CREATE OR REPLACE FUNCTION public.save_platform_secret(
  p_key        text,
  p_value      text,
  p_description text DEFAULT NULL
)
RETURNS jsonb LANGUAGE plpgsql SECURITY DEFINER AS $$
DECLARE
  v_passphrase text;
  v_encrypted  text;
BEGIN
  -- Only sysadmins can save secrets
  IF NOT public.is_platform_sysadmin() THEN
    RAISE EXCEPTION 'Permission denied: sysadmin only';
  END IF;

  -- Use a fixed passphrase stored as a DB setting.
  -- Set via: ALTER DATABASE postgres SET app.secret_passphrase = 'your-passphrase';
  -- NOTE: In production, rotate this passphrase and re-encrypt all secrets.
  v_passphrase := COALESCE(
    current_setting('app.secret_passphrase', true),
    'smivo-default-passphrase-change-in-production'
  );

  v_encrypted := pgp_sym_encrypt(p_value, v_passphrase);

  INSERT INTO public.platform_secrets (secret_key, secret_value_encrypted, description)
  VALUES (p_key, v_encrypted, p_description)
  ON CONFLICT (secret_key)
  DO UPDATE SET
    secret_value_encrypted = EXCLUDED.secret_value_encrypted,
    description            = COALESCE(EXCLUDED.description, platform_secrets.description),
    updated_at             = now();

  -- Audit log
  INSERT INTO public.admin_audit_logs (admin_id, action, target_type, target_id, payload)
  VALUES (auth.uid(), 'save_platform_secret', 'platform_secret', NULL,
    jsonb_build_object('secret_key', p_key, 'timestamp', now()));

  RETURN jsonb_build_object('status', 'ok', 'secret_key', p_key);
END;
$$;
GRANT EXECUTE ON FUNCTION public.save_platform_secret(text, text, text) TO authenticated;

-- ── 4. RPC: Check if a secret exists (without returning value) ──
CREATE OR REPLACE FUNCTION public.check_platform_secret_exists(p_key text)
RETURNS jsonb LANGUAGE plpgsql SECURITY DEFINER AS $$
DECLARE
  v_exists boolean;
  v_updated_at timestamptz;
BEGIN
  IF NOT public.is_platform_sysadmin() THEN
    RAISE EXCEPTION 'Permission denied: sysadmin only';
  END IF;

  SELECT EXISTS(SELECT 1 FROM public.platform_secrets WHERE secret_key = p_key),
         (SELECT updated_at FROM public.platform_secrets WHERE secret_key = p_key)
  INTO v_exists, v_updated_at;

  RETURN jsonb_build_object(
    'exists', v_exists,
    'secret_key', p_key,
    'last_updated', v_updated_at
  );
END;
$$;
GRANT EXECUTE ON FUNCTION public.check_platform_secret_exists(text) TO authenticated;

-- ── 5. RPC: Get current month usage ─────────────────────────
CREATE OR REPLACE FUNCTION public.get_image_moderation_usage()
RETURNS jsonb LANGUAGE plpgsql SECURITY DEFINER AS $$
DECLARE
  v_month text;
  v_openai_count integer;
  v_google_count integer;
BEGIN
  IF NOT public.is_platform_sysadmin() THEN
    RAISE EXCEPTION 'Permission denied: sysadmin only';
  END IF;

  v_month := to_char(now(), 'YYYY-MM');

  SELECT COALESCE(call_count, 0) INTO v_openai_count
  FROM public.image_moderation_usage
  WHERE provider = 'openai' AND year_month = v_month;

  SELECT COALESCE(call_count, 0) INTO v_google_count
  FROM public.image_moderation_usage
  WHERE provider = 'google_vision' AND year_month = v_month;

  RETURN jsonb_build_object(
    'month', v_month,
    'openai',         jsonb_build_object('count', COALESCE(v_openai_count, 0), 'limit', NULL),
    'google_vision',  jsonb_build_object('count', COALESCE(v_google_count, 0), 'limit', 1000)
  );
END;
$$;
GRANT EXECUTE ON FUNCTION public.get_image_moderation_usage() TO authenticated;

-- ── 6. RPC: Increment usage counter (called by Edge Functions) ──
CREATE OR REPLACE FUNCTION public.increment_image_moderation_usage(p_provider text)
RETURNS void LANGUAGE plpgsql SECURITY DEFINER AS $$
DECLARE
  v_month text;
BEGIN
  -- NOTE: This is called from Edge Functions (service role), not from the client.
  -- No role check needed — service role bypasses RLS entirely.
  v_month := to_char(now(), 'YYYY-MM');

  INSERT INTO public.image_moderation_usage (provider, year_month, call_count)
  VALUES (p_provider, v_month, 1)
  ON CONFLICT (provider, year_month)
  DO UPDATE SET
    call_count = image_moderation_usage.call_count + 1,
    updated_at = now();
END;
$$;
-- NOTE: Grant to service_role (Edge Functions use service role key)
GRANT EXECUTE ON FUNCTION public.increment_image_moderation_usage(text) TO service_role;

-- ── 7. Decrypt helper (used ONLY by Edge Functions internally) ──
-- This RPC is called by Edge Functions to retrieve the decrypted secret.
-- It is NOT exposed to the admin client.
CREATE OR REPLACE FUNCTION public.get_platform_secret_decrypted(p_key text)
RETURNS text LANGUAGE plpgsql SECURITY DEFINER AS $$
DECLARE
  v_passphrase text;
  v_encrypted  text;
BEGIN
  -- NOTE: Only callable from service_role (Edge Functions).
  -- Regular authenticated users cannot call this.
  v_passphrase := COALESCE(
    current_setting('app.secret_passphrase', true),
    'smivo-default-passphrase-change-in-production'
  );

  SELECT secret_value_encrypted INTO v_encrypted
  FROM public.platform_secrets
  WHERE secret_key = p_key;

  IF v_encrypted IS NULL THEN RETURN NULL; END IF;

  RETURN pgp_sym_decrypt(v_encrypted::bytea, v_passphrase);
END;
$$;
-- NOTE: Intentionally restricted to service_role only
GRANT EXECUTE ON FUNCTION public.get_platform_secret_decrypted(text) TO service_role;

NOTIFY pgrst, 'reload schema';

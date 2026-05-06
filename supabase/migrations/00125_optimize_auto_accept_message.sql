-- Migration 00125: Optimize Auto Accept Message
-- 1. Move the configuration to system_settings (Feature Flags)
-- 2. Set default value to true

-- NOTE: Must cast to ::jsonb to store as JSON boolean (true), not JSON string ("true").
-- A bare 'true' string would be stored as jsonb string "true", which evaluates differently
-- in Edge Function boolean checks and causes the feature to appear disabled.
INSERT INTO public.system_settings (key, value, description)
VALUES (
  'auto_accept_message_enabled',
  'true'::jsonb,
  'When enabled, automatically sends a platform message to the buyer chat room when a seller accepts an offer.'
)
ON CONFLICT (key) DO UPDATE SET value = 'true'::jsonb;

-- Remove from old system_configs table
DELETE FROM public.system_configs WHERE config_key = 'auto_accept_message_enabled';

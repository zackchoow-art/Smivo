-- Migration 00122: Add auto_accept_message_enabled system config
--
-- Controls whether the order-accepted-message Edge Function sends an
-- automatic platform message to the buyer when their offer is accepted.
-- Default: false (disabled) — admin can enable from Settings > System.

INSERT INTO public.system_configs (config_key, config_value, description)
VALUES (
  'auto_accept_message_enabled',
  'false',
  'When true, automatically sends a platform message to the buyer chat room when a seller accepts an offer.'
)
ON CONFLICT (config_key) DO NOTHING;

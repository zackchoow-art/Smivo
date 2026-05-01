-- Migration 00058: Default content filter and backend review configs.
-- These keys are read by Flutter app (client-side filtering) and
-- moderate-content Edge Function (server-side review) respectively.
-- NOTE: config_value is jsonb, so string values must be JSON-quoted.

INSERT INTO public.system_configs (config_key, config_value, description)
VALUES
  ('content_filter.enabled', 'true'::jsonb, 'Enable/disable client-side content filtering in Flutter app'),
  ('content_filter.warn_action', '"show_warning"'::jsonb, 'Action for warn-severity words: show_warning | silent'),
  ('content_filter.block_action', '"reject"'::jsonb, 'Action for block-severity words: reject | mask | warn_only'),
  ('backend_review.enabled', 'false'::jsonb, 'Enable/disable server-side content review via Edge Function'),
  ('backend_review.mode', '"sensitive_words"'::jsonb, 'Review method: sensitive_words | ai | both')
ON CONFLICT (config_key) DO NOTHING;

-- Migration 00067: Add warn_message config for client-side content filter.
-- This message is shown to the sender when their message contains a
-- warn-severity sensitive word. The message is sent successfully, but the
-- user receives a gentle reminder to keep conversations respectful.
-- NOTE: config_value is jsonb, so strings must be JSON-quoted.

INSERT INTO public.system_configs (config_key, config_value, description)
VALUES (
  'content_filter.warn_message',
  '"Please keep the conversation respectful. Messages with inappropriate language may be reported by the other party."'::jsonb,
  'Warning message shown to the sender when their message contains warn-severity words'
)
ON CONFLICT (config_key) DO NOTHING;

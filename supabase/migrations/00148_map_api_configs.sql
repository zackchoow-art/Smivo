-- Migration 00148: Insert map API key configs (jsonb format)

INSERT INTO public.system_configs (config_key, config_value, description)
VALUES
  ('apple_maps_token', '""', 'Apple MapKit JS token (for web fallback if needed)'),
  ('google_maps_places_api_key', '""', 'Google Places API key (future use)'),
  ('google_maps_directions_api_key', '""', 'Google Directions API key (future use)')
ON CONFLICT (config_key) DO NOTHING;

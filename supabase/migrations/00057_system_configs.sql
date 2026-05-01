-- Migration 00057: System Configs Table
-- Creates a generic key-value store for global system configurations.

CREATE TABLE IF NOT EXISTS public.system_configs (
    config_key text PRIMARY KEY,
    config_value jsonb NOT NULL,
    description text,
    updated_at timestamptz DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- Enable RLS
ALTER TABLE public.system_configs ENABLE ROW LEVEL SECURITY;

-- Policies: Only platform admins can read and write system configs.
-- Edge Functions bypass RLS automatically using the Service Role Key.
CREATE POLICY "Admins can manage system configs"
    ON public.system_configs
    FOR ALL
    TO authenticated
    USING (public.is_platform_sysadmin());

-- Trigger for updated_at
CREATE TRIGGER handle_system_configs_updated_at
    BEFORE UPDATE ON public.system_configs
    FOR EACH ROW
    EXECUTE FUNCTION public.handle_updated_at();

-- Seed initial AI moderation configurations
INSERT INTO public.system_configs (config_key, config_value, description)
VALUES 
  ('ai_moderation_enabled', 'false', 'Enable AI secondary review for listings'),
  ('ai_provider', '"openai"', 'AI provider to use (openai, google)'),
  ('ai_action_on_hit', '"flag"', 'Action to take when AI flags content (flag, reject)')
ON CONFLICT (config_key) DO NOTHING;

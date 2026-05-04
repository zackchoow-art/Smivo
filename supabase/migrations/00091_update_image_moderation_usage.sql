-- Migration 00091: Update Image Moderation Usage RPC to support variable amounts

CREATE OR REPLACE FUNCTION public.increment_image_moderation_usage(p_provider text, p_amount integer DEFAULT 1)
RETURNS void LANGUAGE plpgsql SECURITY DEFINER AS $$
DECLARE
  v_month text;
BEGIN
  -- NOTE: This is called from Edge Functions (service role), not from the client.
  -- No role check needed — service role bypasses RLS entirely.
  v_month := to_char(now(), 'YYYY-MM');

  INSERT INTO public.image_moderation_usage (provider, year_month, call_count)
  VALUES (p_provider, v_month, p_amount)
  ON CONFLICT (provider, year_month)
  DO UPDATE SET
    call_count = image_moderation_usage.call_count + p_amount,
    updated_at = now();
END;
$$;

-- NOTE: Grant to service_role (Edge Functions use service role key)
GRANT EXECUTE ON FUNCTION public.increment_image_moderation_usage(text, integer) TO service_role;

NOTIFY pgrst, 'reload schema';

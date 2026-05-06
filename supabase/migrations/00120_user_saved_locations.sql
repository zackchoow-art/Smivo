-- Migration 00120: User saved locations (custom pickup addresses)
--
-- Enables users to save, retrieve, and delete custom pickup addresses
-- tied to their account. Used in Create/Edit Listing when "Other" is selected.

-- ── 1. Table ──────────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS public.user_saved_locations (
  id          uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id     uuid NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  label       text NOT NULL,              -- The custom address string
  use_count   int  NOT NULL DEFAULT 1,    -- Times this address was used (MRU sort)
  last_used_at timestamptz NOT NULL DEFAULT now(),
  created_at  timestamptz NOT NULL DEFAULT now(),
  updated_at  timestamptz NOT NULL DEFAULT now()
);

-- Index for fast per-user ordered fetch
CREATE INDEX IF NOT EXISTS idx_user_saved_locations_user
  ON public.user_saved_locations (user_id, last_used_at DESC);

-- ── 2. Trigger: keep updated_at current ───────────────────────────────────────
CREATE OR REPLACE FUNCTION public.touch_user_saved_locations_updated_at()
RETURNS TRIGGER LANGUAGE plpgsql AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS trg_user_saved_locations_updated_at
  ON public.user_saved_locations;

CREATE TRIGGER trg_user_saved_locations_updated_at
  BEFORE UPDATE ON public.user_saved_locations
  FOR EACH ROW EXECUTE FUNCTION public.touch_user_saved_locations_updated_at();

-- ── 3. RLS ────────────────────────────────────────────────────────────────────
ALTER TABLE public.user_saved_locations ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can read own saved locations"
  ON public.user_saved_locations FOR SELECT
  TO authenticated
  USING (user_id = auth.uid());

CREATE POLICY "Users can insert own saved locations"
  ON public.user_saved_locations FOR INSERT
  TO authenticated
  WITH CHECK (user_id = auth.uid());

CREATE POLICY "Users can update own saved locations"
  ON public.user_saved_locations FOR UPDATE
  TO authenticated
  USING (user_id = auth.uid())
  WITH CHECK (user_id = auth.uid());

CREATE POLICY "Users can delete own saved locations"
  ON public.user_saved_locations FOR DELETE
  TO authenticated
  USING (user_id = auth.uid());

-- ── 4. RPC: upsert a location by label (increment use_count + update last_used) ──
CREATE OR REPLACE FUNCTION public.upsert_user_saved_location(
  p_user_id uuid,
  p_label   text
)
RETURNS uuid
LANGUAGE plpgsql
SECURITY INVOKER
AS $$
DECLARE
  v_id uuid;
BEGIN
  -- Check if an identical label already exists for this user
  SELECT id INTO v_id
  FROM public.user_saved_locations
  WHERE user_id = p_user_id AND label = p_label
  LIMIT 1;

  IF v_id IS NOT NULL THEN
    -- Increment use count and refresh last_used_at
    UPDATE public.user_saved_locations
    SET use_count    = use_count + 1,
        last_used_at = now(),
        updated_at   = now()
    WHERE id = v_id;
  ELSE
    -- Insert new location
    INSERT INTO public.user_saved_locations (user_id, label)
    VALUES (p_user_id, p_label)
    RETURNING id INTO v_id;
  END IF;

  RETURN v_id;
END;
$$;

GRANT EXECUTE ON FUNCTION public.upsert_user_saved_location(uuid, text)
  TO authenticated;

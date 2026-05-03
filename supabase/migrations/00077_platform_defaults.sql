-- ============================================================
-- Smivo — Platform Default Categories & Conditions
-- Migration 00077
-- ============================================================
-- Strategy: Two separate "template" tables hold platform-level
-- defaults. Schools can import them via RPC. Imported records
-- are flagged with is_imported_default = true so the UI can
-- show them as locked for school admins.
--
-- No Flutter app changes required — school_categories and
-- school_conditions still serve as the source of truth.
-- ============================================================


-- ─── 1. Platform template tables ──────────────────────────────

CREATE TABLE IF NOT EXISTS public.platform_category_defaults (
  id            uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  slug          text NOT NULL UNIQUE,
  name          text NOT NULL,
  icon          text,
  display_order integer NOT NULL DEFAULT 0,
  is_active     boolean NOT NULL DEFAULT true,
  created_at    timestamptz NOT NULL DEFAULT now(),
  updated_at    timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS public.platform_condition_defaults (
  id            uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  slug          text NOT NULL UNIQUE,
  name          text NOT NULL,
  description   text,
  display_order integer NOT NULL DEFAULT 0,
  is_active     boolean NOT NULL DEFAULT true,
  created_at    timestamptz NOT NULL DEFAULT now(),
  updated_at    timestamptz NOT NULL DEFAULT now()
);

-- Trigger updated_at
CREATE TRIGGER platform_category_defaults_updated_at
  BEFORE UPDATE ON public.platform_category_defaults
  FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();

CREATE TRIGGER platform_condition_defaults_updated_at
  BEFORE UPDATE ON public.platform_condition_defaults
  FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();


-- ─── 2. RLS for template tables ───────────────────────────────

ALTER TABLE public.platform_category_defaults ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.platform_condition_defaults ENABLE ROW LEVEL SECURITY;

-- Anyone (including guest app) can read platform defaults
CREATE POLICY "Platform category defaults are publicly readable"
  ON public.platform_category_defaults FOR SELECT USING (true);

CREATE POLICY "Platform condition defaults are publicly readable"
  ON public.platform_condition_defaults FOR SELECT USING (true);

-- Only platform admins can write to the template tables
CREATE POLICY "Platform admins can manage category defaults"
  ON public.platform_category_defaults FOR ALL
  USING (
    EXISTS (
      SELECT 1 FROM public.user_profiles
      WHERE id = auth.uid() AND is_admin = true
    )
  );

CREATE POLICY "Platform admins can manage condition defaults"
  ON public.platform_condition_defaults FOR ALL
  USING (
    EXISTS (
      SELECT 1 FROM public.user_profiles
      WHERE id = auth.uid() AND is_admin = true
    )
  );


-- ─── 3. Add is_imported_default flag to school tables ─────────

-- NOTE: Tracks whether a school record was seeded from the
-- platform template. When true, school admins cannot edit or
-- delete it; only platform super admins can override.
ALTER TABLE public.school_categories
  ADD COLUMN IF NOT EXISTS is_imported_default boolean NOT NULL DEFAULT false;

ALTER TABLE public.school_conditions
  ADD COLUMN IF NOT EXISTS is_imported_default boolean NOT NULL DEFAULT false;


-- ─── 4. Seed platform defaults from existing Smith College data ─

-- NOTE: Smith College was the pilot school; its data is the
-- canonical baseline for platform defaults. We deduplicate
-- by slug, so re-running this migration is safe.
INSERT INTO public.platform_category_defaults (slug, name, icon, display_order)
SELECT DISTINCT ON (sc.slug)
  sc.slug, sc.name, sc.icon, sc.display_order
FROM public.school_categories sc
JOIN public.schools s ON s.id = sc.school_id
WHERE s.slug = 'smith'
ORDER BY sc.slug, sc.display_order
ON CONFLICT (slug) DO NOTHING;

INSERT INTO public.platform_condition_defaults (slug, name, description, display_order)
SELECT DISTINCT ON (sc.slug)
  sc.slug, sc.name, sc.description, sc.display_order
FROM public.school_conditions sc
JOIN public.schools s ON s.id = sc.school_id
WHERE s.slug = 'smith'
ORDER BY sc.slug, sc.display_order
ON CONFLICT (slug) DO NOTHING;


-- ─── 5. Mark existing school records as imported defaults ──────

-- All existing school_categories rows whose slug matches a
-- platform default are retroactively marked as imported.
UPDATE public.school_categories sc
SET is_imported_default = true
WHERE EXISTS (
  SELECT 1 FROM public.platform_category_defaults pcd
  WHERE pcd.slug = sc.slug
);

UPDATE public.school_conditions sc
SET is_imported_default = true
WHERE EXISTS (
  SELECT 1 FROM public.platform_condition_defaults pcd
  WHERE pcd.slug = sc.slug
);


-- ─── 6. RPC: import_platform_defaults ─────────────────────────

-- Called by the admin UI "Import Base Items" button.
-- Copies all active platform defaults into a school,
-- skipping slugs that already exist (idempotent).
-- Returns counts so the UI can show a meaningful message.
CREATE OR REPLACE FUNCTION public.import_platform_defaults(p_school_id uuid)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_cat_count  int := 0;
  v_con_count  int := 0;
BEGIN
  -- Categories: insert only slugs not yet present in this school
  INSERT INTO public.school_categories
    (school_id, slug, name, icon, display_order, is_active, is_imported_default)
  SELECT
    p_school_id, pcd.slug, pcd.name, pcd.icon, pcd.display_order, pcd.is_active, true
  FROM public.platform_category_defaults pcd
  WHERE pcd.is_active = true
    AND NOT EXISTS (
      SELECT 1 FROM public.school_categories sc
      WHERE sc.school_id = p_school_id AND sc.slug = pcd.slug
    );
  GET DIAGNOSTICS v_cat_count = ROW_COUNT;

  -- Conditions: insert only slugs not yet present in this school
  INSERT INTO public.school_conditions
    (school_id, slug, name, description, display_order, is_active, is_imported_default)
  SELECT
    p_school_id, pcd.slug, pcd.name, pcd.description, pcd.display_order, pcd.is_active, true
  FROM public.platform_condition_defaults pcd
  WHERE pcd.is_active = true
    AND NOT EXISTS (
      SELECT 1 FROM public.school_conditions sc
      WHERE sc.school_id = p_school_id AND sc.slug = pcd.slug
    );
  GET DIAGNOSTICS v_con_count = ROW_COUNT;

  RETURN jsonb_build_object(
    'categories_imported', v_cat_count,
    'conditions_imported', v_con_count
  );
END;
$$;

-- Grant execute to authenticated users (RLS + SECURITY DEFINER handle auth)
GRANT EXECUTE ON FUNCTION public.import_platform_defaults(uuid) TO authenticated;


-- ─── 7. Update seed_school_defaults RPC ───────────────────────

-- Update the RPC used when onboarding a new school to reference
-- platform_category_defaults and platform_condition_defaults,
-- so new schools automatically get whatever the platform defines.
CREATE OR REPLACE FUNCTION public.seed_school_defaults(p_school_id uuid)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  -- Categories from platform template (is_imported_default = true)
  INSERT INTO public.school_categories
    (school_id, slug, name, icon, display_order, is_active, is_imported_default)
  SELECT
    p_school_id, slug, name, icon, display_order, is_active, true
  FROM public.platform_category_defaults
  WHERE is_active = true
  ON CONFLICT (school_id, slug) DO NOTHING;

  -- Conditions from platform template (is_imported_default = true)
  INSERT INTO public.school_conditions
    (school_id, slug, name, description, display_order, is_active, is_imported_default)
  SELECT
    p_school_id, slug, name, description, display_order, is_active, true
  FROM public.platform_condition_defaults
  WHERE is_active = true
  ON CONFLICT (school_id, slug) DO NOTHING;

  -- Pickup locations: keep hardcoded for now
  INSERT INTO public.pickup_locations (school_id, name, display_order)
  VALUES
    (p_school_id, 'Campus Center',           1),
    (p_school_id, 'Main Library',            2),
    (p_school_id, 'Student Union',           3),
    (p_school_id, 'Other (specify in chat)', 99);

  -- Copy global FAQs as school-specific
  INSERT INTO public.faqs (school_id, category, question, answer, display_order)
  SELECT p_school_id, category, question, answer, display_order
  FROM public.faqs
  WHERE school_id IS NULL;
END;
$$;

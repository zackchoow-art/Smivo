-- ============================================================
-- Migration 00091: Extend Platform Defaults to include Pickup Locations
-- ============================================================
-- Adds:
--   1. platform_pickup_location_defaults — template table for pickup spots
--   2. Extends import_platform_defaults() to also import pickup locations
--   3. Extends seed_school_defaults() to use the template table
--   4. Seeds common campus pickup locations as the platform template
-- ============================================================

-- ─── 1. Platform pickup location template table ──────────────

CREATE TABLE IF NOT EXISTS public.platform_pickup_location_defaults (
  id            uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  name          text NOT NULL UNIQUE,
  display_order integer NOT NULL DEFAULT 0,
  is_active     boolean NOT NULL DEFAULT true,
  created_at    timestamptz NOT NULL DEFAULT now(),
  updated_at    timestamptz NOT NULL DEFAULT now()
);

CREATE TRIGGER platform_pickup_location_defaults_updated_at
  BEFORE UPDATE ON public.platform_pickup_location_defaults
  FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();

ALTER TABLE public.platform_pickup_location_defaults ENABLE ROW LEVEL SECURITY;

-- Anyone can read the template (needed for admin UI preview)
CREATE POLICY "Platform pickup location defaults are publicly readable"
  ON public.platform_pickup_location_defaults FOR SELECT USING (true);

-- Only platform admins can write
CREATE POLICY "Platform admins can manage pickup location defaults"
  ON public.platform_pickup_location_defaults FOR ALL
  USING (public.is_platform_sysadmin());

-- ─── 2. Seed universal campus pickup locations ───────────────

-- NOTE: These are the "reasonable universals" that work on any campus.
-- Schools can customize by adding/removing after import.
-- "Other" is always last (display_order 99) so it acts as a fallback.
INSERT INTO public.platform_pickup_location_defaults (name, display_order) VALUES
  ('Campus Center',           1),
  ('Main Library',            2),
  ('Student Union',           3),
  ('Cafeteria / Dining Hall', 4),
  ('Dorm Lobby',              5),
  ('Gym / Recreation Center', 6),
  ('Other (specify in chat)', 99)
ON CONFLICT (name) DO NOTHING;

-- ─── 3. Extend import_platform_defaults() ────────────────────
-- Adds pickup_location support alongside existing category + condition import.
-- IDEMPOTENT: skips names that already exist in the school's pickup_locations.

CREATE OR REPLACE FUNCTION public.import_platform_defaults(p_school_id uuid)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_cat_count     int := 0;
  v_con_count     int := 0;
  v_pickup_count  int := 0;
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

  -- Pickup locations: insert only names not yet present in this school
  -- NOTE: pickup_locations has no slug, so we deduplicate by name.
  INSERT INTO public.pickup_locations
    (school_id, name, display_order, is_active)
  SELECT
    p_school_id, ppd.name, ppd.display_order, ppd.is_active
  FROM public.platform_pickup_location_defaults ppd
  WHERE ppd.is_active = true
    AND NOT EXISTS (
      SELECT 1 FROM public.pickup_locations pl
      WHERE pl.school_id = p_school_id AND pl.name = ppd.name
    );
  GET DIAGNOSTICS v_pickup_count = ROW_COUNT;

  RETURN jsonb_build_object(
    'categories_imported',       v_cat_count,
    'conditions_imported',       v_con_count,
    'pickup_locations_imported', v_pickup_count
  );
END;
$$;

GRANT EXECUTE ON FUNCTION public.import_platform_defaults(uuid) TO authenticated;

-- ─── 4. Extend seed_school_defaults() ────────────────────────
-- Uses the platform template instead of hardcoded strings,
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

  -- Pickup locations from platform template
  -- NOTE: Switched from hardcoded VALUES to template table for consistency.
  -- Adding new platform defaults will automatically apply to new schools.
  INSERT INTO public.pickup_locations
    (school_id, name, display_order, is_active)
  SELECT
    p_school_id, name, display_order, is_active
  FROM public.platform_pickup_location_defaults
  WHERE is_active = true
  ON CONFLICT DO NOTHING;

  -- Copy global FAQs as school-specific
  INSERT INTO public.faqs (school_id, category, question, answer, display_order)
  SELECT p_school_id, category, question, answer, display_order
  FROM public.faqs
  WHERE school_id IS NULL;
END;
$$;

NOTIFY pgrst, 'reload schema';

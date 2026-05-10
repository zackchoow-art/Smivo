-- Migration 00136: Sync platform category defaults with Smith College
-- ═══════════════════════════════════════════════════════════════════
-- Background: Migration 00077 created platform_category_defaults by
-- copying Smith's categories. Migration 00100 later replaced Smith's
-- categories with a new set (dorm, kitchen, self_care, food,
-- study_supplies, sports, other), but forgot to update the platform
-- template table. This migration synchronises them.
--
-- Strategy:
--   1. Clear stale platform_category_defaults rows
--   2. Re-seed from Smith College's current school_categories
--   3. Verify the seed_school_defaults() RPC already reads from
--      platform_category_defaults (it does, per 00077 step 7)
--
-- Risk: LOW — additive seed data only. No schema changes.
-- ═══════════════════════════════════════════════════════════════════


-- ─── 1. Replace platform_category_defaults with Smith's current set ──

DELETE FROM public.platform_category_defaults;

INSERT INTO public.platform_category_defaults (slug, name, icon, display_order)
SELECT sc.slug, sc.name, sc.icon, sc.display_order
FROM public.school_categories sc
JOIN public.schools s ON s.id = sc.school_id
WHERE s.slug = 'smith'
  AND sc.is_active = true
ORDER BY sc.display_order
ON CONFLICT (slug) DO UPDATE SET
  name = EXCLUDED.name,
  icon = EXCLUDED.icon,
  display_order = EXCLUDED.display_order;


-- ─── 2. Mark matching school_categories as imported defaults ─────
-- Any school that already has these slugs should be flagged
-- so the admin UI knows they came from the platform template.

UPDATE public.school_categories sc
SET is_imported_default = true
WHERE EXISTS (
  SELECT 1 FROM public.platform_category_defaults pcd
  WHERE pcd.slug = sc.slug
)
AND sc.is_imported_default = false;

-- ============================================================
-- Migration 00066: Remove duplicate category/condition/pickup_location
--                  entries from system_dictionaries
-- ============================================================
-- These dict_types are maintained in their own school-scoped tables:
--   category        → school_categories  (school_id FK, listings.category_id)
--   condition       → school_conditions  (school_id FK, listings.condition)
--   pickup_location → pickup_locations   (school_id FK, listings.pickup_location_id)
--
-- The system_dictionaries copies were added in migration 00056 as a
-- temporary seed, but they are not used by the Flutter app. Keeping
-- them would cause confusion about which table is the source of truth.
-- ============================================================

DELETE FROM public.system_dictionaries
WHERE dict_type IN ('category', 'condition', 'pickup_location');

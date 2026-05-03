-- ============================================================
-- Migration 00065: Add access_level to system_dictionaries
-- ============================================================
-- Introduces a three-tier permission model for dictionary entries:
--   system   → only platform_super_admin can modify
--   platform → platform moderator or above can modify
--   school   → school_admin can modify; platform roles can only view
-- ============================================================

-- ── 1. Add access_level column ──────────────────────────────

ALTER TABLE public.system_dictionaries
  ADD COLUMN IF NOT EXISTS access_level text NOT NULL DEFAULT 'platform'
    CHECK (access_level IN ('system', 'platform', 'school'));

-- ── 2. Classify existing dict_types ─────────────────────────

-- System-level: core business state machine — only super admin may edit
UPDATE public.system_dictionaries
SET access_level = 'system'
WHERE dict_type IN ('order_status', 'rental_status', 'listing_status', 'transaction_type');

-- Platform-level: operational configuration — platform moderator may edit
UPDATE public.system_dictionaries
SET access_level = 'platform'
WHERE dict_type IN ('notification_type', 'review_tag', 'feedback_resolution', 'system_url');

-- School-level: campus-specific configuration — school admin maintains
UPDATE public.system_dictionaries
SET access_level = 'school'
WHERE dict_type IN ('category', 'condition', 'pickup_location');

-- ── 3. Index for common query pattern ───────────────────────
-- Admin pages frequently filter by access_level to show grouped views.

CREATE INDEX IF NOT EXISTS idx_system_dict_access_level
  ON public.system_dictionaries(access_level, dict_type, display_order);

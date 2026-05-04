-- ============================================================
-- Migration 00092: Fix School Dictionary Table RLS Policies
-- ============================================================
-- Problem: Write policies on school_categories, school_conditions,
-- and pickup_locations check `user_profiles.is_admin = true`.
-- The admin dashboard uses `admin_users` as the source of truth,
-- so `is_admin` on user_profiles is unreliable for sysadmins.
--
-- Fix: Replace the write policies to check admin_users table.
-- Also adds missing INSERT/UPDATE/DELETE policies on pickup_locations.
-- ============================================================

-- ─── Helper: is the caller a platform admin? ──────────────────
-- Reuse the existing is_platform_sysadmin() SECURITY DEFINER function
-- for sysadmin check, or fall back to checking admin_users for any role.

-- NOTE: We intentionally allow ANY admin_users entry (not just sysadmin)
-- to manage school dict tables. School-level admins need this too.
-- For tighter scoping, add a role check in the future.

-- ─── school_categories ────────────────────────────────────────

DROP POLICY IF EXISTS "Admins can manage school_categories" ON public.school_categories;

-- Allow SELECT even for inactive rows when caller is an admin
DROP POLICY IF EXISTS "Active categories are publicly readable" ON public.school_categories;

CREATE POLICY "Categories readable by all authenticated"
  ON public.school_categories FOR SELECT
  USING (
    is_active = true
    OR EXISTS (
      SELECT 1 FROM public.admin_users
      WHERE user_id = auth.uid() AND is_active = true
    )
  );

CREATE POLICY "Admins can write school_categories"
  ON public.school_categories FOR ALL
  USING (
    EXISTS (
      SELECT 1 FROM public.admin_users
      WHERE user_id = auth.uid() AND is_active = true
    )
  )
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM public.admin_users
      WHERE user_id = auth.uid() AND is_active = true
    )
  );


-- ─── school_conditions ────────────────────────────────────────

DROP POLICY IF EXISTS "Admins can manage school_conditions" ON public.school_conditions;
DROP POLICY IF EXISTS "Active conditions are publicly readable" ON public.school_conditions;

CREATE POLICY "Conditions readable by all authenticated"
  ON public.school_conditions FOR SELECT
  USING (
    is_active = true
    OR EXISTS (
      SELECT 1 FROM public.admin_users
      WHERE user_id = auth.uid() AND is_active = true
    )
  );

CREATE POLICY "Admins can write school_conditions"
  ON public.school_conditions FOR ALL
  USING (
    EXISTS (
      SELECT 1 FROM public.admin_users
      WHERE user_id = auth.uid() AND is_active = true
    )
  )
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM public.admin_users
      WHERE user_id = auth.uid() AND is_active = true
    )
  );


-- ─── pickup_locations ─────────────────────────────────────────
-- pickup_locations had no write policy at all — only SELECT.

DROP POLICY IF EXISTS "Pickup locations are publicly readable" ON public.pickup_locations;

CREATE POLICY "Pickup locations readable"
  ON public.pickup_locations FOR SELECT
  USING (
    is_active = true
    OR EXISTS (
      SELECT 1 FROM public.admin_users
      WHERE user_id = auth.uid() AND is_active = true
    )
  );

CREATE POLICY "Admins can write pickup_locations"
  ON public.pickup_locations FOR ALL
  USING (
    EXISTS (
      SELECT 1 FROM public.admin_users
      WHERE user_id = auth.uid() AND is_active = true
    )
  )
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM public.admin_users
      WHERE user_id = auth.uid() AND is_active = true
    )
  );


-- ─── Notify PostgREST to reload schema ───────────────────────
NOTIFY pgrst, 'reload schema';

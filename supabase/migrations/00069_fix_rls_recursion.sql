-- ============================================================
-- Migration 00069: Fix RLS recursion in admin_users policies
-- ============================================================
-- Problem: Policies on admin_users that do
--   EXISTS (SELECT 1 FROM admin_users WHERE ...)
-- cause infinite recursion because evaluating the policy
-- triggers the policy again on the nested SELECT.
--
-- Fix: Replace all inline admin_users subqueries in policies
-- with SECURITY DEFINER functions, which bypass RLS entirely.
-- is_platform_sysadmin() and is_admin_user() are both
-- SECURITY DEFINER and safe to use in policy USING clauses.
-- ============================================================

-- ── admin_users ───────────────────────────────────────────────

DROP POLICY IF EXISTS "Sysadmin manages admin_users" ON public.admin_users;
CREATE POLICY "Sysadmin manages admin_users"
  ON public.admin_users FOR ALL
  -- NOTE: is_platform_sysadmin() is SECURITY DEFINER → no RLS recursion
  USING (public.is_platform_sysadmin());

-- ── admin_school_scopes ───────────────────────────────────────

DROP POLICY IF EXISTS "Sysadmin manages scopes" ON public.admin_school_scopes;
CREATE POLICY "Sysadmin manages scopes"
  ON public.admin_school_scopes FOR ALL
  USING (public.is_platform_sysadmin());

-- ── system_settings ───────────────────────────────────────────

DROP POLICY IF EXISTS "Sysadmin manages settings" ON public.system_settings;
CREATE POLICY "Sysadmin manages settings"
  ON public.system_settings FOR ALL
  USING (public.is_platform_sysadmin());

-- ── schools ───────────────────────────────────────────────────

DROP POLICY IF EXISTS "Sysadmin manages schools" ON public.schools;
CREATE POLICY "Sysadmin manages schools"
  ON public.schools FOR ALL
  USING (public.is_platform_sysadmin());

-- ── moderation_drafts (also had inline admin_users subquery) ──

DROP POLICY IF EXISTS "Admin users manage own drafts" ON public.moderation_drafts;
CREATE POLICY "Admin users manage own drafts"
  ON public.moderation_drafts FOR ALL
  USING (admin_id = auth.uid() OR public.is_platform_sysadmin());

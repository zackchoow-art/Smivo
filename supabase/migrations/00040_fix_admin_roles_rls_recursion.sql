-- =============================================================
-- Migration 00040: Fix admin_roles RLS infinite recursion
-- =============================================================
-- The "Sysadmins manage all admin_roles" policy queries
-- admin_roles itself, triggering the same RLS check again
-- → infinite recursion (error 42P17).
--
-- Fix: use a SECURITY DEFINER function to bypass RLS when
-- checking if the current user is a platform sysadmin.
-- =============================================================

-- ─── 1. Create helper function (bypasses RLS) ────────────────

CREATE OR REPLACE FUNCTION public.is_platform_sysadmin()
RETURNS boolean
LANGUAGE sql
SECURITY DEFINER
STABLE
SET search_path = ''
AS $$
  SELECT EXISTS (
    SELECT 1 FROM public.admin_roles
    WHERE user_id = auth.uid()
      AND role = 'sysadmin'
      AND scope_type = 'platform'
      AND is_active = true
  );
$$;

-- ─── 2. Replace admin_roles policies ─────────────────────────

-- Drop the recursive policy
DROP POLICY IF EXISTS "Sysadmins manage all admin_roles" ON admin_roles;

-- Recreate using the SECURITY DEFINER function (no recursion)
CREATE POLICY "Sysadmins manage all admin_roles"
  ON admin_roles
  USING (public.is_platform_sysadmin());

-- ─── 3. Replace admin_permissions policies ───────────────────

-- Drop the recursive policy (also queries admin_roles)
DROP POLICY IF EXISTS "Sysadmins manage all admin_permissions" ON admin_permissions;

-- Recreate using the function
CREATE POLICY "Sysadmins manage all admin_permissions"
  ON admin_permissions
  USING (public.is_platform_sysadmin());

-- ─── 4. Fix "Users can read own permissions" policy ──────────
-- This policy also queries admin_roles which could recurse.

DROP POLICY IF EXISTS "Users can read own permissions" ON admin_permissions;

CREATE POLICY "Users can read own permissions"
  ON admin_permissions FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM public.admin_roles ar
      WHERE ar.id = admin_permissions.role_id
        AND ar.user_id = auth.uid()
    )
  );
-- NOTE: This SELECT on admin_roles is safe because the
-- "Users can read own roles" policy on admin_roles uses
-- a simple (user_id = auth.uid()) check with no recursion.

-- Migration 00053: Fix admin_users RLS infinite recursion
--
-- Problem: The "Super admins manage admin_users" policy queries admin_users
-- within its own USING clause, causing infinite recursion (error 42P17).
--
-- Solution: Create a SECURITY DEFINER function that bypasses RLS to check
-- if the current user is a platform_super_admin, then reference that
-- function in the policy instead of a sub-select.

-- 1. Create helper function (SECURITY DEFINER bypasses RLS)
CREATE OR REPLACE FUNCTION public.is_platform_super_admin()
RETURNS boolean
LANGUAGE sql
SECURITY DEFINER
STABLE
SET search_path = public
AS $$
  SELECT EXISTS (
    SELECT 1 FROM public.admin_users
    WHERE user_id = auth.uid()
      AND role = 'platform_super_admin'
      AND is_active = true
  );
$$;

-- 2. Drop the recursive policy
DROP POLICY IF EXISTS "Super admins manage admin_users" ON public.admin_users;

-- 3. Recreate with the helper function (no recursion)
CREATE POLICY "Super admins manage admin_users"
  ON public.admin_users FOR ALL
  USING (public.is_platform_super_admin());

-- 4. Also fix admin_school_scopes which has the same pattern
DROP POLICY IF EXISTS "Super admins manage scopes" ON public.admin_school_scopes;

CREATE POLICY "Super admins manage scopes"
  ON public.admin_school_scopes FOR ALL
  USING (public.is_platform_super_admin());

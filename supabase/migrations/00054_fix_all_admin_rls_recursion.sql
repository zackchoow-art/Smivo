-- Migration 00054: Fix ALL admin RLS recursion across all tables
--
-- Problem: 20 policies across 12 tables reference admin_users in their
-- USING clause, causing infinite recursion (error 42P17) when admin_users
-- RLS is enabled.
--
-- Solution: Replace all admin_users sub-selects with SECURITY DEFINER
-- helper functions that bypass RLS.

-- 1. Create helper: is any active admin?
CREATE OR REPLACE FUNCTION public.is_active_admin()
RETURNS boolean
LANGUAGE sql
SECURITY DEFINER
STABLE
SET search_path = public
AS $$
  SELECT EXISTS (
    SELECT 1 FROM public.admin_users
    WHERE user_id = auth.uid()
      AND is_active = true
  );
$$;

-- is_platform_super_admin() already created in 00053, recreate for safety
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

-- ══════════════════════════════════════════════
-- 2. Fix admin_audit_logs
-- ══════════════════════════════════════════════
DROP POLICY IF EXISTS "Admin users can read audit logs" ON public.admin_audit_logs;
CREATE POLICY "Admin users can read audit logs"
  ON public.admin_audit_logs FOR SELECT
  USING (public.is_active_admin());

DROP POLICY IF EXISTS "Admin users can insert audit logs" ON public.admin_audit_logs;
CREATE POLICY "Admin users can insert audit logs"
  ON public.admin_audit_logs FOR INSERT
  WITH CHECK (public.is_active_admin());

-- ══════════════════════════════════════════════
-- 3. Fix feature_flags (system_settings)
-- ══════════════════════════════════════════════
DROP POLICY IF EXISTS "Super admins manage settings" ON public.system_settings;
CREATE POLICY "Super admins manage settings"
  ON public.system_settings FOR ALL
  USING (public.is_platform_super_admin());

-- ══════════════════════════════════════════════
-- 4. Fix moderation_drafts
-- ══════════════════════════════════════════════
DROP POLICY IF EXISTS "Admin users manage own drafts" ON public.moderation_drafts;
CREATE POLICY "Admin users manage own drafts"
  ON public.moderation_drafts FOR ALL
  USING (
    admin_id = auth.uid()
    OR public.is_platform_super_admin()
  );

-- ══════════════════════════════════════════════
-- 5. Fix user_bans
-- ══════════════════════════════════════════════
DROP POLICY IF EXISTS "Admin users manage bans" ON public.user_bans;
CREATE POLICY "Admin users manage bans"
  ON public.user_bans FOR ALL
  USING (public.is_active_admin());

-- ══════════════════════════════════════════════
-- 6. Fix push_jobs
-- ══════════════════════════════════════════════
DROP POLICY IF EXISTS "Admin users manage push jobs" ON public.push_jobs;
CREATE POLICY "Admin users manage push jobs"
  ON public.push_jobs FOR ALL
  USING (public.is_active_admin());

-- ══════════════════════════════════════════════
-- 7. Fix push_templates
-- ══════════════════════════════════════════════
DROP POLICY IF EXISTS "Admin users manage push templates" ON public.push_templates;
CREATE POLICY "Admin users manage push templates"
  ON public.push_templates FOR ALL
  USING (public.is_active_admin());

-- ══════════════════════════════════════════════
-- 8. Fix content_reports
-- ══════════════════════════════════════════════
DROP POLICY IF EXISTS "Admin users can read all reports" ON public.content_reports;
CREATE POLICY "Admin users can read all reports"
  ON public.content_reports FOR SELECT
  USING (
    reporter_id = auth.uid()
    OR public.is_active_admin()
  );

DROP POLICY IF EXISTS "Admin users can update reports" ON public.content_reports;
CREATE POLICY "Admin users can update reports"
  ON public.content_reports FOR UPDATE
  USING (public.is_active_admin());

-- ══════════════════════════════════════════════
-- 9. Fix user_feedbacks
-- ══════════════════════════════════════════════
DROP POLICY IF EXISTS "Admin users can read all feedbacks" ON public.user_feedbacks;
CREATE POLICY "Admin users can read all feedbacks"
  ON public.user_feedbacks FOR SELECT
  USING (
    user_id = auth.uid()
    OR public.is_active_admin()
  );

DROP POLICY IF EXISTS "Admin users can update feedbacks" ON public.user_feedbacks;
CREATE POLICY "Admin users can update feedbacks"
  ON public.user_feedbacks FOR UPDATE
  USING (public.is_active_admin());

-- ══════════════════════════════════════════════
-- 10. Fix sensitive_words
-- ══════════════════════════════════════════════
DROP POLICY IF EXISTS "Admin users can manage sensitive words" ON public.sensitive_words;
CREATE POLICY "Admin users can manage sensitive words"
  ON public.sensitive_words FOR ALL
  USING (public.is_active_admin());

-- ══════════════════════════════════════════════
-- 11. Fix schools
-- ══════════════════════════════════════════════
DROP POLICY IF EXISTS "Admin users can manage schools" ON public.schools;
CREATE POLICY "Admin users can manage schools"
  ON public.schools FOR ALL
  USING (public.is_platform_super_admin());

-- ══════════════════════════════════════════════
-- 12. Fix listings (admin read + update)
-- ══════════════════════════════════════════════
DROP POLICY IF EXISTS "Admin users can read all listings" ON public.listings;
CREATE POLICY "Admin users can read all listings"
  ON public.listings FOR SELECT
  USING (
    seller_id = auth.uid()
    OR public.is_active_admin()
  );

DROP POLICY IF EXISTS "Admin users can update listings" ON public.listings;
CREATE POLICY "Admin users can update listings"
  ON public.listings FOR UPDATE
  USING (public.is_active_admin());

-- ══════════════════════════════════════════════
-- 13. Fix orders (admin read)
-- ══════════════════════════════════════════════
DROP POLICY IF EXISTS "Admin users can read all orders" ON public.orders;
CREATE POLICY "Admin users can read all orders"
  ON public.orders FOR SELECT
  USING (
    buyer_id = auth.uid()
    OR seller_id = auth.uid()
    OR public.is_active_admin()
  );

-- ══════════════════════════════════════════════
-- 14. Fix user_profiles (admin read + update)
-- ══════════════════════════════════════════════
DROP POLICY IF EXISTS "Admin users can read all profiles" ON public.user_profiles;
CREATE POLICY "Admin users can read all profiles"
  ON public.user_profiles FOR SELECT
  USING (
    id = auth.uid()
    OR public.is_active_admin()
  );

DROP POLICY IF EXISTS "Admin users can update profiles" ON public.user_profiles;
CREATE POLICY "Admin users can update profiles"
  ON public.user_profiles FOR UPDATE
  USING (public.is_active_admin());

-- ══════════════════════════════════════════════
-- 15. Fix user_heartbeats (admin read)
-- ══════════════════════════════════════════════
DROP POLICY IF EXISTS "Admin users can read all heartbeats" ON public.user_heartbeats;
CREATE POLICY "Admin users can read all heartbeats"
  ON public.user_heartbeats FOR SELECT
  USING (
    user_id = auth.uid()
    OR public.is_active_admin()
  );

-- ══════════════════════════════════════════════
-- Done. All 20 recursive policies replaced with
-- SECURITY DEFINER function calls.
-- ══════════════════════════════════════════════

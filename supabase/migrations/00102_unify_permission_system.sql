-- ============================================================
-- Migration 00102: Unify Permission System
-- ============================================================
-- Consolidates three legacy permission layers into ONE table:
--   1. user_profiles.is_admin (00036)  → REMOVED
--   2. admin_roles + admin_permissions (00039) → REPLACED
--   3. admin_users + admin_school_scopes (00052) → REPLACED
--
-- New single source of truth: public.admin_roles
-- Role hierarchy (5 levels):
--   sysadmin           — full control, max 1 person
--   platform_admin     — all schools admin
--   platform_reviewer  — all schools reviewer
--   school_admin       — per-school management
--   school_reviewer    — per-school moderation
--
-- Business rules enforced via triggers:
--   1. Only 1 sysadmin allowed at any time
--   2. Granting platform_admin auto-deletes school_admin records
--   3. Granting platform_reviewer auto-deletes school_reviewer records
-- ============================================================

BEGIN;

-- ═══════════════════════════════════════════════════════════════
-- 0. Snapshot existing data for safety
-- ═══════════════════════════════════════════════════════════════

-- Snapshot old admin_users data into a temp table (lives only in this txn)
CREATE TEMP TABLE _snapshot_admin_users AS
SELECT * FROM public.admin_users;

CREATE TEMP TABLE _snapshot_admin_school_scopes AS
SELECT * FROM public.admin_school_scopes;

CREATE TEMP TABLE _snapshot_old_admin_roles AS
SELECT * FROM public.admin_roles;

-- ═══════════════════════════════════════════════════════════════
-- 1. Drop old tables (dependency order: children first)
-- ═══════════════════════════════════════════════════════════════

-- admin_permissions depends on old admin_roles
DROP TABLE IF EXISTS public.admin_permissions CASCADE;

-- old admin_roles (the 00039 version — has scope_type, scope_id)
DROP TABLE IF EXISTS public.admin_roles CASCADE;

-- admin_school_scopes depends on admin_users
DROP TABLE IF EXISTS public.admin_school_scopes CASCADE;

-- admin_users
DROP TABLE IF EXISTS public.admin_users CASCADE;

-- ═══════════════════════════════════════════════════════════════
-- 2. Create new unified admin_roles table
-- ═══════════════════════════════════════════════════════════════

CREATE TABLE public.admin_roles (
  id          uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id     uuid NOT NULL REFERENCES public.user_profiles(id) ON DELETE CASCADE,
  role        text NOT NULL,
  scope_type  text NOT NULL,
  scope_id    uuid,            -- NULL for platform scope, school UUID for school scope
  is_active   boolean NOT NULL DEFAULT true,
  created_at  timestamptz NOT NULL DEFAULT now(),
  updated_at  timestamptz NOT NULL DEFAULT now(),

  CONSTRAINT admin_roles_role_check
    CHECK (role IN (
      'sysadmin', 'platform_admin', 'platform_reviewer',
      'school_admin', 'school_reviewer'
    )),

  CONSTRAINT admin_roles_scope_check
    CHECK (scope_type IN ('platform', 'school')),

  -- Platform roles have NULL scope_id; school roles require a scope_id
  CONSTRAINT admin_roles_scope_logic
    CHECK (
      (scope_type = 'platform' AND scope_id IS NULL) OR
      (scope_type = 'school' AND scope_id IS NOT NULL)
    ),

  -- One record per user + role + scope combination
  CONSTRAINT admin_roles_unique
    UNIQUE (user_id, role, scope_type, scope_id)
);

-- Foreign key for school-scoped roles
ALTER TABLE public.admin_roles
  ADD CONSTRAINT admin_roles_scope_school_fkey
  FOREIGN KEY (scope_id) REFERENCES public.schools(id) ON DELETE CASCADE;

-- Auto-update updated_at
CREATE TRIGGER admin_roles_updated_at
  BEFORE UPDATE ON public.admin_roles
  FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();

-- Indexes for fast lookups
CREATE INDEX idx_admin_roles_user ON public.admin_roles(user_id);
CREATE INDEX idx_admin_roles_scope ON public.admin_roles(scope_type, scope_id);
CREATE INDEX idx_admin_roles_role ON public.admin_roles(role);

-- ═══════════════════════════════════════════════════════════════
-- 3. Migrate data from old tables into new admin_roles
-- ═══════════════════════════════════════════════════════════════

-- 3a. Platform-level roles (sysadmin, platform_admin, platform_reviewer)
-- These come from admin_users where role is platform-scoped
INSERT INTO public.admin_roles (user_id, role, scope_type, scope_id, is_active)
SELECT
  user_id,
  role,
  'platform',
  NULL,
  is_active
FROM _snapshot_admin_users
WHERE role IN ('sysadmin', 'platform_admin', 'platform_reviewer')
ON CONFLICT (user_id, role, scope_type, scope_id) DO NOTHING;

-- 3b. School-level roles from admin_users + admin_school_scopes
-- school_admin: each scope entry becomes a separate admin_roles row
INSERT INTO public.admin_roles (user_id, role, scope_type, scope_id, is_active)
SELECT
  au.user_id,
  au.role,
  'school',
  asc2.college_id,
  au.is_active
FROM _snapshot_admin_users au
JOIN _snapshot_admin_school_scopes asc2 ON asc2.admin_user_id = au.user_id
WHERE au.role IN ('school_admin', 'school_reviewer')
ON CONFLICT (user_id, role, scope_type, scope_id) DO NOTHING;

-- ═══════════════════════════════════════════════════════════════
-- 4. Business rule triggers
-- ═══════════════════════════════════════════════════════════════

-- 4a. Sysadmin uniqueness: only 1 active sysadmin allowed
CREATE OR REPLACE FUNCTION public.enforce_sysadmin_uniqueness()
RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN
  IF NEW.role = 'sysadmin' AND NEW.is_active = true THEN
    IF EXISTS (
      SELECT 1 FROM public.admin_roles
      WHERE role = 'sysadmin' AND is_active = true
        AND id != COALESCE(NEW.id, '00000000-0000-0000-0000-000000000000'::uuid)
    ) THEN
      RAISE EXCEPTION 'Only one active sysadmin is allowed. Deactivate the current sysadmin first.';
    END IF;
  END IF;
  RETURN NEW;
END;
$$;

CREATE TRIGGER trg_enforce_sysadmin_uniqueness
  BEFORE INSERT OR UPDATE ON public.admin_roles
  FOR EACH ROW EXECUTE FUNCTION public.enforce_sysadmin_uniqueness();

-- 4b. Platform role auto-cleanup:
--   Granting platform_admin → delete all school_admin for that user
--   Granting platform_reviewer → delete all school_reviewer for that user
CREATE OR REPLACE FUNCTION public.cleanup_redundant_school_roles()
RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN
  IF NEW.scope_type = 'platform' AND NEW.is_active = true THEN
    IF NEW.role = 'platform_admin' THEN
      DELETE FROM public.admin_roles
      WHERE user_id = NEW.user_id
        AND role = 'school_admin'
        AND scope_type = 'school';
    ELSIF NEW.role = 'platform_reviewer' THEN
      DELETE FROM public.admin_roles
      WHERE user_id = NEW.user_id
        AND role = 'school_reviewer'
        AND scope_type = 'school';
    END IF;
  END IF;
  RETURN NEW;
END;
$$;

CREATE TRIGGER trg_cleanup_redundant_school_roles
  AFTER INSERT OR UPDATE ON public.admin_roles
  FOR EACH ROW EXECUTE FUNCTION public.cleanup_redundant_school_roles();

-- ═══════════════════════════════════════════════════════════════
-- 5. RLS Policies for new admin_roles
-- ═══════════════════════════════════════════════════════════════

ALTER TABLE public.admin_roles ENABLE ROW LEVEL SECURITY;

-- Users can read their own roles
CREATE POLICY "Users can read own roles"
  ON public.admin_roles FOR SELECT
  USING (user_id = auth.uid());

-- Sysadmin can manage all roles (uses SECURITY DEFINER function to avoid recursion)
CREATE POLICY "Sysadmin manages all admin_roles"
  ON public.admin_roles FOR ALL
  USING (public.is_platform_sysadmin());

-- ═══════════════════════════════════════════════════════════════
-- 6. Rewrite core helper functions
-- ═══════════════════════════════════════════════════════════════

-- 6a. is_platform_sysadmin() — now reads new admin_roles
CREATE OR REPLACE FUNCTION public.is_platform_sysadmin()
RETURNS boolean LANGUAGE sql STABLE SECURITY DEFINER AS $$
  SELECT EXISTS (
    SELECT 1 FROM public.admin_roles
    WHERE user_id = auth.uid()
      AND role = 'sysadmin'
      AND scope_type = 'platform'
      AND is_active = true
  );
$$;

-- 6b. is_admin_user() — any active admin in new admin_roles
CREATE OR REPLACE FUNCTION public.is_admin_user()
RETURNS boolean LANGUAGE sql STABLE SECURITY DEFINER AS $$
  SELECT EXISTS (
    SELECT 1 FROM public.admin_roles
    WHERE user_id = auth.uid()
      AND is_active = true
  );
$$;

-- 6c. New helper: has_admin_role(role_name, optional scope_id)
-- Checks if current user has at least the specified role level.
-- Platform roles implicitly cover all schools.
CREATE OR REPLACE FUNCTION public.has_admin_role(
  p_role text,
  p_scope_id uuid DEFAULT NULL
)
RETURNS boolean LANGUAGE plpgsql STABLE SECURITY DEFINER AS $$
DECLARE
  v_role_level int;
  v_target_level int;
BEGIN
  -- Map role names to priority levels
  v_target_level := CASE p_role
    WHEN 'school_reviewer'   THEN 1
    WHEN 'school_admin'      THEN 2
    WHEN 'platform_reviewer' THEN 3
    WHEN 'platform_admin'    THEN 4
    WHEN 'sysadmin'          THEN 5
    ELSE 0
  END;

  -- Find the user's highest applicable role level
  SELECT MAX(
    CASE ar.role
      WHEN 'school_reviewer'   THEN 1
      WHEN 'school_admin'      THEN 2
      WHEN 'platform_reviewer' THEN 3
      WHEN 'platform_admin'    THEN 4
      WHEN 'sysadmin'          THEN 5
      ELSE 0
    END
  ) INTO v_role_level
  FROM public.admin_roles ar
  WHERE ar.user_id = auth.uid()
    AND ar.is_active = true
    AND (
      -- Platform roles apply everywhere
      ar.scope_type = 'platform'
      -- School roles apply only to matching school (or if no scope filter)
      OR (ar.scope_type = 'school' AND (p_scope_id IS NULL OR ar.scope_id = p_scope_id))
    );

  RETURN COALESCE(v_role_level, 0) >= v_target_level;
END;
$$;

-- 6d. Drop old functions that are no longer needed
DROP FUNCTION IF EXISTS public.check_admin_permission(uuid, text, text, uuid);
DROP FUNCTION IF EXISTS public.admin_has_college_access(uuid);

-- ═══════════════════════════════════════════════════════════════
-- 7. Rewrite RLS policies that referenced old tables
-- ═══════════════════════════════════════════════════════════════

-- NOTE: is_platform_sysadmin() and is_admin_user() are both
-- SECURITY DEFINER and now point to the new admin_roles table.
-- Policies using these functions do NOT need rewriting — they
-- automatically follow the new data source.
--
-- We only need to fix policies that directly queried admin_users.

-- 7a. school_categories
DROP POLICY IF EXISTS "Categories readable by all authenticated" ON public.school_categories;
DROP POLICY IF EXISTS "Admins can write school_categories" ON public.school_categories;

CREATE POLICY "Categories readable by all authenticated"
  ON public.school_categories FOR SELECT
  USING (
    is_active = true
    OR public.is_admin_user()
  );

CREATE POLICY "Admins can write school_categories"
  ON public.school_categories FOR ALL
  USING (public.is_admin_user())
  WITH CHECK (public.is_admin_user());

-- 7b. school_conditions
DROP POLICY IF EXISTS "Conditions readable by all authenticated" ON public.school_conditions;
DROP POLICY IF EXISTS "Admins can write school_conditions" ON public.school_conditions;

CREATE POLICY "Conditions readable by all authenticated"
  ON public.school_conditions FOR SELECT
  USING (
    is_active = true
    OR public.is_admin_user()
  );

CREATE POLICY "Admins can write school_conditions"
  ON public.school_conditions FOR ALL
  USING (public.is_admin_user())
  WITH CHECK (public.is_admin_user());

-- 7c. pickup_locations
DROP POLICY IF EXISTS "Pickup locations readable" ON public.pickup_locations;
DROP POLICY IF EXISTS "Admins can write pickup_locations" ON public.pickup_locations;

CREATE POLICY "Pickup locations readable"
  ON public.pickup_locations FOR SELECT
  USING (
    is_active = true
    OR public.is_admin_user()
  );

CREATE POLICY "Admins can write pickup_locations"
  ON public.pickup_locations FOR ALL
  USING (public.is_admin_user())
  WITH CHECK (public.is_admin_user());

-- ═══════════════════════════════════════════════════════════════
-- 8. Rewrite handle_new_user() trigger
-- ═══════════════════════════════════════════════════════════════

CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = ''
AS $$
declare
  v_email_domain text;
  v_school_id uuid;
  v_school_name text;
  v_smivo_dev_id uuid;
  v_display_name text;
  v_avatar_url text;
begin
  -- 1. Generate random avatar seed using Open Peeps
  v_avatar_url := 'https://api.dicebear.com/9.x/open-peeps/png?seed=' || new.id || '&backgroundColor=transparent';

  -- 2. HIGHEST PRIORITY: Manual/Admin assignment via metadata
  if new.raw_user_meta_data->>'bypass_edu' = 'true' then
    v_school_id := (new.raw_user_meta_data->>'school_id')::uuid;

    -- Fallback to first active school if metadata school_id is missing
    if v_school_id is null then
      select id into v_school_id from public.schools where is_active = true limit 1;
    end if;

    v_display_name := coalesce(new.raw_user_meta_data->>'display_name', split_part(new.email, '@', 1));

    -- Get school name for the redundancy field
    select name into v_school_name from public.schools where id = v_school_id;

    -- Insert into user_profiles
    insert into public.user_profiles (id, email, school_id, school, is_verified, display_name, avatar_url)
    values (new.id, new.email, v_school_id, v_school_name, true, v_display_name, v_avatar_url);

    -- If role is provided, insert into NEW admin_roles table
    if new.raw_user_meta_data->>'role' is not null then
      insert into public.admin_roles (user_id, role, scope_type, scope_id, is_active)
      values (
        new.id,
        new.raw_user_meta_data->>'role',
        -- Platform-level roles have NULL scope_id
        case when (new.raw_user_meta_data->>'role') in ('sysadmin', 'platform_admin', 'platform_reviewer')
             then 'platform' else 'school' end,
        case when (new.raw_user_meta_data->>'role') in ('sysadmin', 'platform_admin', 'platform_reviewer')
             then null else v_school_id end,
        true
      );
    end if;

    return new;
  end if;

  -- 3. STANDARD USER SIGNUP FLOW
  v_email_domain := split_part(new.email, '@', 2);
  v_display_name := split_part(new.email, '@', 1);

  -- 3a. Look up the school by exact email domain match
  select id, name into v_school_id, v_school_name
    from public.schools
    where email_domain = v_email_domain
      and is_active = true;

  -- 3b. Fallback to smivo-dev school
  if v_school_id is null then
    select id, name into v_smivo_dev_id, v_school_name from public.schools where slug = 'smivo-dev';
    v_school_id := v_smivo_dev_id;
  end if;

  -- 4. FINAL INSERTION
  insert into public.user_profiles (id, email, school_id, school, display_name, avatar_url)
  values (new.id, new.email, v_school_id, v_school_name, v_display_name, v_avatar_url);

  return new;
end;
$$;

-- ═══════════════════════════════════════════════════════════════
-- 9. Update admin_delete_user() to reference new table
-- ═══════════════════════════════════════════════════════════════

CREATE OR REPLACE FUNCTION public.admin_delete_user(p_user_id uuid)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, auth
AS $$
DECLARE
  v_caller_id uuid := auth.uid();
BEGIN
  -- 1. Verify caller is a platform sysadmin
  IF NOT public.is_platform_sysadmin() THEN
    RAISE EXCEPTION 'Unauthorized: caller is not a platform sysadmin';
  END IF;

  -- 2. Delete data with safety checks
  IF EXISTS (SELECT 1 FROM pg_tables WHERE schemaname = 'public' AND tablename = 'rental_extensions') THEN
    EXECUTE 'DELETE FROM public.rental_extensions WHERE order_id IN (SELECT id FROM public.orders WHERE buyer_id = $1 OR seller_id = $1)' USING p_user_id;
    EXECUTE 'DELETE FROM public.rental_extensions WHERE requested_by = $1' USING p_user_id;
  END IF;

  IF EXISTS (SELECT 1 FROM pg_tables WHERE schemaname = 'public' AND tablename = 'order_evidence') THEN
    EXECUTE 'DELETE FROM public.order_evidence WHERE order_id IN (SELECT id FROM public.orders WHERE buyer_id = $1 OR seller_id = $1)' USING p_user_id;
  END IF;

  IF EXISTS (SELECT 1 FROM pg_tables WHERE schemaname = 'public' AND tablename = 'orders') THEN
    EXECUTE 'DELETE FROM public.orders WHERE buyer_id = $1 OR seller_id = $1' USING p_user_id;
  END IF;

  IF EXISTS (SELECT 1 FROM pg_tables WHERE schemaname = 'public' AND tablename = 'notifications') THEN
    EXECUTE 'DELETE FROM public.notifications WHERE user_id = $1' USING p_user_id;
  END IF;

  IF EXISTS (SELECT 1 FROM pg_tables WHERE schemaname = 'public' AND tablename = 'messages') THEN
    EXECUTE 'DELETE FROM public.messages WHERE sender_id = $1' USING p_user_id;
  END IF;

  IF EXISTS (SELECT 1 FROM pg_tables WHERE schemaname = 'public' AND tablename = 'chat_rooms') THEN
    EXECUTE 'DELETE FROM public.chat_rooms WHERE buyer_id = $1 OR seller_id = $1' USING p_user_id;
  END IF;

  IF EXISTS (SELECT 1 FROM pg_tables WHERE schemaname = 'public' AND tablename = 'saved_listings') THEN
    EXECUTE 'DELETE FROM public.saved_listings WHERE user_id = $1' USING p_user_id;
  END IF;

  IF EXISTS (SELECT 1 FROM pg_tables WHERE schemaname = 'public' AND tablename = 'listings') THEN
    EXECUTE 'DELETE FROM public.listings WHERE seller_id = $1' USING p_user_id;
  END IF;

  IF EXISTS (SELECT 1 FROM pg_tables WHERE schemaname = 'public' AND tablename = 'content_reports') THEN
    EXECUTE 'DELETE FROM public.content_reports WHERE reporter_id = $1 OR reported_user_id = $1' USING p_user_id;
  END IF;

  IF EXISTS (SELECT 1 FROM pg_tables WHERE schemaname = 'public' AND tablename = 'moderation_queue') THEN
    EXECUTE 'DELETE FROM public.moderation_queue WHERE user_id = $1' USING p_user_id;
  END IF;

  IF EXISTS (SELECT 1 FROM pg_tables WHERE schemaname = 'public' AND tablename = 'user_feedbacks') THEN
    EXECUTE 'DELETE FROM public.user_feedbacks WHERE user_id = $1' USING p_user_id;
  END IF;

  IF EXISTS (SELECT 1 FROM pg_tables WHERE schemaname = 'public' AND tablename = 'user_active_sessions') THEN
    EXECUTE 'DELETE FROM public.user_active_sessions WHERE user_id = $1' USING p_user_id;
  END IF;

  -- admin_roles (new unified table)
  IF EXISTS (SELECT 1 FROM pg_tables WHERE schemaname = 'public' AND tablename = 'admin_roles') THEN
    EXECUTE 'DELETE FROM public.admin_roles WHERE user_id = $1' USING p_user_id;
  END IF;

  -- school_admins (legacy, may still exist)
  IF EXISTS (SELECT 1 FROM pg_tables WHERE schemaname = 'public' AND tablename = 'school_admins') THEN
    EXECUTE 'DELETE FROM public.school_admins WHERE user_id = $1' USING p_user_id;
  END IF;

  -- admin_audit_logs
  IF EXISTS (SELECT 1 FROM pg_tables WHERE schemaname = 'public' AND tablename = 'admin_audit_logs') THEN
    EXECUTE 'DELETE FROM public.admin_audit_logs WHERE admin_id = $1' USING p_user_id;
  END IF;

  IF EXISTS (SELECT 1 FROM pg_tables WHERE schemaname = 'public' AND tablename = 'user_bans') THEN
    EXECUTE 'DELETE FROM public.user_bans WHERE user_id = $1' USING p_user_id;
  END IF;

  IF EXISTS (SELECT 1 FROM pg_tables WHERE schemaname = 'public' AND tablename = 'user_reviews') THEN
    EXECUTE 'DELETE FROM public.user_reviews WHERE reviewer_id = $1 OR target_user_id = $1' USING p_user_id;
  END IF;

  -- 3. Delete user_profile and auth
  DELETE FROM public.user_profiles WHERE id = p_user_id;
  DELETE FROM auth.users WHERE id = p_user_id;

  -- 4. Write audit log
  IF EXISTS (SELECT 1 FROM pg_tables WHERE schemaname = 'public' AND tablename = 'admin_audit_logs') THEN
    INSERT INTO public.admin_audit_logs (
      admin_id, action, target_type, target_id, payload
    ) VALUES (
      v_caller_id,
      'admin_delete_user',
      'user',
      p_user_id,
      jsonb_build_object('deleted_by', v_caller_id, 'deleted_at', now())
    );
  END IF;

  RETURN jsonb_build_object('success', true, 'deleted_user_id', p_user_id);

EXCEPTION WHEN OTHERS THEN
  RAISE EXCEPTION 'Failed to delete user %: %', p_user_id, SQLERRM;
END;
$$;

GRANT EXECUTE ON FUNCTION public.admin_delete_user(uuid) TO authenticated;

-- ═══════════════════════════════════════════════════════════════
-- 10. Drop RLS policies that depend on is_admin, then drop column
-- ═══════════════════════════════════════════════════════════════

-- 10a. Drop all legacy policies that reference user_profiles.is_admin
DROP POLICY IF EXISTS "Admins can insert FAQs" ON public.faqs;
DROP POLICY IF EXISTS "Admins can update FAQs" ON public.faqs;
DROP POLICY IF EXISTS "Admins can delete FAQs" ON public.faqs;
DROP POLICY IF EXISTS "Admins can insert schools" ON public.schools;
DROP POLICY IF EXISTS "Admins can update schools" ON public.schools;
DROP POLICY IF EXISTS "Admins can delete schools" ON public.schools;
DROP POLICY IF EXISTS "School admins readable by platform admins" ON public.school_admins;
DROP POLICY IF EXISTS "Platform admins can manage school_admins" ON public.school_admins;
DROP POLICY IF EXISTS "Admins can manage system_dictionaries" ON public.system_dictionaries;
DROP POLICY IF EXISTS "Platform admins can manage category defaults" ON public.platform_category_defaults;
DROP POLICY IF EXISTS "Platform admins can manage condition defaults" ON public.platform_condition_defaults;

-- 10b. Now safely drop the column
ALTER TABLE public.user_profiles DROP COLUMN IF EXISTS is_admin;

-- 10c. Recreate equivalent policies using is_admin_user() / is_platform_sysadmin()
-- FAQs: admin-level access
CREATE POLICY "Admins can insert FAQs"
  ON public.faqs FOR INSERT
  WITH CHECK (public.is_admin_user());

CREATE POLICY "Admins can update FAQs"
  ON public.faqs FOR UPDATE
  USING (public.is_admin_user());

CREATE POLICY "Admins can delete FAQs"
  ON public.faqs FOR DELETE
  USING (public.is_admin_user());

-- Schools: sysadmin-only management
CREATE POLICY "Admins can insert schools"
  ON public.schools FOR INSERT
  WITH CHECK (public.is_platform_sysadmin());

CREATE POLICY "Admins can update schools"
  ON public.schools FOR UPDATE
  USING (public.is_platform_sysadmin());

CREATE POLICY "Admins can delete schools"
  ON public.schools FOR DELETE
  USING (public.is_platform_sysadmin());

-- school_admins: platform admin access
DO $$ BEGIN
  IF EXISTS (SELECT 1 FROM pg_tables WHERE schemaname = 'public' AND tablename = 'school_admins') THEN
    EXECUTE 'CREATE POLICY "School admins readable by platform admins" ON public.school_admins FOR SELECT USING (public.is_admin_user())';
    EXECUTE 'CREATE POLICY "Platform admins can manage school_admins" ON public.school_admins FOR ALL USING (public.is_platform_sysadmin())';
  END IF;
END $$;

-- system_dictionaries: admin access
CREATE POLICY "Admins can manage system_dictionaries"
  ON public.system_dictionaries FOR ALL
  USING (public.is_admin_user())
  WITH CHECK (public.is_admin_user());

-- platform defaults: sysadmin access
DO $$ BEGIN
  IF EXISTS (SELECT 1 FROM pg_tables WHERE schemaname = 'public' AND tablename = 'platform_category_defaults') THEN
    EXECUTE 'CREATE POLICY "Platform admins can manage category defaults" ON public.platform_category_defaults FOR ALL USING (public.is_platform_sysadmin()) WITH CHECK (public.is_platform_sysadmin())';
  END IF;
  IF EXISTS (SELECT 1 FROM pg_tables WHERE schemaname = 'public' AND tablename = 'platform_condition_defaults') THEN
    EXECUTE 'CREATE POLICY "Platform admins can manage condition defaults" ON public.platform_condition_defaults FOR ALL USING (public.is_platform_sysadmin()) WITH CHECK (public.is_platform_sysadmin())';
  END IF;
END $$;

-- ═══════════════════════════════════════════════════════════════
-- 11. Notify PostgREST to reload schema
-- ═══════════════════════════════════════════════════════════════

NOTIFY pgrst, 'reload schema';

COMMIT;

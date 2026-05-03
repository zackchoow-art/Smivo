-- ============================================================
-- Migration 00068: Unify admin role hierarchy in admin_users
-- ============================================================
-- admin_users is now the single source of truth for both
-- the web admin dashboard and the Flutter app (future).
--
-- New 5-level role hierarchy:
--   sysadmin           (was: platform_super_admin) — full control, only one
--   platform_admin     (was: platform_moderator)   — cross-school management
--   platform_reviewer  (new)                       — cross-school moderation
--   school_admin       (unchanged)                 — per-school management
--   school_reviewer    (new)                       — per-school moderation
--
-- admin_roles table is deprecated — kept for historical data only.
-- ============================================================

-- ── 1. Expand admin_users.role check constraint ──────────────

ALTER TABLE public.admin_users
  DROP CONSTRAINT IF EXISTS admin_users_role_check;

-- Temporarily allow all values for migration
ALTER TABLE public.admin_users
  ADD CONSTRAINT admin_users_role_check
    CHECK (role IN (
      'sysadmin', 'platform_admin', 'platform_reviewer',
      'school_admin', 'school_reviewer',
      -- legacy values kept during migration window
      'platform_super_admin', 'platform_moderator'
    ));

-- ── 2. Migrate existing data ──────────────────────────────────

UPDATE public.admin_users
  SET role = 'sysadmin'
  WHERE role = 'platform_super_admin';

UPDATE public.admin_users
  SET role = 'platform_admin'
  WHERE role = 'platform_moderator';

-- ── 3. Remove legacy values from constraint ───────────────────

ALTER TABLE public.admin_users
  DROP CONSTRAINT IF EXISTS admin_users_role_check;

ALTER TABLE public.admin_users
  ADD CONSTRAINT admin_users_role_check
    CHECK (role IN (
      'sysadmin', 'platform_admin', 'platform_reviewer',
      'school_admin', 'school_reviewer'
    ));

-- ── 4. Update RLS policies that hardcode old role names ───────

-- admin_users: sysadmin can manage all
DROP POLICY IF EXISTS "Super admins manage admin_users" ON public.admin_users;
CREATE POLICY "Sysadmin manages admin_users"
  ON public.admin_users FOR ALL
  USING (
    EXISTS (
      SELECT 1 FROM public.admin_users au
      WHERE au.user_id = auth.uid()
        AND au.role = 'sysadmin'
        AND au.is_active = true
    )
  );

-- admin_school_scopes: sysadmin can manage all
DROP POLICY IF EXISTS "Super admins manage scopes" ON public.admin_school_scopes;
CREATE POLICY "Sysadmin manages scopes"
  ON public.admin_school_scopes FOR ALL
  USING (
    EXISTS (
      SELECT 1 FROM public.admin_users au
      WHERE au.user_id = auth.uid()
        AND au.role = 'sysadmin'
        AND au.is_active = true
    )
  );

-- system_settings: sysadmin only
DROP POLICY IF EXISTS "Super admins manage settings" ON public.system_settings;
CREATE POLICY "Sysadmin manages settings"
  ON public.system_settings FOR ALL
  USING (
    EXISTS (
      SELECT 1 FROM public.admin_users au
      WHERE au.user_id = auth.uid()
        AND au.role = 'sysadmin'
        AND au.is_active = true
    )
  );

-- schools: sysadmin only
DROP POLICY IF EXISTS "Admin users can manage schools" ON public.schools;
CREATE POLICY "Sysadmin manages schools"
  ON public.schools FOR ALL
  USING (
    EXISTS (
      SELECT 1 FROM public.admin_users au
      WHERE au.user_id = auth.uid()
        AND au.role = 'sysadmin'
        AND au.is_active = true
    )
  );

-- ── 5. Update is_platform_sysadmin() to use admin_users ───────
-- NOTE: This function is used by cleanup RPCs and other SECURITY DEFINER functions.

CREATE OR REPLACE FUNCTION public.is_platform_sysadmin()
RETURNS boolean LANGUAGE sql STABLE SECURITY DEFINER AS $$
  SELECT EXISTS (
    SELECT 1 FROM public.admin_users
    WHERE user_id = auth.uid()
      AND role = 'sysadmin'
      AND is_active = true
  );
$$;

-- ── 6. Update admin_has_college_access() to use new role name ─

CREATE OR REPLACE FUNCTION public.admin_has_college_access(p_college_id uuid)
RETURNS boolean LANGUAGE plpgsql STABLE SECURITY DEFINER AS $$
DECLARE
  v_role text;
BEGIN
  SELECT role INTO v_role
  FROM public.admin_users
  WHERE user_id = auth.uid() AND is_active = true;

  IF v_role IS NULL THEN RETURN false; END IF;

  -- Sysadmin has unrestricted access to all schools
  IF v_role = 'sysadmin' THEN RETURN true; END IF;

  -- All other roles: check admin_school_scopes
  RETURN EXISTS (
    SELECT 1 FROM public.admin_school_scopes
    WHERE admin_user_id = auth.uid() AND college_id = p_college_id
  );
END;
$$;

-- ── 7. Update cleanup RPCs to sysadmin-only ──────────────────

CREATE OR REPLACE FUNCTION public.clear_platform_test_data()
RETURNS jsonb LANGUAGE plpgsql SECURITY DEFINER AS $$
BEGIN
  -- NOTE: Sysadmin only — checked against admin_users
  IF NOT public.is_platform_sysadmin() THEN
    RAISE EXCEPTION 'Permission denied: sysadmin only';
  END IF;

  INSERT INTO public.admin_audit_logs (admin_id, action, target_type, target_id, payload)
  VALUES (auth.uid(), 'platform_data_purge', 'platform', 'all',
    jsonb_build_object('note', 'Pre-launch platform-wide test data purge', 'timestamp', now()));

  DELETE FROM public.rental_extensions;
  DELETE FROM public.order_evidence;
  DELETE FROM public.messages;
  DELETE FROM public.chat_rooms;
  DELETE FROM public.orders;
  DELETE FROM public.content_reports;
  DELETE FROM public.moderation_drafts;
  DELETE FROM public.listing_moderation_notices;
  DELETE FROM public.user_feedbacks;
  DELETE FROM public.contribution_ledger;
  DELETE FROM public.notifications;
  DELETE FROM public.user_bans;
  DELETE FROM public.user_active_sessions;
  DELETE FROM public.saved_listings;
  DELETE FROM public.listing_images;
  DELETE FROM public.listings;
  DELETE FROM public.user_heartbeats;
  DELETE FROM public.hourly_active_users;

  RETURN jsonb_build_object('status', 'success', 'scope', 'platform', 'purged_at', now());
END;
$$;

CREATE OR REPLACE FUNCTION public.clear_school_test_data(p_school_id uuid)
RETURNS jsonb LANGUAGE plpgsql SECURITY DEFINER AS $$
DECLARE
  v_listing_ids uuid[];
  v_user_ids    uuid[];
  v_order_ids   uuid[];
  v_room_ids    uuid[];
BEGIN
  -- NOTE: Sysadmin only per user decision
  IF NOT public.is_platform_sysadmin() THEN
    RAISE EXCEPTION 'Permission denied: sysadmin only';
  END IF;

  SELECT array_agg(id) INTO v_listing_ids
    FROM public.listings WHERE school_id = p_school_id;

  SELECT array_agg(id) INTO v_user_ids
    FROM public.user_profiles WHERE school_id = p_school_id;

  IF v_listing_ids IS NOT NULL THEN
    SELECT array_agg(id) INTO v_order_ids
      FROM public.orders WHERE listing_id = ANY(v_listing_ids);
    SELECT array_agg(id) INTO v_room_ids
      FROM public.chat_rooms WHERE listing_id = ANY(v_listing_ids);

    IF v_order_ids IS NOT NULL THEN
      DELETE FROM public.rental_extensions WHERE order_id = ANY(v_order_ids);
      DELETE FROM public.order_evidence     WHERE order_id = ANY(v_order_ids);
    END IF;
    IF v_room_ids IS NOT NULL THEN
      DELETE FROM public.messages WHERE chat_room_id = ANY(v_room_ids);
    END IF;

    DELETE FROM public.chat_rooms   WHERE listing_id = ANY(v_listing_ids);
    DELETE FROM public.orders       WHERE listing_id = ANY(v_listing_ids);
    DELETE FROM public.saved_listings WHERE listing_id = ANY(v_listing_ids);
    DELETE FROM public.listing_images WHERE listing_id = ANY(v_listing_ids);
    DELETE FROM public.listing_moderation_notices WHERE listing_id = ANY(v_listing_ids);
    DELETE FROM public.listings     WHERE id = ANY(v_listing_ids);
  END IF;

  IF v_user_ids IS NOT NULL THEN
    DELETE FROM public.content_reports    WHERE reporter_id = ANY(v_user_ids);
    DELETE FROM public.user_feedbacks     WHERE user_id     = ANY(v_user_ids);
    DELETE FROM public.contribution_ledger WHERE user_id    = ANY(v_user_ids);
    DELETE FROM public.notifications      WHERE user_id     = ANY(v_user_ids);
    DELETE FROM public.user_bans          WHERE user_id     = ANY(v_user_ids);
    DELETE FROM public.user_active_sessions WHERE user_id   = ANY(v_user_ids);
    DELETE FROM public.user_heartbeats    WHERE user_id     = ANY(v_user_ids);
  END IF;

  INSERT INTO public.admin_audit_logs (admin_id, action, target_type, target_id, payload)
  VALUES (auth.uid(), 'school_data_purge', 'school', p_school_id::text,
    jsonb_build_object('school_id', p_school_id, 'timestamp', now()));

  RETURN jsonb_build_object('status', 'success', 'scope', 'school',
    'school_id', p_school_id, 'purged_at', now());
END;
$$;

-- ── 8. Deprecate admin_roles ──────────────────────────────────

COMMENT ON TABLE public.admin_roles IS
  'DEPRECATED as of migration 00068. admin_users is now the single '
  'source of truth for both web admin and Flutter app admin RBAC. '
  'This table is kept for historical data only — do not write new records.';

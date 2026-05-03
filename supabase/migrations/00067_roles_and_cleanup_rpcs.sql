-- ============================================================
-- Migration 00067: Expand admin role hierarchy + test data cleanup RPCs
-- ============================================================
-- New role hierarchy (5 levels):
--   school_reviewer  → read-only within assigned school(s)
--   school_admin     → read/write within assigned school(s)
--   platform_reviewer→ read-only across all schools (platform scope)
--   platform_admin   → read/write across all schools (platform scope)
--   sysadmin         → full control; only one per platform
-- ============================================================

-- ── 1. Expand admin_roles.role check constraint ──────────────

ALTER TABLE public.admin_roles
  DROP CONSTRAINT IF EXISTS admin_roles_role_check;

ALTER TABLE public.admin_roles
  ADD CONSTRAINT admin_roles_role_check
    CHECK (role IN (
      'school_reviewer',
      'school_admin',
      'platform_reviewer',
      'platform_admin',
      'sysadmin',
      -- Keep legacy values for backward compat during migration
      'operator',
      'admin'
    ));

-- ── 2. Migrate legacy roles to new names ─────────────────────
-- operator (platform) → platform_reviewer
-- admin    (platform) → platform_admin
-- operator (school)   → school_reviewer
-- admin    (school)   → school_admin

UPDATE public.admin_roles
SET role = 'platform_reviewer'
WHERE role = 'operator' AND scope_type = 'platform';

UPDATE public.admin_roles
SET role = 'platform_admin'
WHERE role = 'admin' AND scope_type = 'platform';

UPDATE public.admin_roles
SET role = 'school_reviewer'
WHERE role = 'operator' AND scope_type = 'school';

UPDATE public.admin_roles
SET role = 'school_admin'
WHERE role = 'admin' AND scope_type = 'school';

-- ── 3. Remove legacy values from check constraint ────────────

ALTER TABLE public.admin_roles
  DROP CONSTRAINT IF EXISTS admin_roles_role_check;

ALTER TABLE public.admin_roles
  ADD CONSTRAINT admin_roles_role_check
    CHECK (role IN (
      'school_reviewer',
      'school_admin',
      'platform_reviewer',
      'platform_admin',
      'sysadmin'
    ));

-- ── 4. Update check_admin_permission role ordering ───────────

CREATE OR REPLACE FUNCTION public.check_admin_permission(
  p_user_id  uuid,
  p_module   text,
  p_required text DEFAULT 'read',
  p_scope_id uuid DEFAULT NULL
)
RETURNS boolean LANGUAGE plpgsql SECURITY DEFINER AS $$
DECLARE
  v_role    text;
  v_default text;
BEGIN
  -- Highest applicable role for this user
  SELECT ar.role INTO v_role
  FROM public.admin_roles ar
  WHERE ar.user_id = p_user_id
    AND ar.is_active = true
    AND (
      ar.scope_type = 'platform'
      OR (ar.scope_type = 'school' AND (p_scope_id IS NULL OR ar.scope_id = p_scope_id))
    )
  ORDER BY
    CASE ar.role
      WHEN 'sysadmin'          THEN 5
      WHEN 'platform_admin'    THEN 4
      WHEN 'platform_reviewer' THEN 3
      WHEN 'school_admin'      THEN 2
      WHEN 'school_reviewer'   THEN 1
      ELSE 0
    END DESC
  LIMIT 1;

  IF v_role IS NULL THEN RETURN false; END IF;

  v_default := CASE
    WHEN v_role = 'sysadmin' THEN 'write'
    WHEN v_role = 'platform_admin' THEN
      CASE p_module
        WHEN 'schools'    THEN 'none'
        WHEN 'dictionary' THEN 'write'
        WHEN 'roles'      THEN 'none'
        ELSE 'write'
      END
    WHEN v_role = 'platform_reviewer' THEN
      CASE p_module
        WHEN 'dashboard'  THEN 'read'
        WHEN 'listings'   THEN 'read'
        WHEN 'orders'     THEN 'read'
        WHEN 'users'      THEN 'read'
        WHEN 'faqs'       THEN 'read'
        ELSE 'none'
      END
    WHEN v_role = 'school_admin' THEN
      CASE p_module
        WHEN 'schools'    THEN 'none'
        WHEN 'dictionary' THEN 'none'
        WHEN 'roles'      THEN 'none'
        WHEN 'users'      THEN 'read'
        ELSE 'write'
      END
    WHEN v_role = 'school_reviewer' THEN
      CASE p_module
        WHEN 'dashboard'  THEN 'read'
        WHEN 'listings'   THEN 'read'
        WHEN 'orders'     THEN 'read'
        ELSE 'none'
      END
    ELSE 'none'
  END;

  IF p_required = 'read' THEN
    RETURN v_default IN ('read', 'write');
  ELSIF p_required = 'write' THEN
    RETURN v_default = 'write';
  ELSE
    RETURN false;
  END IF;
END;
$$;

-- ── 5. RPC: clear_platform_test_data ─────────────────────────
-- Deletes ALL user-generated content platform-wide.
-- Restricted to sysadmin only via is_platform_sysadmin() check.

CREATE OR REPLACE FUNCTION public.clear_platform_test_data()
RETURNS jsonb LANGUAGE plpgsql SECURITY DEFINER AS $$
DECLARE
  v_result jsonb;
BEGIN
  -- NOTE: is_platform_sysadmin() is a SECURITY DEFINER function from migration 00040
  IF NOT public.is_platform_sysadmin() THEN
    RAISE EXCEPTION 'Permission denied: platform super admin only';
  END IF;

  -- Write an audit log entry before destruction so there is a trail
  INSERT INTO public.admin_audit_logs (admin_id, action, target_type, target_id, payload)
  VALUES (
    auth.uid(),
    'platform_data_purge',
    'platform',
    'all',
    jsonb_build_object('note', 'Pre-launch platform-wide test data purge', 'timestamp', now())
  );

  -- Delete in dependency order (children before parents)
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

  v_result := jsonb_build_object(
    'status', 'success',
    'scope', 'platform',
    'purged_at', now()
  );

  RETURN v_result;
END;
$$;

-- ── 6. RPC: clear_school_test_data ───────────────────────────
-- Deletes all user-generated content scoped to one school.
-- Accessible to sysadmin or school_admin with matching scope.

CREATE OR REPLACE FUNCTION public.clear_school_test_data(p_school_id uuid)
RETURNS jsonb LANGUAGE plpgsql SECURITY DEFINER AS $$
DECLARE
  v_listing_ids uuid[];
  v_user_ids    uuid[];
  v_order_ids   uuid[];
  v_room_ids    uuid[];
BEGIN
  -- Permission: sysadmin, or school_admin/school_reviewer scoped to this school
  IF NOT (
    public.is_platform_sysadmin()
    OR EXISTS (
      SELECT 1 FROM public.admin_roles
      WHERE user_id    = auth.uid()
        AND role       IN ('school_admin', 'platform_admin')
        AND scope_id   = p_school_id
        AND is_active  = true
    )
  ) THEN
    RAISE EXCEPTION 'Permission denied: insufficient access to school %', p_school_id;
  END IF;

  -- Collect IDs for cascade deletes
  SELECT array_agg(id) INTO v_listing_ids
  FROM public.listings WHERE school_id = p_school_id;

  SELECT array_agg(id) INTO v_user_ids
  FROM public.user_profiles WHERE school_id = p_school_id;

  -- Listing-scoped deletes
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

    DELETE FROM public.chat_rooms  WHERE listing_id = ANY(v_listing_ids);
    DELETE FROM public.orders      WHERE listing_id = ANY(v_listing_ids);
    DELETE FROM public.saved_listings WHERE listing_id = ANY(v_listing_ids);
    DELETE FROM public.listing_images WHERE listing_id = ANY(v_listing_ids);
    DELETE FROM public.listing_moderation_notices WHERE listing_id = ANY(v_listing_ids);
    DELETE FROM public.moderation_drafts WHERE target_id = ANY(v_listing_ids::text[]);
    DELETE FROM public.listings    WHERE id = ANY(v_listing_ids);
  END IF;

  -- User-scoped deletes
  IF v_user_ids IS NOT NULL THEN
    DELETE FROM public.content_reports    WHERE reporter_id = ANY(v_user_ids);
    DELETE FROM public.user_feedbacks     WHERE user_id     = ANY(v_user_ids);
    DELETE FROM public.contribution_ledger WHERE user_id    = ANY(v_user_ids);
    DELETE FROM public.notifications      WHERE user_id     = ANY(v_user_ids);
    DELETE FROM public.user_bans          WHERE user_id     = ANY(v_user_ids);
    DELETE FROM public.user_active_sessions WHERE user_id   = ANY(v_user_ids);
    DELETE FROM public.user_heartbeats    WHERE user_id     = ANY(v_user_ids);
  END IF;

  -- Audit log
  INSERT INTO public.admin_audit_logs (admin_id, action, target_type, target_id, payload)
  VALUES (
    auth.uid(),
    'school_data_purge',
    'school',
    p_school_id::text,
    jsonb_build_object('school_id', p_school_id, 'timestamp', now())
  );

  RETURN jsonb_build_object(
    'status',    'success',
    'scope',     'school',
    'school_id', p_school_id,
    'purged_at', now()
  );
END;
$$;

-- Grant execute to authenticated users (RPC permission enforced inside function)
GRANT EXECUTE ON FUNCTION public.clear_platform_test_data() TO authenticated;
GRANT EXECUTE ON FUNCTION public.clear_school_test_data(uuid) TO authenticated;

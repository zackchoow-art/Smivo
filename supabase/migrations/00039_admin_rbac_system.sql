-- =============================================================
-- Migration 00039: Admin RBAC System
-- Three-tier role system: operator, admin, sysadmin
-- Supports platform-level and school-level scoping
-- =============================================================

-- ─── 1. Create admin_roles table ─────────────────────────────
CREATE TABLE IF NOT EXISTS admin_roles (
  id          uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id     uuid NOT NULL REFERENCES user_profiles(id) ON DELETE CASCADE,
  role        text NOT NULL DEFAULT 'operator',
  scope_type  text NOT NULL DEFAULT 'school',
  scope_id    uuid,
  is_active   boolean NOT NULL DEFAULT true,
  created_at  timestamptz NOT NULL DEFAULT now(),
  updated_at  timestamptz NOT NULL DEFAULT now(),

  -- Role must be one of: operator, admin, sysadmin
  CONSTRAINT admin_roles_role_check
    CHECK (role IN ('operator', 'admin', 'sysadmin')),

  -- Scope must be platform or school
  CONSTRAINT admin_roles_scope_check
    CHECK (scope_type IN ('platform', 'school')),

  -- Platform roles have NULL scope_id; school roles require a scope_id
  CONSTRAINT admin_roles_scope_logic
    CHECK (
      (scope_type = 'platform' AND scope_id IS NULL) OR
      (scope_type = 'school' AND scope_id IS NOT NULL)
    ),

  -- One role per user per scope
  CONSTRAINT admin_roles_unique
    UNIQUE (user_id, scope_type, scope_id)
);

-- Foreign key for school-scoped roles
ALTER TABLE admin_roles
  ADD CONSTRAINT admin_roles_scope_school_fkey
  FOREIGN KEY (scope_id) REFERENCES schools(id) ON DELETE CASCADE;

-- Auto-update updated_at
CREATE TRIGGER admin_roles_updated_at
  BEFORE UPDATE ON admin_roles
  FOR EACH ROW EXECUTE FUNCTION handle_updated_at();

-- Index for fast lookups by user
CREATE INDEX idx_admin_roles_user ON admin_roles(user_id);
CREATE INDEX idx_admin_roles_scope ON admin_roles(scope_type, scope_id);

-- ─── 2. Create admin_permissions table ───────────────────────
-- Optional per-module permission overrides.
-- If no row exists for a (role_id, module), the role's default is used.
CREATE TABLE IF NOT EXISTS admin_permissions (
  id          uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  role_id     uuid NOT NULL REFERENCES admin_roles(id) ON DELETE CASCADE,
  module      text NOT NULL,
  permission  text NOT NULL DEFAULT 'none',
  created_at  timestamptz NOT NULL DEFAULT now(),
  updated_at  timestamptz NOT NULL DEFAULT now(),

  CONSTRAINT admin_permissions_module_check
    CHECK (module IN (
      'dashboard', 'users', 'listings', 'orders',
      'schools', 'categories', 'conditions',
      'faqs', 'dictionary', 'roles'
    )),

  CONSTRAINT admin_permissions_perm_check
    CHECK (permission IN ('none', 'read', 'write')),

  -- One permission per module per role assignment
  CONSTRAINT admin_permissions_unique
    UNIQUE (role_id, module)
);

CREATE TRIGGER admin_permissions_updated_at
  BEFORE UPDATE ON admin_permissions
  FOR EACH ROW EXECUTE FUNCTION handle_updated_at();

CREATE INDEX idx_admin_permissions_role ON admin_permissions(role_id);

-- ─── 3. Migrate existing data ────────────────────────────────

-- 3a. Migrate user_profiles.is_admin = true → platform sysadmin
INSERT INTO admin_roles (user_id, role, scope_type, scope_id)
SELECT id, 'sysadmin', 'platform', NULL
FROM user_profiles
WHERE is_admin = true
ON CONFLICT (user_id, scope_type, scope_id) DO NOTHING;

-- 3b. Migrate school_admins → admin_roles (map old roles)
INSERT INTO admin_roles (user_id, role, scope_type, scope_id)
SELECT
  sa.user_id,
  CASE sa.role
    WHEN 'super_admin' THEN 'sysadmin'
    WHEN 'admin'       THEN 'admin'
    WHEN 'moderator'   THEN 'operator'
    ELSE 'operator'
  END,
  'school',
  sa.school_id
FROM school_admins sa
ON CONFLICT (user_id, scope_type, scope_id) DO NOTHING;

-- ─── 4. RLS Policies ────────────────────────────────────────

ALTER TABLE admin_roles ENABLE ROW LEVEL SECURITY;
ALTER TABLE admin_permissions ENABLE ROW LEVEL SECURITY;

-- admin_roles: platform sysadmins can do everything
CREATE POLICY "Sysadmins manage all admin_roles"
  ON admin_roles
  USING (
    EXISTS (
      SELECT 1 FROM admin_roles ar
      WHERE ar.user_id = auth.uid()
        AND ar.role = 'sysadmin'
        AND ar.scope_type = 'platform'
        AND ar.is_active = true
    )
  );

-- admin_roles: users can read their own roles
CREATE POLICY "Users can read own roles"
  ON admin_roles FOR SELECT
  USING (user_id = auth.uid());

-- admin_permissions: platform sysadmins can manage
CREATE POLICY "Sysadmins manage all admin_permissions"
  ON admin_permissions
  USING (
    EXISTS (
      SELECT 1 FROM admin_roles ar
      WHERE ar.user_id = auth.uid()
        AND ar.role = 'sysadmin'
        AND ar.scope_type = 'platform'
        AND ar.is_active = true
    )
  );

-- admin_permissions: users can read permissions for their own roles
CREATE POLICY "Users can read own permissions"
  ON admin_permissions FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM admin_roles ar
      WHERE ar.id = admin_permissions.role_id
        AND ar.user_id = auth.uid()
    )
  );

-- ─── 5. Helper function: check if user has permission ────────
CREATE OR REPLACE FUNCTION check_admin_permission(
  p_user_id uuid,
  p_module text,
  p_required text DEFAULT 'read',  -- 'read' or 'write'
  p_scope_id uuid DEFAULT NULL     -- NULL = check platform + all schools
)
RETURNS boolean
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_role text;
  v_override text;
  v_default text;
BEGIN
  -- Find the user's highest applicable role
  SELECT ar.role INTO v_role
  FROM admin_roles ar
  WHERE ar.user_id = p_user_id
    AND ar.is_active = true
    AND (
      ar.scope_type = 'platform'
      OR (ar.scope_type = 'school' AND (p_scope_id IS NULL OR ar.scope_id = p_scope_id))
    )
  ORDER BY
    CASE ar.role
      WHEN 'sysadmin' THEN 3
      WHEN 'admin'    THEN 2
      WHEN 'operator' THEN 1
      ELSE 0
    END DESC
  LIMIT 1;

  IF v_role IS NULL THEN
    RETURN false;
  END IF;

  -- Check for permission override
  SELECT ap.permission INTO v_override
  FROM admin_permissions ap
  JOIN admin_roles ar ON ar.id = ap.role_id
  WHERE ar.user_id = p_user_id
    AND ar.is_active = true
    AND ap.module = p_module
    AND (
      ar.scope_type = 'platform'
      OR (ar.scope_type = 'school' AND (p_scope_id IS NULL OR ar.scope_id = p_scope_id))
    )
  ORDER BY
    CASE ap.permission
      WHEN 'write' THEN 3
      WHEN 'read'  THEN 2
      WHEN 'none'  THEN 1
      ELSE 0
    END DESC
  LIMIT 1;

  -- Use override if exists, otherwise use role default
  IF v_override IS NOT NULL THEN
    v_default := v_override;
  ELSE
    -- Role defaults
    v_default := CASE
      WHEN v_role = 'sysadmin' THEN 'write'
      WHEN v_role = 'admin' THEN
        CASE p_module
          WHEN 'schools'    THEN 'none'
          WHEN 'dictionary' THEN 'none'
          WHEN 'roles'      THEN 'none'
          WHEN 'users'      THEN 'read'
          ELSE 'write'
        END
      WHEN v_role = 'operator' THEN
        CASE p_module
          WHEN 'dashboard'  THEN 'read'
          WHEN 'listings'   THEN 'read'
          WHEN 'orders'     THEN 'read'
          WHEN 'faqs'       THEN 'read'
          ELSE 'none'
        END
      ELSE 'none'
    END;
  END IF;

  -- Check if effective permission meets the requirement
  IF p_required = 'read' THEN
    RETURN v_default IN ('read', 'write');
  ELSIF p_required = 'write' THEN
    RETURN v_default = 'write';
  ELSE
    RETURN false;
  END IF;
END;
$$;

-- ─── 6. Mark school_admins as deprecated ─────────────────────
COMMENT ON TABLE school_admins IS 'DEPRECATED: Use admin_roles instead. Kept for backward compatibility.';

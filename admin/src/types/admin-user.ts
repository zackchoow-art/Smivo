/**
 * Admin user types — maps to the unified `admin_roles` table.
 * admin_roles is the single source of truth for all admin RBAC
 * (migration 00102).
 *
 * Role hierarchy (5 levels):
 *   sysadmin           — full control, only one per platform
 *   platform_admin     — cross-school management
 *   platform_reviewer  — cross-school moderation
 *   school_admin       — management within assigned school(s)
 *   school_reviewer    — moderation within assigned school(s)
 */

export type AdminRoleName =
  | 'sysadmin'
  | 'platform_admin'
  | 'platform_reviewer'
  | 'school_admin'
  | 'school_reviewer';

/** A single row in admin_roles */
export interface AdminRoleRecord {
  id: string;
  user_id: string;
  role: AdminRoleName;
  scope_type: 'platform' | 'school';
  scope_id: string | null;
  is_active: boolean;
  created_at: string;
  updated_at: string;
}

/** Denormalized admin info — joined with user_profiles and schools */
export interface AdminUserInfo {
  user_id: string;
  display_name: string | null;
  email: string;
  avatar_url: string | null;
  roles: AdminRoleRecord[];
  /** Highest role across all scopes */
  highest_role: AdminRoleName | null;
  /** School names for display (from school-scoped roles) */
  school_names: string[];
}

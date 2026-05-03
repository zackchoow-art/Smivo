/**
 * Admin user types — maps to `admin_users` + `admin_school_scopes` tables.
 * admin_users is the single source of truth for both web admin and Flutter app.
 *
 * Role hierarchy (5 levels, migration 00068):
 *   sysadmin           — full control, only one per platform
 *   platform_admin     — cross-school management (assigned schools via scopes)
 *   platform_reviewer  — cross-school moderation (assigned schools via scopes)
 *   school_admin       — management within assigned school(s)
 *   school_reviewer    — moderation within assigned school(s)
 */

export type AdminRole =
  | 'sysadmin'
  | 'platform_admin'
  | 'platform_reviewer'
  | 'school_admin'
  | 'school_reviewer';

export interface AdminUser {
  user_id: string;
  role: AdminRole;
  display_name: string | null;
  email: string;
  avatar_url: string | null;
  is_active: boolean;
  created_at: string;
  updated_at: string;
}

export interface AdminSchoolScope {
  admin_user_id: string;
  college_id: string;
  granted_by: string | null;
  granted_at: string;
}

/** Denormalized admin info with scopes — used in admin list page */
export interface AdminUserWithScopes extends AdminUser {
  scopes: AdminSchoolScope[];
  college_names: string[];
}

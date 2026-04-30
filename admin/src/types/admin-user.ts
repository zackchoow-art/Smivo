/**
 * Admin user types — maps to `admin_users` + `admin_school_scopes` tables.
 * Defined in 03_MULTI_TENANT_ARCHITECTURE.md.
 */

export type AdminRole = 'platform_super_admin' | 'platform_moderator' | 'school_admin';

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

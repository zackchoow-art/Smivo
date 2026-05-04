/**
 * Zustand store for admin authentication state.
 * Stores the user's admin role records from the unified admin_roles table.
 * Persists across page refreshes via Supabase session.
 */
import { create } from 'zustand';
import type { AdminRoleRecord, AdminRoleName } from '@/types';

export interface AdminProfile {
  id: string;
  display_name: string | null;
  email: string;
  avatar_url: string | null;
}

interface AuthState {
  /** Current authenticated admin's role records */
  roles: AdminRoleRecord[];
  /** Admin's profile info for display (TopBar, etc.) */
  adminProfile: AdminProfile | null;
  /** Whether initial auth check has completed */
  initialized: boolean;
  /** Whether auth check is in progress */
  loading: boolean;

  setRoles: (roles: AdminRoleRecord[]) => void;
  setAdminProfile: (profile: AdminProfile | null) => void;
  setInitialized: (initialized: boolean) => void;
  setLoading: (loading: boolean) => void;
  logout: () => void;
}

export const useAuthStore = create<AuthState>((set) => ({
  roles: [],
  adminProfile: null,
  initialized: false,
  loading: true,

  setRoles: (roles) => set({ roles, loading: false }),
  setAdminProfile: (adminProfile) => set({ adminProfile }),
  setInitialized: (initialized) => set({ initialized }),
  setLoading: (loading) => set({ loading }),
  logout: () => set({ roles: [], adminProfile: null, initialized: false }),
}));

// ─── Derived helpers ──────────────────────────────────────

/** Role hierarchy priority map */
const ROLE_PRIORITY: Record<AdminRoleName, number> = {
  school_reviewer: 1,
  school_admin: 2,
  platform_reviewer: 3,
  platform_admin: 4,
  sysadmin: 5,
};

/** Get the highest role from a list of role records */
export function getHighestRole(roles: AdminRoleRecord[]): AdminRoleName | null {
  const active = roles.filter((r) => r.is_active);
  if (active.length === 0) return null;

  return active.reduce<AdminRoleName>((highest, r) => {
    const current = ROLE_PRIORITY[r.role] ?? 0;
    const best = ROLE_PRIORITY[highest] ?? 0;
    return current > best ? r.role : highest;
  }, active[0].role);
}

/** Check if the user is a sysadmin */
export function isSysadmin(roles: AdminRoleRecord[]): boolean {
  return roles.some((r) => r.is_active && r.role === 'sysadmin' && r.scope_type === 'platform');
}

/** Check if the user is any kind of admin */
export function isAnyAdmin(roles: AdminRoleRecord[]): boolean {
  return roles.some((r) => r.is_active);
}

/** Get college IDs from school-scoped roles */
export function getSchoolScopeIds(roles: AdminRoleRecord[]): string[] {
  return roles
    .filter((r) => r.is_active && r.scope_type === 'school' && r.scope_id)
    .map((r) => r.scope_id!)
    // Remove duplicates
    .filter((id, idx, arr) => arr.indexOf(id) === idx);
}


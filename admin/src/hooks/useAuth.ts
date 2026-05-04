/**
 * Auth hook — handles login, logout, and admin verification.
 * Verifies the user has entries in the unified admin_roles table
 * after Supabase auth (migration 00102).
 */
import { useCallback, useEffect } from 'react';
import { supabase } from '@/lib/supabase';
import { useAuthStore, isSysadmin, getSchoolScopeIds } from '@/stores/auth-store';
import { useSchoolScopeStore } from '@/stores/school-scope-store';
import { TABLES } from '@/lib/constants';
import type { AdminRoleRecord } from '@/types';

export function useAuth() {
  const { roles, initialized, loading, setRoles, setAdminProfile, setInitialized, setLoading, logout: clearStore } = useAuthStore();

  /** Check if current session user is an admin */
  const checkAdminStatus = useCallback(async (userId: string) => {
    try {
      // Fetch all active role records for this user
      const { data: roleData, error: roleError } = await supabase
        .from(TABLES.ADMIN_ROLES)
        .select('*')
        .eq('user_id', userId)
        .eq('is_active', true);

      if (roleError || !roleData || roleData.length === 0) {
        setRoles([]);
        setAdminProfile(null);
        return false;
      }

      const adminRoles = roleData as AdminRoleRecord[];
      setRoles(adminRoles);

      // Fetch admin's profile info for display in TopBar
      const { data: profileData } = await supabase
        .from(TABLES.USER_PROFILES)
        .select('id, display_name, email, avatar_url')
        .eq('id', userId)
        .single();

      if (profileData) {
        setAdminProfile({
          id: profileData.id,
          display_name: profileData.display_name,
          email: profileData.email,
          avatar_url: profileData.avatar_url,
        });
      }

      // NOTE: Always override school scope on auth-check.
      // This prevents cross-admin data leaks when different admins share a browser.
      const store = useSchoolScopeStore.getState();

      if (isSysadmin(adminRoles)) {
        // Sysadmin: restore last persisted choice or default to platform view
        if (!store.currentCollegeId && !store.isPlatformView) {
          store.setPlatformView();
        }
      } else {
        // Non-sysadmin: derive school access from school-scoped roles
        const schoolIds = getSchoolScopeIds(adminRoles);
        if (schoolIds.length > 0) {
          const lastStored = localStorage.getItem('smivo_admin_last_school');
          if (lastStored && schoolIds.includes(lastStored)) {
            store.setCollege(lastStored);
          } else {
            store.setCollege(schoolIds[0]);
          }
        }
      }

      return true;
    } catch {
      setRoles([]);
      setAdminProfile(null);
      return false;
    }
  }, [setRoles, setAdminProfile]);

  /** Initialize auth state on mount */
  useEffect(() => {
    if (initialized) return;

    const initAuth = async () => {
      setLoading(true);
      const { data: { session } } = await supabase.auth.getSession();

      if (session?.user) {
        await checkAdminStatus(session.user.id);
      } else {
        setRoles([]);
      }

      setInitialized(true);
      setLoading(false);
    };

    initAuth();

    // Listen for auth state changes
    const { data: { subscription } } = supabase.auth.onAuthStateChange(async (event, session) => {
      if (event === 'SIGNED_IN' && session?.user) {
        await checkAdminStatus(session.user.id);
      } else if (event === 'SIGNED_OUT') {
        clearStore();
      }
    });

    return () => subscription.unsubscribe();
  }, [initialized, checkAdminStatus, setRoles, setInitialized, setLoading, clearStore]);

  /** Login with email/password */
  const login = useCallback(async (email: string, password: string) => {
    setLoading(true);
    const { data, error } = await supabase.auth.signInWithPassword({ email, password });

    if (error) {
      setLoading(false);
      throw error;
    }

    if (data.user) {
      const isAdmin = await checkAdminStatus(data.user.id);
      if (!isAdmin) {
        setLoading(false);
        await supabase.auth.signOut();
        throw new Error('You do not have access to the Admin panel');
      }
    }

    setLoading(false);
    return data;
  }, [setLoading, checkAdminStatus]);

  /** Logout */
  const logout = useCallback(async () => {
    await supabase.auth.signOut();
    clearStore();
  }, [clearStore]);

  // NOTE: Backward-compatible `admin` object for pages that reference admin.user_id.
  // Derives the user_id from the first role record and profile info from adminProfile.
  const { adminProfile } = useAuthStore();
  const admin = roles.length > 0
    ? {
        user_id: roles[0].user_id,
        display_name: adminProfile?.display_name ?? null,
        email: adminProfile?.email ?? '',
        role: roles[0].role,
      }
    : null;

  return {
    roles,
    admin,
    initialized,
    loading,
    isAuthenticated: roles.length > 0,
    login,
    logout,
  };
}

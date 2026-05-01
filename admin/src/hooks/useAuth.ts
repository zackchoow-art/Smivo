/**
 * Auth hook — handles login, logout, and admin verification.
 * Verifies the user exists in admin_users table after Supabase auth.
 */
import { useCallback, useEffect } from 'react';
import { supabase } from '@/lib/supabase';
import { useAuthStore } from '@/stores/auth-store';
import { useSchoolScopeStore } from '@/stores/school-scope-store';
import { TABLES } from '@/lib/constants';
import type { AdminUser, AdminSchoolScope } from '@/types';

export function useAuth() {
  const { admin, scopes, initialized, loading, setAdmin, setInitialized, setLoading, logout: clearStore } = useAuthStore();

  /** Check if current session user is an admin */
  const checkAdminStatus = useCallback(async (userId: string) => {
    try {
      // Fetch admin record
      const { data: adminData, error: adminError } = await supabase
        .from(TABLES.ADMIN_USERS)
        .select('*')
        .eq('user_id', userId)
        .eq('is_active', true)
        .single();

      if (adminError || !adminData) {
        setAdmin(null);
        return false;
      }

      // Fetch school scopes
      const { data: scopeData } = await supabase
        .from(TABLES.ADMIN_SCHOOL_SCOPES)
        .select('*')
        .eq('admin_user_id', userId);

      setAdmin(adminData as AdminUser, (scopeData || []) as AdminSchoolScope[]);

      // Auto-set school scope if not already set
      const store = useSchoolScopeStore.getState();
      if (!store.currentCollegeId && scopeData && scopeData.length > 0) {
        store.setCollege(scopeData[0].college_id);
      }

      return true;
    } catch {
      setAdmin(null);
      return false;
    }
  }, [setAdmin]);

  /** Initialize auth state on mount */
  useEffect(() => {
    if (initialized) return;

    const initAuth = async () => {
      setLoading(true);
      const { data: { session } } = await supabase.auth.getSession();

      if (session?.user) {
        await checkAdminStatus(session.user.id);
      } else {
        setAdmin(null);
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
  }, [initialized, checkAdminStatus, setAdmin, setInitialized, setLoading, clearStore]);

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

  return {
    admin,
    scopes,
    initialized,
    loading,
    isAuthenticated: !!admin,
    login,
    logout,
  };
}

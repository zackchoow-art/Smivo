/**
 * Zustand store for admin authentication state.
 * Persists across page refreshes via Supabase session.
 */
import { create } from 'zustand';
import type { AdminUser, AdminSchoolScope } from '@/types';

interface AuthState {
  /** Current authenticated admin user */
  admin: AdminUser | null;
  /** School scopes the admin has access to */
  scopes: AdminSchoolScope[];
  /** Whether initial auth check has completed */
  initialized: boolean;
  /** Whether auth check is in progress */
  loading: boolean;

  setAdmin: (admin: AdminUser | null, scopes?: AdminSchoolScope[]) => void;
  setInitialized: (initialized: boolean) => void;
  setLoading: (loading: boolean) => void;
  logout: () => void;
}

export const useAuthStore = create<AuthState>((set) => ({
  admin: null,
  scopes: [],
  initialized: false,
  loading: true,

  setAdmin: (admin, scopes = []) => set({ admin, scopes, loading: false }),
  setInitialized: (initialized) => set({ initialized }),
  setLoading: (loading) => set({ loading }),
  logout: () => set({ admin: null, scopes: [], initialized: false }),
}));

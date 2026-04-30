/**
 * Zustand store for school scope state.
 * Controls which school's data the admin is currently viewing.
 * Persists selection in localStorage per 04_ADMIN_WEB_SPEC.md §4.3.
 */
import { create } from 'zustand';
import { LS_KEYS } from '@/lib/constants';

interface SchoolScopeState {
  /** Currently selected college_id, or null for "platform-wide" view */
  currentCollegeId: string | null;
  /** Whether this is the platform-wide aggregate view */
  isPlatformView: boolean;

  setCollege: (collegeId: string) => void;
  setPlatformView: () => void;
}

export const useSchoolScopeStore = create<SchoolScopeState>((set) => ({
  currentCollegeId: localStorage.getItem(LS_KEYS.LAST_SCHOOL) || null,
  isPlatformView: false,

  setCollege: (collegeId: string) => {
    localStorage.setItem(LS_KEYS.LAST_SCHOOL, collegeId);
    set({ currentCollegeId: collegeId, isPlatformView: false });
  },

  setPlatformView: () => {
    set({ currentCollegeId: null, isPlatformView: true });
  },
}));

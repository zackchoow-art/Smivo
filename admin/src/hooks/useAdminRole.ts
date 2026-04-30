/**
 * Hook for checking admin role and permissions.
 * Centralized RBAC logic per 04_ADMIN_WEB_SPEC.md §3 role matrix.
 */
import { useMemo } from 'react';
import { useAuthStore } from '@/stores/auth-store';
import { useSchoolScopeStore } from '@/stores/school-scope-store';
import { ADMIN_ROLES } from '@/lib/constants';

export function useAdminRole() {
  const { admin, scopes } = useAuthStore();
  const { currentCollegeId } = useSchoolScopeStore();

  const role = admin?.role;

  const permissions = useMemo(() => {
    const isSuperAdmin = role === ADMIN_ROLES.PLATFORM_SUPER_ADMIN;
    const isModerator = role === ADMIN_ROLES.PLATFORM_MODERATOR;
    const isSchoolAdmin = role === ADMIN_ROLES.SCHOOL_ADMIN;

    // Check if admin has access to current school scope
    const hasCurrentSchoolAccess = isSuperAdmin || scopes.some(
      (s) => s.college_id === currentCollegeId
    );

    return {
      isSuperAdmin,
      isModerator,
      isSchoolAdmin,

      // Menu visibility (04 §3 role matrix)
      canViewDashboard: true,
      canViewModeration: true,
      canViewSensitiveWords: isSuperAdmin || isModerator,
      canViewUsers: true,
      canViewFeedback: true,
      canViewPush: true,
      canViewAnalytics: true,
      canViewDictionary: isSuperAdmin || isModerator,
      canEditDictionary: isSuperAdmin,
      canViewFeatureFlags: isSuperAdmin,
      canViewAdminManagement: isSuperAdmin || isSchoolAdmin,
      canViewCollegeManagement: isSuperAdmin,
      canViewAuditLog: true,

      // Operational permissions
      canBanUser: true,
      canPushPlatformWide: isSuperAdmin,
      canManageAllSchools: isSuperAdmin,
      hasCurrentSchoolAccess,

      // School switcher visibility
      showSchoolSwitcher: isSuperAdmin || (isModerator && scopes.length > 1),
      showPlatformView: isSuperAdmin,
    };
  }, [role, scopes, currentCollegeId]);

  return { role, ...permissions };
}

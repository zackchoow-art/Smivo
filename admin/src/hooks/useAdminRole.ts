/**
 * Hook for checking admin role and permissions.
 *
 * Permission model (migration 00068):
 *   sysadmin           — full control
 *   platform_admin     — cross-school management (soft + hard restrictions)
 *   platform_reviewer  — cross-school moderation (soft restrictions only)
 *   school_admin       — per-school management (soft + hard restrictions)
 *   school_reviewer    — per-school moderation (soft restrictions only)
 *
 * "Soft restrictions": mute, listing ban, feedback ban (user_restrictions table)
 * "Hard ban": freeze/deactivate account (user_bans table)
 */
import { useMemo } from 'react';
import { useAuthStore } from '@/stores/auth-store';
import { useSchoolScopeStore } from '@/stores/school-scope-store';

export function useAdminRole() {
  const { admin, scopes } = useAuthStore();
  const { currentCollegeId } = useSchoolScopeStore();

  const role = admin?.role;

  const permissions = useMemo(() => {
    const isSysadmin         = role === 'sysadmin';
    const isPlatformAdmin    = role === 'platform_admin';
    const isPlatformReviewer = role === 'platform_reviewer';
    const isSchoolAdmin      = role === 'school_admin';
    const isSchoolReviewer   = role === 'school_reviewer';

    // Platform-level roles can cross schools
    const isPlatformLevel = isSysadmin || isPlatformAdmin || isPlatformReviewer;

    // Roles that can perform write/moderation actions (both reviewer levels and above)
    const isModeratorOrAbove = isSysadmin || isPlatformAdmin || isPlatformReviewer
      || isSchoolAdmin || isSchoolReviewer;

    // School scope: does the current admin have access to the currently selected school?
    const hasCurrentSchoolAccess = isSysadmin
      || scopes.some((s) => s.college_id === currentCollegeId);

    // Hard ban: only admins (not reviewers)
    const canHardBan = isSysadmin || isPlatformAdmin || isSchoolAdmin;

    // Soft restrictions: all moderation roles
    const canSoftRestrict = isModeratorOrAbove;

    return {
      // ── Role flags ───────────────────────────────────────────
      isSysadmin,
      isPlatformAdmin,
      isPlatformReviewer,
      isSchoolAdmin,
      isSchoolReviewer,
      isPlatformLevel,
      isModeratorOrAbove,

      // ── Legacy aliases (backward compat with older components) ──
      isSuperAdmin:  isSysadmin,
      isModerator:   isPlatformAdmin,

      // ── Menu visibility ───────────────────────────────────────
      // All moderation roles can see these
      canViewModeration:        isModeratorOrAbove,
      canViewUsers:             isModeratorOrAbove,
      canViewFeedback:          isModeratorOrAbove,
      canViewAnalytics:         isModeratorOrAbove,
      canViewAuditLog:          isSysadmin || isPlatformAdmin || isPlatformReviewer || isSchoolAdmin,

      // Platform admin and above only
      canViewSensitiveWords:    isSysadmin || isPlatformAdmin,
      canViewPush:              isSysadmin || isPlatformAdmin,

      // Dictionary — school admins manage school-level dict only
      canViewDictionary:        isSysadmin || isPlatformAdmin || isSchoolAdmin,

      // Sysadmin only
      canViewFeatureFlags:      isSysadmin,
      canViewAdminManagement:   isSysadmin,
      canViewCollegeManagement: isSysadmin,
      canViewSystemConfigs:     isSysadmin,
      canViewCleanup:           isSysadmin,

      // Purge functions
      canPurgePlatformData:     isSysadmin,
      canPurgeSchoolData:       isSysadmin || isSchoolAdmin,

      // ── Action permissions ────────────────────────────────────
      canHardBan,
      canSoftRestrict,

      // ── Dictionary edit (by level) ───────────────────────────
      // Used by canEditLevel() helper in useDictionary
      canEditSchoolDict:    isSysadmin || isSchoolAdmin,
      canEditPlatformDict:  isSysadmin || isPlatformAdmin,
      canEditSystemDict:    isSysadmin,

      // ── Cross-school context ──────────────────────────────────
      hasCurrentSchoolAccess,
      showSchoolSwitcher: isPlatformLevel || scopes.length > 1,
      showPlatformView:   isPlatformLevel,

      // Accessible school IDs (for filtering queries)
      accessibleSchoolIds: isSysadmin
        ? null  // null = all schools
        : scopes.map((s) => s.college_id),
    };
  }, [role, scopes, currentCollegeId]);

  return { role, ...permissions };
}

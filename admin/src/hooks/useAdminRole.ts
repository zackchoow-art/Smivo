/**
 * Hook for checking admin role and permissions.
 *
 * Now reads from the unified admin_roles table via auth store.
 *
 * Permission model (migration 00102):
 *   sysadmin           — full control
 *   platform_admin     — cross-school management
 *   platform_reviewer  — cross-school moderation
 *   school_admin       — per-school management
 *   school_reviewer    — per-school moderation
 */
import { useMemo } from 'react';
import { useAuthStore, getHighestRole, isSysadmin as checkSysadmin, getSchoolScopeIds } from '@/stores/auth-store';
import { useSchoolScopeStore } from '@/stores/school-scope-store';

export function useAdminRole() {
  const { roles } = useAuthStore();
  const { currentCollegeId } = useSchoolScopeStore();

  const role = getHighestRole(roles);
  const schoolScopeIds = getSchoolScopeIds(roles);

  const permissions = useMemo(() => {
    const _isSysadmin        = checkSysadmin(roles);
    const isPlatformAdmin    = roles.some((r) => r.is_active && r.role === 'platform_admin');
    const isPlatformReviewer = roles.some((r) => r.is_active && r.role === 'platform_reviewer');
    const isSchoolAdmin      = roles.some((r) => r.is_active && r.role === 'school_admin');
    const isSchoolReviewer   = roles.some((r) => r.is_active && r.role === 'school_reviewer');

    // Platform-level roles can cross schools
    const isPlatformLevel = _isSysadmin || isPlatformAdmin || isPlatformReviewer;

    // Roles that can perform write/moderation actions (both reviewer levels and above)
    const isModeratorOrAbove = _isSysadmin || isPlatformAdmin || isPlatformReviewer
      || isSchoolAdmin || isSchoolReviewer;

    // School scope: does the current admin have access to the currently selected school?
    const hasCurrentSchoolAccess = _isSysadmin || isPlatformLevel
      || schoolScopeIds.includes(currentCollegeId ?? '');

    // Hard ban: only admins (not reviewers)
    const canHardBan = _isSysadmin || isPlatformAdmin || isSchoolAdmin;

    // Soft restrictions: all moderation roles
    const canSoftRestrict = isModeratorOrAbove;

    return {
      // ── Role flags ───────────────────────────────────────────
      isSysadmin: _isSysadmin,
      isPlatformAdmin,
      isPlatformReviewer,
      isSchoolAdmin,
      isSchoolReviewer,
      isPlatformLevel,
      isModeratorOrAbove,

      // ── Legacy aliases (backward compat with older components) ──
      isSuperAdmin:  _isSysadmin,
      isModerator:   isPlatformAdmin,

      // ── Menu visibility ───────────────────────────────────────
      canViewModeration:        isModeratorOrAbove,
      canViewUsers:             isModeratorOrAbove,
      canViewFeedback:          isModeratorOrAbove,
      canViewAnalytics:         isModeratorOrAbove,
      canViewAuditLog:          _isSysadmin || isPlatformAdmin || isPlatformReviewer || isSchoolAdmin,

      canViewSensitiveWords:    _isSysadmin,
      canViewPush:              _isSysadmin || isPlatformAdmin,

      canViewDictionary:        _isSysadmin || isPlatformAdmin || isSchoolAdmin,

      canViewFeatureFlags:      _isSysadmin,
      canViewAdminManagement:   _isSysadmin,
      canViewCollegeManagement: _isSysadmin,
      canViewSystemConfigs:     _isSysadmin,
      canViewCleanup:           _isSysadmin,

      canPurgePlatformData:     _isSysadmin,
      canPurgeSchoolData:       _isSysadmin || isSchoolAdmin,

      // ── Carpool management ────────────────────────────────────
      canViewCarpool:           isModeratorOrAbove,
      canEditCarpoolStatus:     _isSysadmin || isPlatformAdmin || isSchoolAdmin,

      // ── Action permissions ────────────────────────────────────
      canHardBan,
      canSoftRestrict,

      // ── Dictionary edit (by level) ───────────────────────────
      canEditSchoolDict:    _isSysadmin || isSchoolAdmin,
      canEditPlatformDict:  _isSysadmin || isPlatformAdmin,
      canEditSystemDict:    _isSysadmin,

      // ── Cross-school context ──────────────────────────────────
      hasCurrentSchoolAccess,
      showSchoolSwitcher: isPlatformLevel || schoolScopeIds.length > 1,
      showPlatformView:   isPlatformLevel,

      // Accessible school IDs (for filtering queries)
      // null = all schools (platform-level access)
      accessibleSchoolIds: isPlatformLevel ? null : schoolScopeIds,
    };
  }, [roles, schoolScopeIds, currentCollegeId]);

  return { role, ...permissions };
}

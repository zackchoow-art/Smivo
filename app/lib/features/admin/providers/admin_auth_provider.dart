import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:smivo/data/models/admin_role.dart';
import 'package:smivo/data/repositories/admin_role_repository.dart';

part 'admin_auth_provider.g.dart';

/// All admin modules that can have permission settings.
enum AdminModule {
  dashboard,
  users,
  listings,
  orders,
  schools,
  categories,
  conditions,
  pickupLocations,
  faqs,
  dictionary,
  roles,
}

/// Permission levels, ordered by access.
enum PermissionLevel { none, read, write }

/// Encapsulates the current user's admin context: their roles
/// and helper methods for authorization.
///
/// Permissions are now derived entirely from the role hierarchy —
/// no more per-module permission overrides (admin_permissions table removed).
class AdminContext {
  final List<AdminRole> roles;

  AdminContext({required this.roles});

  /// Whether the user has any admin role at all.
  bool get isAdmin => roles.any((r) => r.isActive);

  /// Whether the user is a platform-level sysadmin.
  bool get isSysadmin => roles.any(
    (r) => r.isActive && r.role == 'sysadmin' && r.scopeType == 'platform',
  );

  /// The user's highest role across all scopes.
  String get highestRole {
    if (isSysadmin) return 'sysadmin';
    if (_hasActiveRole('platform_admin')) return 'platform_admin';
    if (_hasActiveRole('platform_reviewer')) return 'platform_reviewer';
    if (_hasActiveRole('school_admin')) return 'school_admin';
    if (_hasActiveRole('school_reviewer')) return 'school_reviewer';
    return 'none';
  }

  /// The user's highest role label for display.
  String get highestRoleLabel {
    switch (highestRole) {
      case 'sysadmin':
        return 'Super Admin';
      case 'platform_admin':
        return 'Platform Admin';
      case 'platform_reviewer':
        return 'Platform Reviewer';
      case 'school_admin':
        return 'School Admin';
      case 'school_reviewer':
        return 'School Reviewer';
      default:
        return 'No Access';
    }
  }

  /// Icon for the user's highest role.
  IconData get roleIcon {
    switch (highestRole) {
      case 'sysadmin':
        return Icons.shield;
      case 'platform_admin':
      case 'school_admin':
        return Icons.admin_panel_settings;
      case 'platform_reviewer':
      case 'school_reviewer':
        return Icons.rate_review;
      default:
        return Icons.block;
    }
  }

  /// Check if user has at least [required] permission for [module].
  ///
  /// Optionally scope to a specific [schoolId].
  bool hasPermission(
    AdminModule module, {
    PermissionLevel required = PermissionLevel.read,
    String? schoolId,
  }) {
    final effective = _effectivePermission(module, schoolId: schoolId);
    return effective.index >= required.index;
  }

  /// Get the effective permission level for a module.
  PermissionLevel _effectivePermission(AdminModule module, {String? schoolId}) {
    // Collect applicable roles sorted by priority
    final applicable =
        roles.where((r) {
            if (!r.isActive) return false;
            if (r.scopeType == 'platform') return true;
            if (r.scopeType == 'school') {
              return schoolId == null || r.scopeId == schoolId;
            }
            return false;
          }).toList()
          ..sort((a, b) => _rolePriority(b.role) - _rolePriority(a.role));

    if (applicable.isEmpty) return PermissionLevel.none;

    // NOTE: No more per-module overrides — derive from role hierarchy
    return _defaultPermission(applicable.first.role, module.name);
  }

  /// Get list of module names visible to this user (permission >= read).
  List<AdminModule> get visibleModules {
    return AdminModule.values
        .where((m) => hasPermission(m, required: PermissionLevel.read))
        .toList();
  }

  /// Whether module allows write operations.
  bool canWrite(AdminModule module, {String? schoolId}) {
    return hasPermission(
      module,
      required: PermissionLevel.write,
      schoolId: schoolId,
    );
  }

  // ─── Private helpers ──────────────────────────────────────

  bool _hasActiveRole(String roleName) =>
      roles.any((r) => r.isActive && r.role == roleName);

  static int _rolePriority(String role) {
    switch (role) {
      case 'sysadmin':
        return 5;
      case 'platform_admin':
        return 4;
      case 'platform_reviewer':
        return 3;
      case 'school_admin':
        return 2;
      case 'school_reviewer':
        return 1;
      default:
        return 0;
    }
  }

  /// Default permissions per role per module.
  /// Matches the permission matrix from the migration plan.
  static PermissionLevel _defaultPermission(String role, String module) {
    switch (role) {
      case 'sysadmin':
        // NOTE: Sysadmin has write access to everything
        return PermissionLevel.write;

      case 'platform_admin':
        // Same as school_admin but for all schools
        switch (module) {
          case 'roles':
            return PermissionLevel.none;
          case 'schools':
            return PermissionLevel.none;
          default:
            return PermissionLevel.write;
        }

      case 'platform_reviewer':
        // Same as school_reviewer but for all schools
        switch (module) {
          case 'dashboard':
          case 'listings':
          case 'orders':
          case 'users':
            return PermissionLevel.read;
          default:
            return PermissionLevel.none;
        }

      case 'school_admin':
        switch (module) {
          case 'roles':
          case 'schools':
            return PermissionLevel.none;
          case 'users':
            return PermissionLevel.read;
          default:
            return PermissionLevel.write;
        }

      case 'school_reviewer':
        switch (module) {
          case 'dashboard':
          case 'listings':
          case 'orders':
            return PermissionLevel.read;
          default:
            return PermissionLevel.none;
        }

      default:
        return PermissionLevel.none;
    }
  }
}

/// Provider that loads the current user's admin context.
///
/// Used by the admin shell to filter sidebar items and by
/// individual admin screens to gate write operations.
@riverpod
Future<AdminContext> adminContext(Ref ref) async {
  final repo = ref.watch(adminRoleRepositoryProvider);
  final roles = await repo.fetchMyRoles();

  // NOTE: No more permission override loading — role hierarchy is the sole
  // source of truth for access control (admin_permissions table removed)
  return AdminContext(roles: roles);
}

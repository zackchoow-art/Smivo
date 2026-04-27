import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:smivo/data/models/admin_role.dart';
import 'package:smivo/data/models/admin_permission.dart';
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
enum PermissionLevel {
  none,
  read,
  write,
}

/// Encapsulates the current user's admin context: their roles,
/// permission overrides, and helper methods for authorization.
class AdminContext {
  final List<AdminRole> roles;
  final Map<String, List<AdminPermission>> _overrides; // roleId -> perms

  AdminContext({
    required this.roles,
    Map<String, List<AdminPermission>>? overrides,
  }) : _overrides = overrides ?? {};

  /// Whether the user has any admin role at all.
  bool get isAdmin => roles.any((r) => r.isActive);

  /// Whether the user is a platform-level sysadmin.
  bool get isSysadmin => roles.any(
        (r) => r.isActive && r.role == 'sysadmin' && r.scopeType == 'platform',
      );

  /// The user's highest role across all scopes.
  String get highestRole {
    if (isSysadmin) return 'sysadmin';
    if (roles.any((r) => r.isActive && r.role == 'admin')) return 'admin';
    if (roles.any((r) => r.isActive && r.role == 'operator')) return 'operator';
    return 'none';
  }

  /// The user's highest role label for display.
  String get highestRoleLabel {
    switch (highestRole) {
      case 'sysadmin':
        return 'System Admin';
      case 'admin':
        return 'Admin';
      case 'operator':
        return 'Operator';
      default:
        return 'No Access';
    }
  }

  /// Icon for the user's highest role.
  IconData get roleIcon {
    switch (highestRole) {
      case 'sysadmin':
        return Icons.shield;
      case 'admin':
        return Icons.admin_panel_settings;
      case 'operator':
        return Icons.person;
      default:
        return Icons.block;
    }
  }

  /// Check if user has at least [required] permission for [module].
  ///
  /// Optionally scope to a specific [schoolId].
  /// Logic: find best applicable role → check overrides → fall back to defaults.
  bool hasPermission(
    AdminModule module, {
    PermissionLevel required = PermissionLevel.read,
    String? schoolId,
  }) {
    final effective = _effectivePermission(module, schoolId: schoolId);
    return effective.index >= required.index;
  }

  /// Get the effective permission level for a module.
  PermissionLevel _effectivePermission(
    AdminModule module, {
    String? schoolId,
  }) {
    final moduleName = module.name;

    // Collect applicable roles sorted by priority (sysadmin > admin > operator)
    final applicable = roles.where((r) {
      if (!r.isActive) return false;
      if (r.scopeType == 'platform') return true;
      if (r.scopeType == 'school') {
        return schoolId == null || r.scopeId == schoolId;
      }
      return false;
    }).toList()
      ..sort((a, b) => _rolePriority(b.role) - _rolePriority(a.role));

    if (applicable.isEmpty) return PermissionLevel.none;

    // Check each role from highest to lowest for overrides
    for (final role in applicable) {
      final overrides = _overrides[role.id];
      if (overrides != null) {
        final match = overrides.where((p) => p.module == moduleName);
        if (match.isNotEmpty) {
          return _parsePermission(match.first.permission);
        }
      }
    }

    // No overrides found → use default for highest role
    return _defaultPermission(applicable.first.role, moduleName);
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

  static int _rolePriority(String role) {
    switch (role) {
      case 'sysadmin':
        return 3;
      case 'admin':
        return 2;
      case 'operator':
        return 1;
      default:
        return 0;
    }
  }

  static PermissionLevel _parsePermission(String perm) {
    switch (perm) {
      case 'write':
        return PermissionLevel.write;
      case 'read':
        return PermissionLevel.read;
      default:
        return PermissionLevel.none;
    }
  }

  /// Default permissions per role per module.
  static PermissionLevel _defaultPermission(String role, String module) {
    switch (role) {
      case 'sysadmin':
        // NOTE: Sysadmin has write access to everything
        return PermissionLevel.write;

      case 'admin':
        switch (module) {
          case 'schools':
          case 'dictionary':
          case 'roles':
            return PermissionLevel.none;
          case 'users':
            return PermissionLevel.read;
          default:
            return PermissionLevel.write;
        }

      case 'operator':
        switch (module) {
          case 'dashboard':
          case 'listings':
          case 'orders':
          case 'faqs':
          case 'pickupLocations':
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
Future<AdminContext> adminContext(AdminContextRef ref) async {
  final repo = ref.watch(adminRoleRepositoryProvider);

  final roles = await repo.fetchMyRoles();

  // Load permission overrides for each role
  final overrides = <String, List<AdminPermission>>{};
  for (final role in roles) {
    final perms = await repo.fetchPermissionsForRole(role.id);
    if (perms.isNotEmpty) {
      overrides[role.id] = perms;
    }
  }

  return AdminContext(roles: roles, overrides: overrides);
}

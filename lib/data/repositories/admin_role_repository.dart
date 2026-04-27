import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:smivo/data/models/admin_role.dart';
import 'package:smivo/data/models/admin_permission.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'admin_role_repository.g.dart';

/// Repository for admin role CRUD and permission queries.
class AdminRoleRepository {
  final SupabaseClient _client;

  AdminRoleRepository(this._client);

  // ─── Roles ───────────────────────────────────────────────

  /// Fetch all admin roles with joined user/school info.
  Future<List<AdminRole>> fetchAllRoles() async {
    final res = await _client
        .from('admin_roles')
        .select('''
          *,
          user_profiles!inner(email, display_name),
          schools(name)
        ''')
        .order('created_at', ascending: false);

    return (res as List).map((row) {
      final userProfile = row['user_profiles'] as Map<String, dynamic>?;
      final school = row['schools'] as Map<String, dynamic>?;
      return AdminRole.fromJson({
        ...row,
        'user_email': userProfile?['email'],
        'user_name': userProfile?['display_name'],
        'school_name': school?['name'],
      });
    }).toList();
  }

  /// Fetch roles for a specific user.
  Future<List<AdminRole>> fetchRolesForUser(String userId) async {
    final res = await _client
        .from('admin_roles')
        .select('''
          *,
          schools(name)
        ''')
        .eq('user_id', userId)
        .order('scope_type');

    return (res as List).map((row) {
      final school = row['schools'] as Map<String, dynamic>?;
      return AdminRole.fromJson({
        ...row,
        'school_name': school?['name'],
      });
    }).toList();
  }

  /// Fetch the current user's own roles (for permission checking).
  Future<List<AdminRole>> fetchMyRoles() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return [];
    return fetchRolesForUser(userId);
  }

  /// Create a new admin role assignment.
  Future<void> createRole({
    required String userId,
    required String role,
    required String scopeType,
    String? scopeId,
  }) async {
    await _client.from('admin_roles').insert({
      'user_id': userId,
      'role': role,
      'scope_type': scopeType,
      'scope_id': scopeId,
    });
  }

  /// Update an existing admin role.
  Future<void> updateRole(String id, {String? role, bool? isActive}) async {
    final updates = <String, dynamic>{};
    if (role != null) updates['role'] = role;
    if (isActive != null) updates['is_active'] = isActive;
    if (updates.isEmpty) return;

    await _client.from('admin_roles').update(updates).eq('id', id);
  }

  /// Delete an admin role assignment.
  Future<void> deleteRole(String id) async {
    await _client.from('admin_roles').delete().eq('id', id);
  }

  // ─── Permissions ──────────────────────────────────────────

  /// Fetch all permission overrides for a specific role assignment.
  Future<List<AdminPermission>> fetchPermissionsForRole(String roleId) async {
    final res = await _client
        .from('admin_permissions')
        .select()
        .eq('role_id', roleId)
        .order('module');

    return (res as List)
        .map((row) => AdminPermission.fromJson(row))
        .toList();
  }

  /// Upsert a permission override.
  Future<void> upsertPermission({
    required String roleId,
    required String module,
    required String permission,
  }) async {
    await _client.from('admin_permissions').upsert({
      'role_id': roleId,
      'module': module,
      'permission': permission,
    }, onConflict: 'role_id, module');
  }

  /// Delete a permission override (reverts to role default).
  Future<void> deletePermission(String id) async {
    await _client.from('admin_permissions').delete().eq('id', id);
  }

  /// Delete all permission overrides for a role.
  Future<void> deleteAllPermissionsForRole(String roleId) async {
    await _client.from('admin_permissions').delete().eq('role_id', roleId);
  }
}

@riverpod
AdminRoleRepository adminRoleRepository(AdminRoleRepositoryRef ref) {
  return AdminRoleRepository(Supabase.instance.client);
}

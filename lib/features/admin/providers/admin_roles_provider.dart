import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:smivo/data/models/admin_role.dart';
import 'package:smivo/data/repositories/admin_role_repository.dart';

part 'admin_roles_provider.g.dart';

/// Provides all admin role assignments for the roles management screen.
@riverpod
Future<List<AdminRole>> adminRoles(AdminRolesRef ref) async {
  return ref.watch(adminRoleRepositoryProvider).fetchAllRoles();
}

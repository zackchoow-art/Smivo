import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:smivo/data/repositories/admin_repository.dart';

part 'admin_users_provider.g.dart';

/// Fetches all registered users for the admin panel.
@riverpod
Future<List<Map<String, dynamic>>> adminUsers(Ref ref) async {
  return ref.watch(adminRepositoryProvider).fetchAllUsers();
}

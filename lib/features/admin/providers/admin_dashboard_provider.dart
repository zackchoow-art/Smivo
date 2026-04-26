import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:smivo/data/repositories/admin_repository.dart';

part 'admin_dashboard_provider.g.dart';

@riverpod
Future<DashboardMetrics> adminDashboardMetrics(Ref ref) async {
  return ref.watch(adminRepositoryProvider).fetchDashboardMetrics();
}

@riverpod
Future<List<Map<String, dynamic>>> adminRecentOrders(Ref ref) async {
  return ref.watch(adminRepositoryProvider).fetchRecentOrders(limit: 10);
}

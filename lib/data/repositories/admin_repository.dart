import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:smivo/core/exceptions/app_exception.dart';
import 'package:smivo/core/providers/supabase_provider.dart';

part 'admin_repository.g.dart';

@riverpod
AdminRepository adminRepository(Ref ref) {
  return AdminRepository(ref.watch(supabaseClientProvider));
}

class DashboardMetrics {
  final int totalUsers;
  final int activeListings;
  final int completedOrders;
  final int pendingOrders;

  DashboardMetrics({
    required this.totalUsers,
    required this.activeListings,
    required this.completedOrders,
    required this.pendingOrders,
  });
}

class AdminRepository {
  final SupabaseClient _client;

  AdminRepository(this._client);

  Future<DashboardMetrics> fetchDashboardMetrics() async {
    try {
      final usersRes = await _client.from('user_profiles').select('id').count(CountOption.exact);
      final listingsRes = await _client.from('listings').select('id').eq('status', 'active').count(CountOption.exact);
      final completedOrdersRes = await _client.from('orders').select('id').eq('status', 'completed').count(CountOption.exact);
      final pendingOrdersRes = await _client.from('orders').select('id').eq('status', 'pending').count(CountOption.exact);

      return DashboardMetrics(
        totalUsers: usersRes.count,
        activeListings: listingsRes.count,
        completedOrders: completedOrdersRes.count,
        pendingOrders: pendingOrdersRes.count,
      );
    } on PostgrestException catch (e) {
      throw DatabaseException(e.message);
    } catch (e) {
      throw NetworkException(e.toString());
    }
  }
}

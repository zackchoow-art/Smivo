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
  final int totalOrders;
  final int totalListings;
  final int totalSchools;
  final int totalCategories;

  DashboardMetrics({
    required this.totalUsers,
    required this.activeListings,
    required this.completedOrders,
    required this.pendingOrders,
    required this.totalOrders,
    required this.totalListings,
    required this.totalSchools,
    required this.totalCategories,
  });
}

class AdminRepository {
  final SupabaseClient _client;

  AdminRepository(this._client);

  /// Fetches aggregate dashboard metrics from multiple tables.
  Future<DashboardMetrics> fetchDashboardMetrics() async {
    try {
      final usersRes = await _client.from('user_profiles').select('id').count(CountOption.exact);
      final listingsRes = await _client.from('listings').select('id').count(CountOption.exact);
      final activeListingsRes = await _client.from('listings').select('id').eq('status', 'active').count(CountOption.exact);
      final ordersRes = await _client.from('orders').select('id').count(CountOption.exact);
      final completedOrdersRes = await _client.from('orders').select('id').eq('status', 'completed').count(CountOption.exact);
      final pendingOrdersRes = await _client.from('orders').select('id').eq('status', 'pending').count(CountOption.exact);
      final schoolsRes = await _client.from('schools').select('id').count(CountOption.exact);

      final categoriesRes = await _client.from('school_categories').select('id').count(CountOption.exact);

      return DashboardMetrics(
        totalUsers: usersRes.count,
        activeListings: activeListingsRes.count,
        completedOrders: completedOrdersRes.count,
        pendingOrders: pendingOrdersRes.count,
        totalOrders: ordersRes.count,
        totalListings: listingsRes.count,
        totalSchools: schoolsRes.count,
        totalCategories: categoriesRes.count,
      );
    } on PostgrestException catch (e) {
      throw DatabaseException(e.message);
    } catch (e) {
      throw NetworkException(e.toString());
    }
  }

  /// Fetches all registered users with profile info.
  Future<List<Map<String, dynamic>>> fetchAllUsers() async {
    try {
      final data = await _client
          .from('user_profiles')
          .select('id, email, display_name, avatar_url, school_id, created_at, updated_at')
          .order('created_at', ascending: false);

      // Enrich with school name
      final schools = await _client.from('schools').select('id, name');
      final schoolMap = <String, String>{};
      for (final s in schools) {
        schoolMap[s['id']] = s['name'];
      }

      return (data as List).map((u) {
        final m = Map<String, dynamic>.from(u);
        m['school_name'] = schoolMap[m['school_id']] ?? 'Unknown';
        // NOTE: email_verified is approximated by presence of email
        m['email_verified'] = m['email'] != null && (m['email'] as String).isNotEmpty;
        return m;
      }).toList();
    } on PostgrestException catch (e) {
      throw DatabaseException(e.message);
    } catch (e) {
      throw NetworkException(e.toString());
    }
  }

  /// Fetches all listings with seller name.
  Future<List<Map<String, dynamic>>> fetchAllListings() async {
    try {
      final data = await _client
          .from('listings')
          .select('id, title, description, category, price, listing_type, status, condition, created_at, seller_id')
          .order('created_at', ascending: false);

      // Enrich with seller names
      final profiles = await _client.from('user_profiles').select('id, display_name');
      final nameMap = <String, String>{};
      for (final p in profiles) {
        nameMap[p['id']] = p['display_name'] ?? 'Unknown';
      }

      return (data as List).map((l) {
        final m = Map<String, dynamic>.from(l);
        m['seller_name'] = nameMap[m['seller_id']] ?? 'Unknown';
        return m;
      }).toList();
    } on PostgrestException catch (e) {
      throw DatabaseException(e.message);
    } catch (e) {
      throw NetworkException(e.toString());
    }
  }

  /// Fetches all orders with buyer/seller names and listing title.
  Future<List<Map<String, dynamic>>> fetchAllOrders() async {
    try {
      final data = await _client
          .from('orders')
          .select('id, listing_id, buyer_id, seller_id, status, order_type, total_price, created_at')
          .order('created_at', ascending: false);

      // Enrich with names and listing titles
      final profiles = await _client.from('user_profiles').select('id, display_name');
      final nameMap = <String, String>{};
      for (final p in profiles) {
        nameMap[p['id']] = p['display_name'] ?? 'Unknown';
      }

      final listings = await _client.from('listings').select('id, title');
      final titleMap = <String, String>{};
      for (final l in listings) {
        titleMap[l['id']] = l['title'] ?? 'Unknown';
      }

      return (data as List).map((o) {
        final m = Map<String, dynamic>.from(o);
        m['buyer_name'] = nameMap[m['buyer_id']] ?? 'Unknown';
        m['seller_name'] = nameMap[m['seller_id']] ?? 'Unknown';
        m['listing_title'] = titleMap[m['listing_id']] ?? 'Unknown';
        return m;
      }).toList();
    } on PostgrestException catch (e) {
      throw DatabaseException(e.message);
    } catch (e) {
      throw NetworkException(e.toString());
    }
  }

  /// Fetches recent orders for the dashboard activity feed.
  Future<List<Map<String, dynamic>>> fetchRecentOrders({int limit = 10}) async {
    try {
      final data = await _client
          .from('orders')
          .select('id, listing_id, buyer_id, status, order_type, total_price, created_at')
          .order('created_at', ascending: false)
          .limit(limit);

      final profiles = await _client.from('user_profiles').select('id, display_name');
      final nameMap = <String, String>{};
      for (final p in profiles) {
        nameMap[p['id']] = p['display_name'] ?? 'Unknown';
      }

      final listings = await _client.from('listings').select('id, title');
      final titleMap = <String, String>{};
      for (final l in listings) {
        titleMap[l['id']] = l['title'] ?? 'Unknown';
      }

      return (data as List).map((o) {
        final m = Map<String, dynamic>.from(o);
        m['buyer_name'] = nameMap[m['buyer_id']] ?? 'Unknown';
        m['listing_title'] = titleMap[m['listing_id']] ?? 'Unknown';
        return m;
      }).toList();
    } on PostgrestException catch (e) {
      throw DatabaseException(e.message);
    } catch (e) {
      throw NetworkException(e.toString());
    }
  }

  /// Clears all user-generated test data while preserving system config.
  ///
  /// Deletion order respects FK constraints:
  /// order_evidence → rental_extensions → messages → chat_rooms →
  /// notifications → saved_listings → orders → listing_images → listings
  ///
  /// Preserved tables: schools, school_categories, school_conditions,
  /// pickup_locations, faqs, system_dictionaries, admin_roles,
  /// admin_permissions, user_profiles (auth users)
  Future<Map<String, int>> clearTestData() async {
    try {
      final counts = <String, int>{};

      // 1. Order evidence (references orders)
      final ev = await _client.from('order_evidence').select('id');
      await _client.from('order_evidence').delete().gte('created_at', '2000-01-01');
      counts['order_evidence'] = (ev as List).length;

      // 2. Rental extensions (references orders)
      final re = await _client.from('rental_extensions').select('id');
      await _client.from('rental_extensions').delete().gte('created_at', '2000-01-01');
      counts['rental_extensions'] = (re as List).length;

      // 3. Messages (references chat_rooms)
      final msg = await _client.from('messages').select('id');
      await _client.from('messages').delete().gte('created_at', '2000-01-01');
      counts['messages'] = (msg as List).length;

      // 4. Chat rooms (references listings)
      final cr = await _client.from('chat_rooms').select('id');
      await _client.from('chat_rooms').delete().gte('created_at', '2000-01-01');
      counts['chat_rooms'] = (cr as List).length;

      // 5. Notifications
      final notif = await _client.from('notifications').select('id');
      await _client.from('notifications').delete().gte('created_at', '2000-01-01');
      counts['notifications'] = (notif as List).length;

      // 6. Saved listings (references listings)
      final sl = await _client.from('saved_listings').select('id');
      await _client.from('saved_listings').delete().gte('created_at', '2000-01-01');
      counts['saved_listings'] = (sl as List).length;

      // 7. Orders (references listings)
      final ord = await _client.from('orders').select('id');
      await _client.from('orders').delete().gte('created_at', '2000-01-01');
      counts['orders'] = (ord as List).length;

      // 8. Listing images (references listings)
      final li = await _client.from('listing_images').select('id');
      await _client.from('listing_images').delete().gte('created_at', '2000-01-01');
      counts['listing_images'] = (li as List).length;

      // 9. Listings
      final lst = await _client.from('listings').select('id');
      await _client.from('listings').delete().gte('created_at', '2000-01-01');
      counts['listings'] = (lst as List).length;

      return counts;
    } on PostgrestException catch (e) {
      throw DatabaseException(e.message);
    } catch (e) {
      throw NetworkException(e.toString());
    }
  }
}

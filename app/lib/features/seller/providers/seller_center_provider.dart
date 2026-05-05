import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:smivo/data/models/order.dart';
import 'package:smivo/data/models/listing.dart';
import 'package:smivo/data/repositories/listing_repository.dart';

import 'package:smivo/features/auth/providers/auth_provider.dart';

import 'package:smivo/features/orders/providers/orders_provider.dart';
import 'package:smivo/features/home/providers/home_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:smivo/core/providers/supabase_provider.dart';

part 'seller_center_provider.g.dart';

/// Fetches all listings owned by the current user with realtime updates.
@riverpod
class MyListings extends _$MyListings {
  RealtimeChannel? _channel;

  @override
  Future<List<Listing>> build() async {
    final user = ref.watch(authStateProvider).value;
    if (user == null) return [];

    ref.onDispose(() {
      _channel?.unsubscribe();
      _channel = null;
    });

    _subscribe(user.id);

    final repo = ref.watch(listingRepositoryProvider);
    return repo.fetchUserListings(user.id);
  }

  void _subscribe(String userId) {
    final client = ref.read(supabaseClientProvider);
    _channel =
        client
            .channel('my_listings:$userId')
            .onPostgresChanges(
              event: PostgresChangeEvent.all,
              schema: 'public',
              table: 'listings',
              filter: PostgresChangeFilter(
                type: PostgresChangeFilterType.eq,
                column: 'seller_id',
                value: userId,
              ),
              callback: (payload) {
                ref.invalidateSelf();
              },
            )
            .subscribe();
  }
}

/// Fetches all orders where the current user is the seller.
@riverpod
Future<List<Order>> sellerOrders(Ref ref) async {
  final user = ref.watch(authStateProvider).value;
  if (user == null) return [];

  final allOrders = await ref.watch(allOrdersProvider.future);
  return allOrders.where((o) => o.sellerId == user.id).toList();
}

/// Handles the seller-initiated relist action.
///
/// Calls [relistListing] RPC which atomically:
///   - Sets listing status back to 'active'
///   - Increments listing_cycle to isolate previous cancelled offers
///
/// After completion, both [myListingsProvider] and [allOrdersProvider]
/// are invalidated so the Seller Center rebuilds with fresh data.
@riverpod
class RelistActions extends _$RelistActions {
  @override
  AsyncValue<void> build() => const AsyncValue.data(null);

  Future<void> relist(String listingId) async {
    if (state.isLoading) return;
    state = const AsyncValue.loading();
    try {
      final repo = ref.read(listingRepositoryProvider);
      await repo.relistListing(listingId);
      // Refresh both listings and orders so History + Active Listings
      // sections update without requiring a manual pull-to-refresh.
      ref.invalidate(myListingsProvider);
      ref.invalidate(allOrdersProvider);
      ref.invalidate(homeListingsProvider);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }
}

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:smivo/data/models/order.dart';
import 'package:smivo/data/models/saved_listing.dart';
import 'package:smivo/data/repositories/order_repository.dart';
import 'package:smivo/data/repositories/saved_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:smivo/core/providers/supabase_provider.dart';

part 'transaction_stats_provider.g.dart';

/// Fetches all orders for a specific listing with realtime updates.
@riverpod
class ListingOrders extends _$ListingOrders {
  RealtimeChannel? _channel;

  @override
  Future<List<Order>> build(String listingId) async {
    ref.onDispose(() {
      _channel?.unsubscribe();
      _channel = null;
    });

    _subscribe(listingId);

    final repo = ref.watch(orderRepositoryProvider);
    return repo.fetchOrdersByListing(listingId);
  }

  void _subscribe(String listingId) {
    final client = ref.read(supabaseClientProvider);
    _channel =
        client
            .channel('listing_orders:$listingId')
            .onPostgresChanges(
              event: PostgresChangeEvent.all,
              schema: 'public',
              table: 'orders',
              filter: PostgresChangeFilter(
                type: PostgresChangeFilterType.eq,
                column: 'listing_id',
                value: listingId,
              ),
              callback: (payload) {
                ref.invalidateSelf();
              },
            )
            .subscribe();
  }
}

/// Fetches all saves for a specific listing with realtime updates.
@riverpod
class ListingSaves extends _$ListingSaves {
  RealtimeChannel? _channel;

  @override
  Future<List<SavedListing>> build(String listingId) async {
    ref.onDispose(() {
      _channel?.unsubscribe();
      _channel = null;
    });

    _subscribe(listingId);

    final repo = ref.watch(savedRepositoryProvider);
    return repo.fetchSavedByListing(listingId);
  }

  void _subscribe(String listingId) {
    final client = ref.read(supabaseClientProvider);
    _channel =
        client
            .channel('listing_saves:$listingId')
            .onPostgresChanges(
              event: PostgresChangeEvent.all,
              schema: 'public',
              table: 'saved_listings',
              filter: PostgresChangeFilter(
                type: PostgresChangeFilterType.eq,
                column: 'listing_id',
                value: listingId,
              ),
              callback: (payload) {
                ref.invalidateSelf();
              },
            )
            .subscribe();
  }
}

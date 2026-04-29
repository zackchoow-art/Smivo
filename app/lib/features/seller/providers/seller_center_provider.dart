import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:smivo/data/models/order.dart';
import 'package:smivo/data/models/listing.dart';
import 'package:smivo/data/repositories/listing_repository.dart';

import 'package:smivo/features/auth/providers/auth_provider.dart';

import 'package:smivo/features/orders/providers/orders_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:smivo/core/providers/supabase_provider.dart';

part 'seller_center_provider.g.dart';

/// Fetches all listings owned by the current user with realtime updates.
@riverpod
class MyListings extends _$MyListings {
  RealtimeChannel? _channel;

  @override
  Future<List<Listing>> build() async {
    final user = ref.watch(authStateProvider).valueOrNull;
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
  final user = ref.watch(authStateProvider).valueOrNull;
  if (user == null) return [];

  final allOrders = await ref.watch(allOrdersProvider.future);
  return allOrders.where((o) => o.sellerId == user.id).toList();
}

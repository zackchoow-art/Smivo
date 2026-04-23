import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:smivo/data/models/order.dart';
import 'package:smivo/data/models/listing.dart';
import 'package:smivo/data/repositories/listing_repository.dart';
import 'package:smivo/data/repositories/order_repository.dart';
import 'package:smivo/features/auth/providers/auth_provider.dart';

part 'seller_center_provider.g.dart';

/// Fetches all listings owned by the current user.
@riverpod
Future<List<Listing>> myListings(Ref ref) async {
  final user = ref.watch(authStateProvider).valueOrNull;
  if (user == null) return [];
  
  final repo = ref.watch(listingRepositoryProvider);
  return repo.fetchUserListings(user.id);
}

/// Fetches all orders where the current user is the seller.
@riverpod
Future<List<Order>> sellerOrders(Ref ref) async {
  final user = ref.watch(authStateProvider).valueOrNull;
  if (user == null) return [];
  
  final repo = ref.watch(orderRepositoryProvider);
  final allOrders = await repo.fetchOrders(user.id);
  return allOrders.where((o) => o.sellerId == user.id).toList();
}

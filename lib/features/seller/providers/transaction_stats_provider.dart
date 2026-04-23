import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:smivo/data/models/order.dart';
import 'package:smivo/data/models/saved_listing.dart';
import 'package:smivo/data/repositories/order_repository.dart';
import 'package:smivo/data/repositories/saved_repository.dart';

part 'transaction_stats_provider.g.dart';

/// Fetches all orders for a specific listing.
@riverpod
Future<List<Order>> listingOrders(Ref ref, String listingId) async {
  final repo = ref.watch(orderRepositoryProvider);
  return repo.fetchOrdersByListing(listingId);
}

/// Fetches all saves for a specific listing.
@riverpod
Future<List<SavedListing>> listingSaves(Ref ref, String listingId) async {
  final repo = ref.watch(savedRepositoryProvider);
  return repo.fetchSavedByListing(listingId);
}

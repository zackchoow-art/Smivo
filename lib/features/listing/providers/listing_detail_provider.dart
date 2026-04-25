import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smivo/data/models/listing.dart';
import 'package:smivo/data/models/order.dart';
import 'package:smivo/data/repositories/listing_repository.dart';
import 'package:smivo/data/repositories/order_repository.dart';
import 'package:smivo/features/auth/providers/auth_provider.dart';

part 'listing_detail_provider.g.dart';

/// State for the selected rental rate (DAY, WEEK, MONTH).
/// 
/// Defaults to 'MONTH' as per the primary design.
@riverpod
class SelectedRentalRate extends _$SelectedRentalRate {
  @override
  // NOTE: Default to DAY as it's the most commonly enabled rate.
  // The RentalOptionsSection auto-selects the first available rate on build.
  String build() => 'DAY';

  void setRate(String rate) {
    state = rate;
  }
}

/// State for the rental duration stepper (e.g., number of months).
@riverpod
class RentalDuration extends _$RentalDuration {
  @override
  int build() => 1;

  void increment() {
    state++;
  }

  void decrement() {
    if (state > 1) state--;
  }
}

/// State for the selected rental start date.
@riverpod
class RentalStartDate extends _$RentalStartDate {
  @override
  DateTime build() => DateTime.now();

  void setDate(DateTime date) {
    state = date;
  }
}

/// State for the selected rental end date.
@riverpod
class RentalEndDate extends _$RentalEndDate {
  @override
  DateTime build() => DateTime.now().add(const Duration(days: 1));

  void setDate(DateTime date) {
    state = date;
  }
}

/// Fetches a single listing with all joined details (images, seller) from Supabase.
/// 
/// Takes a listing [id] as a parameter.
@riverpod
Future<Listing> listingDetail(Ref ref, String id) async {
  final repository = ref.watch(listingRepositoryProvider);
  final listing = await repository.fetchListing(id);

  // Fire-and-forget: record this view for analytics
  // NOTE: Skip recording if the viewer is the seller (own listing)
  final userId = ref.read(authStateProvider).valueOrNull?.id;
  if (userId != null && userId != listing.sellerId) {
    repository.recordView(listingId: id, viewerId: userId);
  }

  return listing;
}

/// Checks if the current user already has a pending/confirmed order
/// for this listing. Returns the order if found, null otherwise.
@riverpod
Future<Order?> existingBuyerOrder(Ref ref, String listingId) async {
  final user = ref.watch(authStateProvider).valueOrNull;
  if (user == null) return null;
  
  final repo = ref.watch(orderRepositoryProvider);
  return repo.fetchOrderByListingAndBuyer(
    listingId: listingId,
    buyerId: user.id,
  );
}

/// Checks if a listing has any confirmed (in-progress) orders.
///
/// Used to hide the delist button when a rental listing has been accepted
/// by the seller but the listing status is still 'active' (pre-delivery).
@riverpod
Future<bool> listingHasConfirmedOrder(Ref ref, String listingId) async {
  final repo = ref.watch(orderRepositoryProvider);
  return repo.hasConfirmedOrderForListing(listingId);
}

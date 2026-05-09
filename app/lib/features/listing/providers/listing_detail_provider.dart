import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:smivo/core/providers/supabase_provider.dart';
import 'package:smivo/data/models/listing.dart';
import 'package:smivo/data/models/order.dart';
import 'package:smivo/data/repositories/listing_repository.dart';
import 'package:smivo/data/repositories/order_repository.dart';
import 'package:smivo/features/auth/providers/auth_provider.dart';

part 'listing_detail_provider.g.dart';

/// State for the selected rental rate (DAY, WEEK, MONTH).
///
/// Defaults to 'MONTH' as per the primary design.
@Riverpod(keepAlive: true)
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
@Riverpod(keepAlive: true)
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
@Riverpod(keepAlive: true)
class RentalStartDate extends _$RentalStartDate {
  @override
  DateTime build() => DateTime.now();

  void setDate(DateTime date) {
    state = date;
  }
}

/// State for the selected rental end date.
@Riverpod(keepAlive: true)
class RentalEndDate extends _$RentalEndDate {
  @override
  DateTime build() => DateTime.now().add(const Duration(days: 1));

  void setDate(DateTime date) {
    state = date;
  }
}

/// State for the selected sale delivery/pickup start date.
@Riverpod(keepAlive: true)
class SaleStartDate extends _$SaleStartDate {
  @override
  DateTime build() => DateTime.now();

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
  final userId = ref.read(authStateProvider).value?.id;
  // NOTE: Skip recording if the viewer is the seller (own listing)
  if (userId != listing.sellerId) {
    repository.recordView(listingId: id, viewerId: userId);
  }

  return listing;
}

/// Checks if the current user already has a pending/confirmed order
/// for this listing. Returns the order if found, null otherwise.
///
/// NOTE: Subscribes to a Realtime channel scoped to the specific listing so
/// any INSERT/UPDATE on its orders row immediately re-fetches this provider
/// and invalidates listingDetail. This drives the real-time UI update for
/// buttons and status cards when the seller accepts, cancels, etc.
@riverpod
Future<Order?> existingBuyerOrder(Ref ref, String listingId) async {
  final user = ref.watch(authStateProvider).value;
  if (user == null) return null;

  final supabase = ref.watch(supabaseClientProvider);
  final repo = ref.watch(orderRepositoryProvider);

  // Subscribe to order changes for this listing
  final channel = supabase
      .channel('order_changes_$listingId')
      .onPostgresChanges(
        event: PostgresChangeEvent.all,
        schema: 'public',
        table: 'orders',
        filter: PostgresChangeFilter(
          type: PostgresChangeFilterType.eq,
          column: 'listing_id',
          value: listingId,
        ),
        callback: (_) {
          // Re-fetch this provider so the button/card reacts immediately
          ref.invalidateSelf();
          // Also re-fetch the listing itself (e.g. status changes on accept)
          ref.invalidate(listingDetailProvider(listingId));
        },
      )
      .subscribe();

  // Clean up the channel when this provider is disposed or rebuilt
  ref.onDispose(channel.unsubscribe);

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

/// Checks whether the current user is blocked by the seller of a listing.
///
/// Used on the listing detail page to render "Item Unavailable" instead of
/// the order button when the seller has blocked the buyer.
///
/// NOTE: Uses [check_order_eligibility] RPC (SECURITY DEFINER) which ONLY
/// checks the block relationship — not mute or freeze status — so being
/// platform-muted does NOT prevent ordering.
@riverpod
Future<bool> isBlockedBySeller(Ref ref, String sellerId) async {
  final user = ref.watch(authStateProvider).value;
  // Not logged in or viewing own listing — no block check needed.
  if (user == null || user.id == sellerId) return false;

  final repo = ref.watch(orderRepositoryProvider);
  return repo.isBlockedBySeller(buyerId: user.id, sellerId: sellerId);
}

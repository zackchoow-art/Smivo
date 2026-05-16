import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:smivo/data/models/carpool_review.dart';
import 'package:smivo/data/repositories/carpool_repository.dart';
import 'package:smivo/features/carpool/providers/carpool_detail_provider.dart';

part 'carpool_lifecycle_provider.g.dart';

// ── Trip Lifecycle ──────────────────────────────────────────────────────────

/// Manages trip status transitions: active → departed → arrived → completed.
///
/// Each state change invalidates the detail provider so the UI reflects
/// the latest status without a manual pull-to-refresh.
@Riverpod(keepAlive: true)
class TripLifecycle extends _$TripLifecycle {
  @override
  Future<void> build(String tripId) async {}

  /// Marks the trip as departed and refreshes the trip detail.
  Future<void> markDeparted() async {
    state = const AsyncLoading();
    try {
      await ref.read(carpoolRepositoryProvider).markDeparted(tripId);
      ref.invalidate(carpoolDetailProvider(tripId));
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }

  /// Marks the trip as arrived and refreshes the trip detail.
  Future<void> markArrived() async {
    state = const AsyncLoading();
    try {
      await ref.read(carpoolRepositoryProvider).markArrived(tripId);
      ref.invalidate(carpoolDetailProvider(tripId));
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }

  /// Marks the trip as completed and refreshes the trip detail.
  Future<void> markCompleted() async {
    state = const AsyncLoading();
    try {
      await ref.read(carpoolRepositoryProvider).markCompleted(tripId);
      ref.invalidate(carpoolDetailProvider(tripId));
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }

  /// Records the actual total cost and refreshes the trip detail.
  Future<void> settleTripCost(String tripId, double actualTotalCost) async {
    state = const AsyncLoading();
    try {
      await ref.read(carpoolRepositoryProvider).settleTripCost(tripId, actualTotalCost);
      ref.invalidate(carpoolDetailProvider(tripId));
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }
}

// ── Trip Reviews ────────────────────────────────────────────────────────────

/// Loads and manages peer reviews for a completed carpool trip.
@Riverpod(keepAlive: true)
class TripReviews extends _$TripReviews {
  @override
  Future<List<CarpoolReview>> build(String tripId) async {
    return ref.read(carpoolRepositoryProvider).fetchTripReviews(tripId);
  }

  /// Submits a batch of reviews and refreshes the review list.
  ///
  /// NOTE: [reviews] must be pre-constructed with trip_id, reviewer_id,
  /// reviewee_id, rating, and optional comment by the calling widget.
  Future<void> submitReviews(
    String tripId,
    List<Map<String, dynamic>> reviews,
  ) async {
    state = const AsyncLoading();
    try {
      await ref.read(carpoolRepositoryProvider).submitReviews(reviews);
      final newReviews = await ref.read(carpoolRepositoryProvider).fetchTripReviews(tripId);
      state = AsyncData(newReviews);
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }
}

// ── User Carpool Rating ─────────────────────────────────────────────────────

/// Fetches the average carpool rating received by a specific user.
///
/// Returns 0.0 when the user has not been reviewed yet.
@riverpod
Future<double> userCarpoolRating(Ref ref, String userId) async {
  return ref.read(carpoolRepositoryProvider).fetchUserAverageRating(userId);
}

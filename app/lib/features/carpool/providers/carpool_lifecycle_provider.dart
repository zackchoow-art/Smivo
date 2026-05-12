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
@riverpod
class TripLifecycle extends _$TripLifecycle {
  @override
  Future<void> build(String tripId) async {}

  /// Marks the trip as departed and refreshes the trip detail.
  Future<void> markDeparted() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(carpoolRepositoryProvider).markDeparted(tripId);
      // Invalidate so all watchers (detail screen, list) pick up new status.
      ref.invalidate(carpoolDetailProvider(tripId));
    });
  }

  /// Marks the trip as arrived and refreshes the trip detail.
  Future<void> markArrived() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(carpoolRepositoryProvider).markArrived(tripId);
      ref.invalidate(carpoolDetailProvider(tripId));
    });
  }

  /// Marks the trip as completed and refreshes the trip detail.
  Future<void> markCompleted() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(carpoolRepositoryProvider).markCompleted(tripId);
      ref.invalidate(carpoolDetailProvider(tripId));
    });
  }
}

// ── Trip Reviews ────────────────────────────────────────────────────────────

/// Loads and manages peer reviews for a completed carpool trip.
@riverpod
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
    state = await AsyncValue.guard(() async {
      await ref.read(carpoolRepositoryProvider).submitReviews(reviews);
      // Refresh so newly submitted reviews are shown immediately.
      return ref.read(carpoolRepositoryProvider).fetchTripReviews(tripId);
    });
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

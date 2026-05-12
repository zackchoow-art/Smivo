import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:smivo/core/providers/supabase_provider.dart';
import 'package:smivo/data/models/carpool_trip.dart';
import 'package:smivo/data/repositories/carpool_repository.dart';

part 'carpool_trips_provider.g.dart';

/// Fetches active carpool trips for a given school.
///
/// Used by the carpool discovery list to show available trips.
/// Automatically refetches when invalidated after a trip is created/cancelled.
@riverpod
class ActiveCarpoolTrips extends _$ActiveCarpoolTrips {
  @override
  Future<List<CarpoolTrip>> build(String schoolId) async {
    final repo = ref.watch(carpoolRepositoryProvider);
    return repo.fetchActiveTrips(schoolId);
  }

  /// Refresh the trip list (e.g. after creating a new trip).
  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
      () => ref.read(carpoolRepositoryProvider).fetchActiveTrips(
            state.requireValue.isNotEmpty
                ? state.requireValue.first.schoolId
                : '',
          ),
    );
  }
}

/// Fetches all trips the current user has created or joined.
@riverpod
class MyCarpoolTrips extends _$MyCarpoolTrips {
  @override
  Future<List<CarpoolTrip>> build() async {
    final client = ref.watch(supabaseClientProvider);
    final userId = client.auth.currentUser?.id;
    if (userId == null) return [];

    final repo = ref.watch(carpoolRepositoryProvider);
    return repo.fetchMyTrips(userId);
  }
}

/// Fetches a single trip with full details (creator + members).
@riverpod
class CarpoolTripDetail extends _$CarpoolTripDetail {
  @override
  Future<CarpoolTrip> build(String tripId) async {
    final repo = ref.watch(carpoolRepositoryProvider);
    return repo.fetchTripDetail(tripId);
  }
}

/// Handles creating a new carpool trip.
///
/// Returns the created trip on success. The provider layer handles
/// converting location picker data into the format expected by the repo.
@riverpod
class CreateCarpoolTrip extends _$CreateCarpoolTrip {
  @override
  FutureOr<void> build() {}

  Future<CarpoolTrip?> createTrip({
    required String schoolId,
    required String role,
    required String departureAddress,
    required String destinationAddress,
    required DateTime departureTime,
    required int totalSeats,
    double? departureLat,
    double? departureLng,
    String? departurePlaceId,
    double? destinationLat,
    double? destinationLng,
    String? destinationPlaceId,
    DateTime? estimatedArrivalTime,
    String? luggageLimit,
    String approvalMode = 'manual',
    DateTime? closingTime,
    String? note,
  }) async {
    final client = ref.read(supabaseClientProvider);
    final userId = client.auth.currentUser?.id;
    if (userId == null) return null;

    state = const AsyncValue.loading();
    final repo = ref.read(carpoolRepositoryProvider);

    try {
      final trip = await repo.createTrip(
        creatorId: userId,
        schoolId: schoolId,
        role: role,
        departureAddress: departureAddress,
        destinationAddress: destinationAddress,
        departureTime: departureTime,
        totalSeats: totalSeats,
        departureLat: departureLat,
        departureLng: departureLng,
        departurePlaceId: departurePlaceId,
        destinationLat: destinationLat,
        destinationLng: destinationLng,
        destinationPlaceId: destinationPlaceId,
        estimatedArrivalTime: estimatedArrivalTime,
        luggageLimit: luggageLimit,
        approvalMode: approvalMode,
        closingTime: closingTime,
        note: note,
      );

      // Invalidate the list providers so they refetch
      ref.invalidate(activeCarpoolTripsProvider);
      ref.invalidate(myCarpoolTripsProvider);
      state = const AsyncValue.data(null);
      return trip;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return null;
    }
  }

  /// Cancels a trip and refreshes lists.
  Future<void> cancelTrip(String tripId) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await ref.read(carpoolRepositoryProvider).cancelTrip(tripId);
      ref.invalidate(activeCarpoolTripsProvider);
      ref.invalidate(myCarpoolTripsProvider);
      ref.invalidate(carpoolTripDetailProvider(tripId));
    });
  }
}

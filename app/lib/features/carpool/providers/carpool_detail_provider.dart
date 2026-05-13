import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:smivo/data/models/carpool_trip.dart';
import 'package:smivo/data/repositories/carpool_repository.dart';
import 'package:smivo/features/profile/providers/profile_provider.dart';

part 'carpool_detail_provider.g.dart';

@riverpod
class CarpoolDetail extends _$CarpoolDetail {
  @override
  FutureOr<CarpoolTrip?> build(String tripId) async {
    return ref.read(carpoolRepositoryProvider).fetchTripDetail(tripId);
  }

  Future<void> cancelTrip() async {
    final oldState = state;
    state = const AsyncValue.loading();
    try {
      await ref.read(carpoolRepositoryProvider).cancelTrip(tripId);
      final updatedTrip = await ref.read(carpoolRepositoryProvider).fetchTripDetail(tripId);
      state = AsyncValue.data(updatedTrip);
    } catch (e) {
      state = oldState;
      rethrow;
    }
  }

  Future<void> requestJoin() async {
    final profile = ref.read(profileProvider).value;
    if (profile == null) return;

    final oldState = state;
    state = const AsyncValue.loading();
    try {
      // Re-fetch trip to check current seat availability (race condition guard)
      final freshTrip = await ref.read(carpoolRepositoryProvider).fetchTripDetail(tripId);
      if (freshTrip == null || freshTrip.availableSeats <= 0) {
        throw Exception('NO_SEATS');
      }
      await ref.read(carpoolRepositoryProvider).requestJoinTrip(tripId, profile.id);
      
      final updatedTrip = await ref.read(carpoolRepositoryProvider).fetchTripDetail(tripId);
      state = AsyncValue.data(updatedTrip);
    } catch (e) {
      state = oldState;
      rethrow;
    }
  }

  Future<void> leaveTrip() async {
    final profile = ref.read(profileProvider).value;
    if (profile == null) return;

    final oldState = state;
    state = const AsyncValue.loading();
    try {
      await ref.read(carpoolRepositoryProvider).leaveTrip(tripId, profile.id);
      final updatedTrip = await ref.read(carpoolRepositoryProvider).fetchTripDetail(tripId);
      state = AsyncValue.data(updatedTrip);
    } catch (e) {
      state = oldState;
      rethrow;
    }
  }
}

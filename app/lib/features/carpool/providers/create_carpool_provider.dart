import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:smivo/data/repositories/carpool_repository.dart';
import 'package:smivo/features/profile/providers/profile_provider.dart';
import 'package:smivo/features/carpool/providers/carpool_list_provider.dart';

part 'create_carpool_provider.g.dart';

@riverpod
class CreateCarpool extends _$CreateCarpool {
  @override
  AsyncValue<void> build() {
    return const AsyncValue.data(null);
  }

  Future<void> createTrip({
    required String role,
    required String departureAddress,
    required String destinationAddress,
    required DateTime departureTime,
    required int totalSeats,
    String? luggageLimit,
    String approvalMode = 'manual',
    DateTime? closingTime,
    String? note,
    double? departureLat,
    double? departureLng,
    String? departurePlaceId,
    double? destinationLat,
    double? destinationLng,
    String? destinationPlaceId,
  }) async {
    final profile = ref.read(profileProvider).value;
    if (profile == null) return;

    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await ref.read(carpoolRepositoryProvider).createTrip(
            creatorId: profile.id,
            schoolId: profile.schoolId,
            role: role,
            departureAddress: departureAddress,
            destinationAddress: destinationAddress,
            departureTime: departureTime,
            totalSeats: totalSeats,
            luggageLimit: luggageLimit,
            approvalMode: approvalMode,
            closingTime: closingTime,
            note: note,
            departureLat: departureLat,
            departureLng: departureLng,
            departurePlaceId: departurePlaceId,
            destinationLat: destinationLat,
            destinationLng: destinationLng,
            destinationPlaceId: destinationPlaceId,
          );
      // invalidate list provider to refresh data
      ref.invalidate(carpoolListProvider);
    });
  }
}

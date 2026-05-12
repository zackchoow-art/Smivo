import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:smivo/data/models/carpool_trip.dart';
import 'package:smivo/data/repositories/carpool_repository.dart';
import 'package:smivo/features/profile/providers/profile_provider.dart';

part 'carpool_list_provider.g.dart';

@riverpod
class CarpoolList extends _$CarpoolList {
  @override
  FutureOr<List<CarpoolTrip>> build() async {
    final profile = ref.watch(profileProvider).value;
    if (profile == null) return [];
    return ref.read(carpoolRepositoryProvider).fetchActiveTrips(profile.schoolId);
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final profile = ref.read(profileProvider).value;
      if (profile == null) return [];
      return ref.read(carpoolRepositoryProvider).fetchActiveTrips(profile.schoolId);
    });
  }
}

@riverpod
class MyCarpool extends _$MyCarpool {
  @override
  FutureOr<List<CarpoolTrip>> build() async {
    final profile = ref.watch(profileProvider).value;
    if (profile == null) return [];
    return ref.read(carpoolRepositoryProvider).fetchMyTrips(profile.id);
  }
}

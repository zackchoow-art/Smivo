import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:smivo/core/constants/app_constants.dart';
import 'package:smivo/core/providers/supabase_provider.dart';
import 'package:smivo/data/models/carpool_trip.dart';
import 'package:smivo/data/repositories/carpool_repository.dart';
import 'package:smivo/features/profile/providers/profile_provider.dart';

part 'carpool_list_provider.g.dart';

@riverpod
class CarpoolList extends _$CarpoolList {
  @override
  FutureOr<List<CarpoolTrip>> build() async {
    final profile = ref.watch(profileProvider).value;
    final repo = ref.read(carpoolRepositoryProvider);

    // Subscribe to Realtime changes on carpool_trips so the list
    // auto-refreshes when trips are created, updated, or cancelled.
    // NOTE: We subscribe regardless of login state so guests also
    // get live updates when new trips are posted.
    final client = ref.read(supabaseClientProvider);
    final channel = client.channel('carpool_trips_realtime');
    channel
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: AppConstants.tableCarpoolTrips,
          callback: (_) {
            ref.invalidateSelf();
          },
        )
        .subscribe();

    ref.onDispose(() {
      client.removeChannel(channel);
    });

    // Guests (profile == null) see all active trips platform-wide.
    // Logged-in users see only their own school's trips, mirroring
    // the home feed behaviour.
    if (profile == null) {
      return repo.fetchAllActiveTrips();
    }
    return repo.fetchActiveTrips(profile.schoolId);
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final profile = ref.read(profileProvider).value;
      final repo = ref.read(carpoolRepositoryProvider);
      if (profile == null) {
        return repo.fetchAllActiveTrips();
      }
      return repo.fetchActiveTrips(profile.schoolId);
    });
  }
}

@riverpod
class MyCarpool extends _$MyCarpool {
  @override
  FutureOr<List<CarpoolTrip>> build() async {
    final profile = ref.watch(profileProvider).value;
    if (profile == null) return [];

    // Same Realtime subscription for "My Trips" tab
    final client = ref.read(supabaseClientProvider);
    final channel = client.channel('my_carpool_realtime');
    channel
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: AppConstants.tableCarpoolTrips,
          callback: (_) {
            ref.invalidateSelf();
          },
        )
        .subscribe();

    ref.onDispose(() {
      client.removeChannel(channel);
    });

    return ref.read(carpoolRepositoryProvider).fetchMyTrips(profile.id);
  }
}

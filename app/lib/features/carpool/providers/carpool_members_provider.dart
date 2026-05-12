import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:smivo/core/providers/supabase_provider.dart';
import 'package:smivo/data/models/carpool_member.dart';
import 'package:smivo/data/repositories/carpool_repository.dart';
import 'package:smivo/features/carpool/providers/carpool_trips_provider.dart';

part 'carpool_members_provider.g.dart';

/// Fetches the member list for a trip (with user profiles).
@riverpod
class CarpoolTripMembers extends _$CarpoolTripMembers {
  @override
  Future<List<CarpoolMember>> build(String tripId) async {
    final repo = ref.watch(carpoolRepositoryProvider);
    return repo.fetchTripMembers(tripId);
  }
}

/// Handles the join/leave/approve/reject flow for carpool memberships.
///
/// This provider is the single entry point for all member mutation actions.
/// It coordinates with the trip detail and member list providers to keep
/// the UI in sync after each operation.
@riverpod
class CarpoolMemberActions extends _$CarpoolMemberActions {
  @override
  FutureOr<void> build() {}

  /// Request to join a trip. The RPC checks:
  /// 1. Trip is active and has seats
  /// 2. N×N user_blocks safety (no blocks in either direction)
  /// 3. Closing time not passed
  /// 4. Not already a member
  ///
  /// Returns the join status: 'approved' (auto-mode) or 'pending' (manual).
  Future<String?> requestJoin(String tripId) async {
    final client = ref.read(supabaseClientProvider);
    final userId = client.auth.currentUser?.id;
    if (userId == null) return null;

    state = const AsyncValue.loading();
    String? resultStatus;

    state = await AsyncValue.guard(() async {
      final repo = ref.read(carpoolRepositoryProvider);
      final result = await repo.requestJoinTrip(tripId, userId);
      resultStatus = result['status'] as String?;

      // Refresh related providers
      ref.invalidate(carpoolTripDetailProvider(tripId));
      ref.invalidate(carpoolTripMembersProvider(tripId));
      ref.invalidate(activeCarpoolTripsProvider);
    });

    return state.hasError ? null : resultStatus;
  }

  /// Creator approves a pending join request.
  ///
  /// NOTE: Uses the `accept_carpool_member` RPC which atomically:
  /// approves member, decrements seats, adds to group chat, sends welcome msg.
  Future<void> approveMember(String memberId, String tripId) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(carpoolRepositoryProvider);
      await repo.approveMember(memberId);

      ref.invalidate(carpoolTripDetailProvider(tripId));
      ref.invalidate(carpoolTripMembersProvider(tripId));
      ref.invalidate(activeCarpoolTripsProvider);
    });
  }

  /// Creator rejects a pending join request.
  Future<void> rejectMember(String memberId, String tripId) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(carpoolRepositoryProvider);
      await repo.rejectMember(memberId);

      ref.invalidate(carpoolTripMembersProvider(tripId));
    });
  }

  /// Member voluntarily leaves a trip.
  ///
  /// NOTE: The RPC atomically: marks member as 'left', increments
  /// available_seats, removes from group chat, sends system message.
  Future<void> leaveTrip(String tripId) async {
    final client = ref.read(supabaseClientProvider);
    final userId = client.auth.currentUser?.id;
    if (userId == null) return;

    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(carpoolRepositoryProvider);
      await repo.leaveTrip(tripId, userId);

      ref.invalidate(carpoolTripDetailProvider(tripId));
      ref.invalidate(carpoolTripMembersProvider(tripId));
      ref.invalidate(myCarpoolTripsProvider);
      ref.invalidate(activeCarpoolTripsProvider);
    });
  }
}

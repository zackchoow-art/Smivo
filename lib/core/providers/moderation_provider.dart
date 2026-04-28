import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:smivo/data/repositories/moderation_repository.dart';
import 'package:smivo/features/auth/providers/auth_provider.dart';
import 'package:smivo/features/home/providers/home_provider.dart';
import 'package:smivo/data/models/user_profile.dart';

part 'moderation_provider.g.dart';

@riverpod
class BlockedUsers extends _$BlockedUsers {
  @override
  Future<List<String>> build() async {
    final user = ref.watch(authStateProvider).valueOrNull;
    if (user == null) return [];

    final repo = ref.watch(moderationRepositoryProvider);
    return repo.getBlockedUserIds(user.id);
  }
}

@riverpod
class BlockedUsersList extends _$BlockedUsersList {
  @override
  Future<List<UserProfile>> build() async {
    final user = ref.watch(authStateProvider).valueOrNull;
    if (user == null) return [];

    final repo = ref.watch(moderationRepositoryProvider);
    return repo.getBlockedUsersDetails(user.id);
  }
}

@riverpod
class ModerationActions extends _$ModerationActions {
  @override
  FutureOr<void> build() {}

  Future<void> blockUser(String blockedUserId) async {
    final user = ref.read(authStateProvider).valueOrNull;
    if (user == null) return;

    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(moderationRepositoryProvider);
      await repo.blockUser(user.id, blockedUserId);
      
      // Invalidate the blocked users provider to refresh the cache
      ref.invalidate(blockedUsersProvider);
      
      // Invalidate the home feed so the abusive user's content disappears instantly
      ref.invalidate(homeListingsProvider);
      ref.invalidate(blockedUsersListProvider);
    });
  }

  Future<void> unblockUser(String blockedUserId) async {
    final user = ref.read(authStateProvider).valueOrNull;
    if (user == null) return;

    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(moderationRepositoryProvider);
      await repo.unblockUser(user.id, blockedUserId);
      
      ref.invalidate(blockedUsersProvider);
      ref.invalidate(blockedUsersListProvider);
      ref.invalidate(homeListingsProvider);
    });
  }

  Future<void> reportContent({
    required String reportedUserId,
    String? listingId,
    String? chatRoomId,
    required String reason,
  }) async {
    final user = ref.read(authStateProvider).valueOrNull;
    if (user == null) return;

    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(moderationRepositoryProvider);
      await repo.reportContent(
        reporterId: user.id,
        reportedUserId: reportedUserId,
        listingId: listingId,
        chatRoomId: chatRoomId,
        reason: reason,
      );
    });
  }
}

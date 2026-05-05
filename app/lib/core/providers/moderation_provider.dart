import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:smivo/core/providers/supabase_provider.dart';
import 'package:smivo/data/repositories/moderation_repository.dart';
import 'package:smivo/features/auth/providers/auth_provider.dart';
import 'package:smivo/features/home/providers/home_provider.dart';
import 'package:smivo/data/models/user_profile.dart';
import 'package:smivo/data/models/content_report.dart';

part 'moderation_provider.g.dart';

@riverpod
class BlockedUsers extends _$BlockedUsers {
  @override
  Future<List<String>> build() async {
    final user = ref.watch(authStateProvider).value;
    if (user == null) return [];

    final repo = ref.watch(moderationRepositoryProvider);
    return repo.getBlockedUserIds(user.id);
  }
}

/// IDs of users who have blocked the current user.
///
/// Fetched via a SECURITY DEFINER RPC because RLS only exposes
/// blocks the user has *sent*, not blocks *received*.
@riverpod
class BlockedByUsers extends _$BlockedByUsers {
  @override
  Future<List<String>> build() async {
    final user = ref.watch(authStateProvider).value;
    if (user == null) return [];

    final repo = ref.watch(moderationRepositoryProvider);
    return repo.getBlockedByUserIds();
  }
}

/// IDs to exclude from the home feed: only users the current user has blocked.
///
/// NOTE: We deliberately do NOT include "users who blocked me" here.
/// Bidirectional feed filtering required an extra SECURITY DEFINER RPC on
/// every home feed load, which was resource-intensive and unstable.
/// Instead, the block is enforced at order-placement time via the
/// [isBlockedBySellerProvider] which calls [check_order_eligibility].
@riverpod
List<String> allBlockedUserIds(Ref ref) {
  // Synchronous read — returns [] while the async provider is still loading.
  return ref.watch(blockedUsersProvider).value ?? [];
}

@riverpod
class BlockedUsersList extends _$BlockedUsersList {
  @override
  Future<List<UserProfile>> build() async {
    final user = ref.watch(authStateProvider).value;
    if (user == null) return [];

    final repo = ref.watch(moderationRepositoryProvider);
    return repo.getBlockedUsersDetails(user.id);
  }
}

@Riverpod(keepAlive: true)
class ModerationActions extends _$ModerationActions {
  @override
  FutureOr<void> build() {}

  Future<void> blockUser(String blockedUserId) async {
    final user = ref.read(authStateProvider).value;
    if (user == null) return;

    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(moderationRepositoryProvider);
      await repo.blockUser(user.id, blockedUserId);

      // Invalidate the blocked users provider to refresh the cache
      ref.invalidate(blockedUsersProvider);
      ref.invalidate(blockedByUsersProvider);
      ref.invalidate(allBlockedUserIdsProvider);

      // Invalidate the home feed so the abusive user's content disappears instantly
      ref.invalidate(homeListingsProvider);
      ref.invalidate(blockedUsersListProvider);
    });
  }

  Future<void> unblockUser(String blockedUserId) async {
    final user = ref.read(authStateProvider).value;
    if (user == null) return;

    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(moderationRepositoryProvider);
      await repo.unblockUser(user.id, blockedUserId);

      ref.invalidate(blockedUsersProvider);
      ref.invalidate(blockedByUsersProvider);
      ref.invalidate(allBlockedUserIdsProvider);
      ref.invalidate(blockedUsersListProvider);
      ref.invalidate(homeListingsProvider);
    });
  }

  Future<void> reportContent({
    required String reportedUserId,
    String? listingId,
    String? chatRoomId,
    String? reasonCategory,
    required String reason,
    List<String>? selectedMessageIds,
    Map<String, dynamic>? evidence,
  }) async {
    final user = ref.read(authStateProvider).value;
    if (user == null) return;

    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(moderationRepositoryProvider);
      
      final hasReported = await repo.hasAlreadyReported(
        reporterId: user.id,
        reportedUserId: reportedUserId,
        listingId: listingId,
        chatRoomId: chatRoomId,
      );

      if (hasReported) {
        throw Exception('You have already reported this content.');
      }

      await repo.reportContent(
        reporterId: user.id,
        reportedUserId: reportedUserId,
        listingId: listingId,
        chatRoomId: chatRoomId,
        reasonCategory: reasonCategory,
        reason: reason,
        selectedMessageIds: selectedMessageIds,
        evidence: evidence,
      );
    });
  }
}

@riverpod
class UserReports extends _$UserReports {
  @override
  Future<List<ContentReport>> build() async {
    final user = ref.watch(authStateProvider).value;
    if (user == null) return [];

    final repo = ref.watch(moderationRepositoryProvider);
    return repo.getReportsByReporter(user.id);
  }
}

/// Provides a list of moderation actions (warn/restrict) that were applied
/// to the current user as the *reported* party.
///
/// NOTE: Dismissed reports are filtered out by the RLS policy, so this list
/// only contains records the user genuinely needs to be aware of.
@riverpod
class UserPenalties extends _$UserPenalties {
  @override
  Future<List<ContentReport>> build() async {
    final user = ref.watch(authStateProvider).value;
    if (user == null) return [];

    final repo = ref.watch(moderationRepositoryProvider);
    return repo.getReportPenaltiesAgainstUser(user.id);
  }
}

/// Set of image URLs that have been flagged by the AI moderation system.
///
/// Loaded once at session start from backend_moderation_logs where result='fail'.
/// Used by [ModerationAwareImage] to decide whether to apply blur.
///
/// NOTE: keepAlive: true — this set must persist for the entire session so
/// the blur is consistent across page navigations. It is NOT per-user data;
/// it loads all flagged images visible to the current user via RLS.
@Riverpod(keepAlive: true)
class FlaggedImageUrls extends _$FlaggedImageUrls {
  @override
  Future<Set<String>> build() async {
    try {
      final supabase = ref.watch(supabaseClientProvider);
      // Query backend_moderation_logs for failed image moderation results.
      // NOTE: content_snapshot holds the image URL for image-type logs.
      final data = await supabase
          .from('backend_moderation_logs')
          .select('content_snapshot')
          .eq('result', 'fail')
          .inFilter('action_taken', ['image_flagged', 'blur_applied'])
          .limit(500);

      final urls = <String>{};
      for (final row in (data as List)) {
        final url = row['content_snapshot'] as String?;
        if (url != null && url.startsWith('http')) {
          urls.add(url);
        }
      }
      return urls;
    } catch (e) {
      // NOTE: If the query fails (e.g. RLS or network), return empty set.
      // No images should be accidentally blurred due to a DB error.
      return {};
    }
  }

  /// Adds a URL to the in-memory flagged set immediately after moderation
  /// completes, so the blur takes effect without waiting for a full reload.
  void addFlagged(String url) {
    state = AsyncData({...?state.value, url});
  }
}


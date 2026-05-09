import 'dart:async';

import 'package:flutter/foundation.dart';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
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

/// Platform-level image moderation mode.
///
/// Reads 'image_moderation_mode' from the system_configs table.
/// Supported values:
///   'blur'        — blur the flagged image and show a violation summary
///   'auto_reject' — do not load the image at all, show a removal notice
///
/// NOTE: keepAlive: true — this config must persist for the session.
/// Defaults to 'blur' on any error so existing behavior is preserved.
@Riverpod(keepAlive: true)
class ImageModerationMode extends _$ImageModerationMode {
  @override
  Future<String> build() async {
    try {
      final supabase = ref.watch(supabaseClientProvider);
      final data =
          await supabase
              .from('system_configs')
              // FIXME was: .select('value') / .eq('key', ...) — wrong column names.
              // system_configs uses config_key and config_value, not key/value.
              .select('config_value')
              .eq('config_key', 'image_moderation_mode')
              .maybeSingle();

      final value = data?['config_value'] as String?;
      if (value == 'auto_reject' || value == 'blur') return value!;
      // NOTE: Fall back to 'blur' for any unknown or null config value.
      return 'blur';
    } catch (_) {
      return 'blur';
    }
  }
}

/// Map of flagged image URLs to their violation reasons.
///
/// Key   = image URL
/// Value = list of violation reason strings (e.g. ['sexual', 'violence'])
///
/// Loaded once at session start from backend_moderation_logs where result='fail'.
/// Used by [ModerationAwareImage] to decide whether to apply blur and what text
/// to show the user.
///
/// NOTE: keepAlive: true — must persist for the entire session so blur is
/// consistent across page navigations. Loads all flagged images visible to
/// the current user via the RLS policy added in migration 00129.
@Riverpod(keepAlive: true)
class FlaggedImageUrls extends _$FlaggedImageUrls {
  // Holds the Realtime subscription so it can be cancelled on dispose.
  RealtimeChannel? _channel;

  @override
  Future<Map<String, List<String>>> build() async {
    // Cancel any previous subscription when the provider rebuilds.
    ref.onDispose(() {
      _channel?.unsubscribe();
      _channel = null;
    });

    Map<String, List<String>> urlReasons = {};

    try {
      final supabase = ref.watch(supabaseClientProvider);
      // NOTE: RLS policy added in migration 00129 allows all authenticated
      // users to read result='fail' rows — required so chat recipients can
      // blur images sent by other users.
      //
      // FIX 2.1-A: Order by created_at DESC so the most recent violations
      // are always included in the 500-record window. Previously no order
      // clause meant the 500 records were unpredictable and could miss
      // recent chat images.
      final data = await supabase
          .from('backend_moderation_logs')
          .select('content_snapshot, image_details')
          .eq('result', 'fail')
          .order('created_at', ascending: false)
          .limit(500);

      urlReasons = _parseRows(data as List);
    } catch (e) {
      // NOTE: Return empty map on any error — never accidentally blur clean images.
      urlReasons = {};
    }

    // FIX 2.1-B: Subscribe to Realtime INSERT events on backend_moderation_logs
    // so that any image moderated during the current session is immediately added
    // to the in-memory map without needing an app restart.
    //
    // Only INSERT events with result='fail' are relevant; we filter in the
    // callback rather than relying on a server-side filter, because Postgres
    // Realtime column filters require the table to have RLS enabled with the
    // right policy (which it does), but the filter syntax differs by Supabase
    // version. Filtering client-side is safer and zero-risk.
    try {
      final supabase = ref.read(supabaseClientProvider);
      _channel = supabase
          .channel('flagged_images_realtime')
          .onPostgresChanges(
            event: PostgresChangeEvent.insert,
            schema: 'public',
            table: 'backend_moderation_logs',
            callback: (payload) {
              final row = payload.newRecord;
              debugPrint('[Moderation] Realtime INSERT received: result=${row['result']}');
              if (row['result'] != 'fail') return;
              final parsed = _parseRows([row]);
              if (parsed.isEmpty) return;
              debugPrint('[Moderation] Flagged ${parsed.length} new image(s) via Realtime');
              // Merge new entries into the live map
              final current = Map<String, List<String>>.from(
                state.value ?? {},
              );
              parsed.forEach((url, reasons) {
                current.update(
                  url,
                  (existing) => {...existing, ...reasons}.toList(),
                  ifAbsent: () => reasons,
                );
              });
              state = AsyncData(current);
            },
          )
          .subscribe();
    } catch (_) {
      // NOTE: Realtime failure should not crash the provider — the initial
      // snapshot is still used for blur enforcement.
    }

    return urlReasons;
  }

  /// Parses a list of backend_moderation_logs rows into a url→reasons Map.
  Map<String, List<String>> _parseRows(List<dynamic> rows) {
    final urlReasons = <String, List<String>>{};
    for (final row in rows) {
      // Source: image_details array (listings + chat images store per-image results)
      final imageDetails = row['image_details'] as List?;
      if (imageDetails != null) {
        for (final detail in imageDetails) {
          if (detail is Map &&
              detail['flagged'] == true &&
              detail['url'] is String &&
              (detail['url'] as String).startsWith('http')) {
            final url = detail['url'] as String;
            final rawReasons = detail['reasons'];
            final reasons = (rawReasons is List)
                ? rawReasons.map((r) => r.toString()).toList()
                : <String>[];
            // NOTE: Merge reasons if the same URL appears in multiple rows
            urlReasons.update(
              url,
              (existing) => {...existing, ...reasons}.toList(),
              ifAbsent: () => reasons,
            );
          }
        }
      }

      // Source: content_snapshot (chat image messages store URL here).
      // For messages, image_details[0] holds the reasons.
      final snapshot = row['content_snapshot'] as String?;
      if (snapshot != null && snapshot.startsWith('http')) {
        if (!urlReasons.containsKey(snapshot)) {
          List<String> msgReasons = [];
          if (imageDetails != null && imageDetails.isNotEmpty) {
            final first = imageDetails.first;
            if (first is Map && first['reasons'] is List) {
              msgReasons =
                  (first['reasons'] as List).map((r) => r.toString()).toList();
            }
          }
          urlReasons[snapshot] = msgReasons;
        }
      }
    }
    return urlReasons;
  }

  /// Adds a URL to the in-memory flagged map immediately after moderation
  /// completes, so the blur takes effect without waiting for a full reload.
  ///
  /// [reasons] defaults to an empty list if the violation type is unknown yet.
  void addFlagged(String url, {List<String> reasons = const []}) {
    final current = Map<String, List<String>>.from(state.value ?? {});
    current[url] = reasons;
    state = AsyncData(current);
  }
}


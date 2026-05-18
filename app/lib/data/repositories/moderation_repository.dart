import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:smivo/core/exceptions/app_exception.dart';
import 'package:smivo/core/providers/supabase_provider.dart';
import 'package:smivo/data/models/content_report.dart';
import 'package:smivo/data/models/user_profile.dart';

part 'moderation_repository.g.dart';

/// Handles user-generated content moderation: blocking users and reporting content.
class ModerationRepository {
  const ModerationRepository(this._client);
  final SupabaseClient _client;

  /// Blocks a user by inserting a record into `user_blocks`.
  Future<void> blockUser(String currentUserId, String blockedUserId) async {
    try {
      await _client.from('user_blocks').insert({
        'user_id': currentUserId,
        'blocked_user_id': blockedUserId,
      });
    } on PostgrestException catch (e) {
      // 23505 is PostgreSQL unique_violation. If already blocked, silently succeed.
      if (e.code == '23505') return;
      throw DatabaseException(e.message, e);
    }
  }

  /// Fetches the list of user IDs that the current user has blocked.
  Future<List<String>> getBlockedUserIds(String currentUserId) async {
    try {
      final data = await _client
          .from('user_blocks')
          .select('blocked_user_id')
          .eq('user_id', currentUserId);
      return data.map((json) => json['blocked_user_id'] as String).toList();
    } on PostgrestException catch (e) {
      throw DatabaseException(e.message, e);
    }
  }

  /// Fetches the IDs of users who have blocked the current user.
  ///
  /// Uses the [get_blocked_by_user_ids] SECURITY DEFINER RPC because RLS
  /// only allows a user to see their own blocks. Without this RPC, a user
  /// has no way to query who has blocked them.
  Future<List<String>> getBlockedByUserIds() async {
    try {
      final data = await _client.rpc('get_blocked_by_user_ids');
      // NOTE: PostgREST may return null for an empty uuid[] array,
      // or a List<dynamic> with String elements. Handle both safely.
      if (data == null) return [];
      if (data is List) return List<String>.from(data);
      // Unexpected format — fail safe, return empty list.
      return [];
    } on PostgrestException catch (e) {
      throw DatabaseException(e.message, e);
    } catch (_) {
      // NOTE: Any unexpected type error from PostgREST deserialization
      // should not crash the home feed — return empty list.
      return [];
    }
  }

  /// Unblocks a user by deleting the record from `user_blocks`.
  Future<void> unblockUser(String currentUserId, String blockedUserId) async {
    try {
      await _client
          .from('user_blocks')
          .delete()
          .eq('user_id', currentUserId)
          .eq('blocked_user_id', blockedUserId);
    } on PostgrestException catch (e) {
      throw DatabaseException(e.message, e);
    }
  }

  /// Fetches the detailed profiles of users that the current user has blocked.
  Future<List<UserProfile>> getBlockedUsersDetails(String currentUserId) async {
    try {
      final data = await _client
          .from('user_blocks')
          .select('user_profiles!user_blocks_blocked_user_id_fkey(*)')
          .eq('user_id', currentUserId)
          .order('created_at', ascending: false);
      return data
          .map(
            (json) => UserProfile.fromJson(
              json['user_profiles'] as Map<String, dynamic>,
            ),
          )
          .toList();
    } on PostgrestException catch (e) {
      throw DatabaseException(e.message, e);
    }
  }

  /// Checks if a user has already reported a specific target.
  Future<bool> hasAlreadyReported({
    required String reporterId,
    required String reportedUserId,
    String? listingId,
    String? chatRoomId,
  }) async {
    try {
      var query = _client
          .from('content_reports')
          .select('id')
          .eq('reporter_id', reporterId)
          .eq('reported_user_id', reportedUserId);

      if (listingId != null) {
        query = query.eq('listing_id', listingId);
      } else if (chatRoomId != null) {
        query = query.eq('chat_room_id', chatRoomId);
      } else {
        query = query
            .filter('listing_id', 'is', null)
            .filter('chat_room_id', 'is', null);
      }

      final data = await query.maybeSingle();
      return data != null;
    } on PostgrestException catch (e) {
      throw DatabaseException(e.message, e);
    }
  }

  /// Reports objectionable content (user, listing, or chat).
  Future<void> reportContent({
    required String reporterId,
    required String reportedUserId,
    String? listingId,
    String? chatRoomId,
    String? reasonCategory,
    required String reason,
    List<String>? selectedMessageIds,
    Map<String, dynamic>? evidence,
  }) async {
    try {
      await _client.from('content_reports').insert({
        'reporter_id': reporterId,
        'reported_user_id': reportedUserId,
        'listing_id': listingId,
        'chat_room_id': chatRoomId,
        if (reasonCategory != null) 'reason_category': reasonCategory,
        'reason': reason,
        if (selectedMessageIds != null)
          'selected_message_ids': selectedMessageIds,
        if (evidence != null) 'evidence': evidence,
      });
    } on PostgrestException catch (e) {
      if (e.code == '23505') {
        throw const DatabaseException(
          'You have already reported this content.',
          null,
        );
      }
      if (e.message.contains('row-level security policy')) {
        throw DatabaseException(
          'Action denied. Your account may be restricted.',
          e,
        );
      }
      throw DatabaseException(e.message, e);
    }
  }

  /// Fetches reports submitted by the given user.
  Future<List<ContentReport>> getReportsByReporter(String reporterId) async {
    try {
      final data = await _client
          .from('content_reports')
          .select(
            '*, reported_user:user_profiles!content_reports_reported_user_id_fkey(*), listing:listings(*, images:listing_images(*))',
          )
          .eq('reporter_id', reporterId)
          .order('created_at', ascending: false);
      return data.map((json) => ContentReport.fromJson(json)).toList();
    } on PostgrestException catch (e) {
      throw DatabaseException(e.message, e);
    }
  }

  /// Fetches reports where the current user was penalised (warn or restrict).
  ///
  /// The RLS policy on content_reports only returns rows where:
  ///   status = 'resolved' AND action_taken IN ('warn', 'restrict')
  /// so dismissed reports are never exposed to the reported user.
  ///
  /// NOTE: De-duplication by content target (listing_id / chat_room_id) is
  /// applied here to prevent the same moderation event appearing multiple
  /// times when multiple users reported the same item.  When N reporters flag
  /// the same listing, N rows are resolved — but the seller should only see
  /// ONE warning card per listing (the most recent one, which already carries
  /// the merged reporter count in resolution_note).
  Future<List<ContentReport>> getReportPenaltiesAgainstUser(
    String userId,
  ) async {
    try {
      final data = await _client
          .from('content_reports')
          .select('*, listing:listings(*, images:listing_images(*))')
          .eq('reported_user_id', userId)
          .order('created_at', ascending: false);

      final all = data.map((json) => ContentReport.fromJson(json)).toList();

      // NOTE: De-duplicate by target: keep only the first (newest) record per
      // listing_id.  For reports without a listing (user-level reports), group
      // by chat_room_id, or fall back to treating each report individually.
      // The incoming list is already sorted newest-first, so the first entry
      // in each group is the canonical one we want to display.
      final seen = <String>{};
      final deduped = <ContentReport>[];
      for (final report in all) {
        // Build a dedup key:
        //   - listing reports: "listing:<listing_id>"
        //   - chat reports   : "chat:<chat_room_id>"
        //   - user reports   : "user:<report_id>" (no dedup — each is unique)
        final String key;
        if (report.listingId != null) {
          key = 'listing:${report.listingId}';
        } else if (report.chatRoomId != null) {
          key = 'chat:${report.chatRoomId}';
        } else {
          key = 'user:${report.id}';
        }

        if (!seen.contains(key)) {
          seen.add(key);
          deduped.add(report);
        }
      }

      return deduped;
    } on PostgrestException catch (e) {
      throw DatabaseException(e.message, e);
    }
  }
}

@riverpod
ModerationRepository moderationRepository(Ref ref) {
  return ModerationRepository(ref.watch(supabaseClientProvider));
}

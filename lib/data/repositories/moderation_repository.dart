import 'package:flutter_riverpod/flutter_riverpod.dart';
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
      return data.map((json) => UserProfile.fromJson(json['user_profiles'] as Map<String, dynamic>)).toList();
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
    required String reason,
  }) async {
    try {
      await _client.from('content_reports').insert({
        'reporter_id': reporterId,
        'reported_user_id': reportedUserId,
        'listing_id': listingId,
        'chat_room_id': chatRoomId,
        'reason': reason,
      });
    } on PostgrestException catch (e) {
      throw DatabaseException(e.message, e);
    }
  }

  /// Fetches reports submitted by the given user.
  Future<List<ContentReport>> getReportsByReporter(String reporterId) async {
    try {
      final data = await _client
          .from('content_reports')
          .select('*, reported_user:user_profiles!content_reports_reported_user_id_fkey(*), listing:listings(*, images:listing_images(*))')
          .eq('reporter_id', reporterId)
          .order('created_at', ascending: false);
      return data.map((json) => ContentReport.fromJson(json)).toList();
    } on PostgrestException catch (e) {
      throw DatabaseException(e.message, e);
    }
  }
}

@riverpod
ModerationRepository moderationRepository(Ref ref) {
  return ModerationRepository(ref.watch(supabaseClientProvider));
}

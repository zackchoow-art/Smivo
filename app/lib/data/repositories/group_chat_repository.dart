import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:smivo/core/constants/app_constants.dart';
import 'package:smivo/core/exceptions/app_exception.dart';
import 'package:smivo/core/providers/supabase_provider.dart';
import 'package:smivo/data/models/group_chat_room.dart';
import 'package:smivo/data/models/group_message.dart';

part 'group_chat_repository.g.dart';

/// Handles all Supabase operations for group chat rooms and messages.
///
/// Group chat is 1:1 with a carpool trip — there is one room per trip.
/// Realtime subscriptions follow the same lifecycle pattern as ChatRepository:
/// subscribe in provider build(), cancel in onDispose.
class GroupChatRepository {
  const GroupChatRepository(this._client);

  final SupabaseClient _client;

  // ── Room queries ───────────────────────────────────────────────────────────

  /// Fetches the group chat room for [tripId] with member profiles joined.
  ///
  /// NOTE: Returns the single room that maps to this trip. The 1:1
  /// relationship is enforced by a UNIQUE constraint on trip_id in the DB.
  Future<GroupChatRoom> fetchGroupChatRoom(String tripId) async {
    try {
      final data = await _client
          .from(AppConstants.tableGroupChatRooms)
          .select('''
            *,
            members:group_chat_members(*, user:user_profiles!user_id(*))
          ''')
          .eq('trip_id', tripId)
          .single();
      return GroupChatRoom.fromJson(data);
    } on PostgrestException catch (e) {
      throw DatabaseException(e.message, e);
    }
  }

  // ── Message queries ────────────────────────────────────────────────────────

  /// Fetches all messages in [roomId] with sender profiles, ordered by time.
  Future<List<GroupMessage>> fetchGroupMessages(String roomId) async {
    try {
      final data = await _client
          .from(AppConstants.tableGroupMessages)
          .select('*, sender:user_profiles!sender_id(*)')
          .eq('room_id', roomId)
          .order('created_at', ascending: true);
      return data.map((json) => GroupMessage.fromJson(json)).toList();
    } on PostgrestException catch (e) {
      throw DatabaseException(e.message, e);
    }
  }

  /// Sends a text message in [roomId] on behalf of [senderId].
  Future<GroupMessage> sendGroupMessage({
    required String roomId,
    required String senderId,
    required String content,
  }) async {
    try {
      final data = await _client
          .from(AppConstants.tableGroupMessages)
          .insert({
            'room_id': roomId,
            'sender_id': senderId,
            'content': content,
            'message_type': 'text',
          })
          .select('*, sender:user_profiles!sender_id(*)')
          .single();
      return GroupMessage.fromJson(data);
    } on PostgrestException catch (e) {
      if (e.message.contains('row-level security policy')) {
        throw DatabaseException(
          'Action denied. Your account may be restricted.',
          e,
        );
      }
      throw DatabaseException(e.message, e);
    }
  }

  /// Sends an image message in [roomId] on behalf of [senderId].
  ///
  /// The [imageUrl] is the public URL of an already-uploaded Storage object.
  /// content is set to '[Image]' as a fallback for notification previews.
  Future<GroupMessage> sendGroupImageMessage({
    required String roomId,
    required String senderId,
    required String imageUrl,
  }) async {
    try {
      final data = await _client
          .from(AppConstants.tableGroupMessages)
          .insert({
            'room_id': roomId,
            'sender_id': senderId,
            'content': '[Image]',
            'message_type': 'image',
            'image_url': imageUrl,
          })
          .select('*, sender:user_profiles!sender_id(*)')
          .single();
      return GroupMessage.fromJson(data);
    } on PostgrestException catch (e) {
      if (e.message.contains('row-level security policy')) {
        throw DatabaseException(
          'Action denied. Your account may be restricted.',
          e,
        );
      }
      throw DatabaseException(e.message, e);
    }
  }

  // ── Realtime ───────────────────────────────────────────────────────────────

  /// Subscribes to new messages in [roomId] via Supabase Realtime.
  ///
  /// NOTE: The channel name includes roomId to prevent cross-room
  /// message delivery when multiple group chats are subscribed simultaneously.
  /// Caller must call .unsubscribe() on the returned channel in onDispose.
  RealtimeChannel subscribeToGroupMessages({
    required String roomId,
    required void Function(GroupMessage message) onMessage,
  }) {
    return _client
        .channel('group_messages:$roomId')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: AppConstants.tableGroupMessages,
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'room_id',
            value: roomId,
          ),
          callback: (payload) {
            // NOTE: Realtime payloads do not include joined relations.
            // Sender profile will be null here — UI must handle this case
            // by fetching the full message list after receiving the event.
            final message = GroupMessage.fromJson(payload.newRecord);
            onMessage(message);
          },
        )
        .subscribe();
  }
  // ── User membership queries ────────────────────────────────────────────────

  /// Fetches all group chat rooms where [userId] is an active member.
  ///
  /// NOTE: This queries group_chat_members directly for the user's rows,
  /// then fetches the corresponding rooms with member profiles. Members who
  /// have left or been kicked are already removed from group_chat_members by
  /// the leave/kick RPCs, so no additional filtering is needed here.
  Future<List<GroupChatRoom>> fetchUserGroupChatRooms(String userId) async {
    try {
      // First, get all room IDs this user belongs to
      final memberRows = await _client
          .from(AppConstants.tableGroupChatMembers)
          .select('room_id')
          .eq('user_id', userId);

      if (memberRows.isEmpty) return [];

      final roomIds = memberRows
          .map((row) => row['room_id'] as String)
          .toList();

      // Then fetch full room data with members for each room
      final data = await _client
          .from(AppConstants.tableGroupChatRooms)
          .select('''
            *,
            members:group_chat_members(*, user:user_profiles!user_id(*))
          ''')
          .inFilter('id', roomIds)
          .order('updated_at', ascending: false);

      return data.map((json) => GroupChatRoom.fromJson(json)).toList();
    } on PostgrestException catch (e) {
      throw DatabaseException(e.message, e);
    }
  }

  // ── Unread count tracking ──────────────────────────────────────────────────

  /// Updates [last_read_at] to now for the current user's membership in [roomId].
  ///
  /// Called when the user opens a group chat screen so all existing messages
  /// are marked as "read".
  Future<void> updateLastReadAt({
    required String roomId,
    required String userId,
  }) async {
    try {
      await _client
          .from(AppConstants.tableGroupChatMembers)
          .update({'last_read_at': DateTime.now().toUtc().toIso8601String()})
          .eq('room_id', roomId)
          .eq('user_id', userId);
    } on PostgrestException catch (e) {
      throw DatabaseException(e.message, e);
    }
  }

  /// Returns a map of { roomId: unreadCount } for all rooms the user belongs to.
  ///
  /// Uses a single RPC call instead of N+1 queries for efficiency.
  Future<Map<String, int>> fetchGroupUnreadCounts(String userId) async {
    try {
      final result = await _client
          .rpc('get_group_unread_counts', params: {'p_user_id': userId});

      final counts = <String, int>{};
      for (final row in (result as List)) {
        counts[row['room_id'] as String] = (row['unread_count'] as num).toInt();
      }
      return counts;
    } on PostgrestException catch (e) {
      throw DatabaseException(e.message, e);
    }
  }

  // ── Group chat active session ──────────────────────────────────────────────
  // Mirrors ChatRepository's setActiveSession/clearActiveSession but uses
  // the group_chat_room_id column instead of chat_room_id.

  /// Records that [userId] is currently viewing group chat [roomId].
  Future<void> setGroupActiveSession({
    required String userId,
    required String roomId,
  }) async {
    try {
      await _client.from('user_active_sessions').upsert({
        'user_id': userId,
        'group_chat_room_id': roomId,
        'updated_at': DateTime.now().toUtc().toIso8601String(),
      }, onConflict: 'user_id');
    } on PostgrestException catch (e) {
      throw DatabaseException(e.message, e);
    }
  }

  /// Clears the group chat room session for [userId].
  Future<void> clearGroupActiveSession(String userId) async {
    try {
      await _client
          .from('user_active_sessions')
          .update({
            'group_chat_room_id': null,
            'updated_at': DateTime.now().toUtc().toIso8601String(),
          })
          .eq('user_id', userId);
    } on PostgrestException catch (e) {
      throw DatabaseException(e.message, e);
    }
  }

  // ── Per-member preferences ─────────────────────────────────────────────────

  /// Toggles [is_pinned] for the current user's membership in [roomId].
  Future<void> toggleGroupPin({
    required String roomId,
    required String userId,
    required bool isPinned,
  }) async {
    try {
      await _client
          .from(AppConstants.tableGroupChatMembers)
          .update({'is_pinned': isPinned})
          .eq('room_id', roomId)
          .eq('user_id', userId);
    } on PostgrestException catch (e) {
      throw DatabaseException(e.message, e);
    }
  }

  /// Toggles [is_archived] for the current user's membership in [roomId].
  Future<void> toggleGroupArchive({
    required String roomId,
    required String userId,
    required bool isArchived,
  }) async {
    try {
      await _client
          .from(AppConstants.tableGroupChatMembers)
          .update({'is_archived': isArchived})
          .eq('room_id', roomId)
          .eq('user_id', userId);
    } on PostgrestException catch (e) {
      throw DatabaseException(e.message, e);
    }
  }

  /// Toggles [is_unread_override] for the current user's membership in [roomId].
  Future<void> toggleGroupUnreadOverride({
    required String roomId,
    required String userId,
    required bool isUnreadOverride,
  }) async {
    try {
      await _client
          .from(AppConstants.tableGroupChatMembers)
          .update({'is_unread_override': isUnreadOverride})
          .eq('room_id', roomId)
          .eq('user_id', userId);
    } on PostgrestException catch (e) {
      throw DatabaseException(e.message, e);
    }
  }
}

@riverpod
GroupChatRepository groupChatRepository(Ref ref) =>
    GroupChatRepository(ref.watch(supabaseClientProvider));

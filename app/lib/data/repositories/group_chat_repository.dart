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
}

@riverpod
GroupChatRepository groupChatRepository(Ref ref) =>
    GroupChatRepository(ref.watch(supabaseClientProvider));

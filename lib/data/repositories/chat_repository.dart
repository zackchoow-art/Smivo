import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:smivo/core/constants/app_constants.dart';
import 'package:smivo/core/exceptions/app_exception.dart';
import 'package:smivo/core/providers/supabase_provider.dart';
import 'package:smivo/data/models/chat_room.dart';
import 'package:smivo/data/models/message.dart';

part 'chat_repository.g.dart';

/// Handles chat room and message Supabase operations + Realtime.
class ChatRepository {
  const ChatRepository(this._client);

  final SupabaseClient _client;

  /// Fetches all chat rooms for a given user.
  Future<List<ChatRoom>> fetchChatRooms(String userId) async {
    try {
      final data = await _client
          .from(AppConstants.tableChatRooms)
          .select()
          .or('buyer_id.eq.$userId,seller_id.eq.$userId')
          .order('last_message_at', ascending: false);
      return data.map((json) => ChatRoom.fromJson(json)).toList();
    } on PostgrestException catch (e) {
      throw DatabaseException(e.message, e);
    }
  }

  /// Fetches or creates a chat room for a listing between buyer and seller.
  Future<ChatRoom> getOrCreateChatRoom({
    required String listingId,
    required String buyerId,
    required String sellerId,
  }) async {
    try {
      final existing = await _client
          .from(AppConstants.tableChatRooms)
          .select()
          .eq('listing_id', listingId)
          .eq('buyer_id', buyerId)
          .eq('seller_id', sellerId)
          .maybeSingle();
      if (existing != null) return ChatRoom.fromJson(existing);

      final data = await _client
          .from(AppConstants.tableChatRooms)
          .insert({
            'listing_id': listingId,
            'buyer_id': buyerId,
            'seller_id': sellerId,
          })
          .select()
          .single();
      return ChatRoom.fromJson(data);
    } on PostgrestException catch (e) {
      throw DatabaseException(e.message, e);
    }
  }

  /// Fetches messages for a chat room, ordered chronologically.
  Future<List<Message>> fetchMessages(String chatRoomId) async {
    try {
      final data = await _client
          .from(AppConstants.tableMessages)
          .select()
          .eq('chat_room_id', chatRoomId)
          .order('created_at');
      return data.map((json) => Message.fromJson(json)).toList();
    } on PostgrestException catch (e) {
      throw DatabaseException(e.message, e);
    }
  }

  /// Sends a new message in a chat room.
  Future<Message> sendMessage({
    required String chatRoomId,
    required String senderId,
    required String content,
  }) async {
    try {
      final data = await _client
          .from(AppConstants.tableMessages)
          .insert({
            'chat_room_id': chatRoomId,
            'sender_id': senderId,
            'content': content,
          })
          .select()
          .single();
      return Message.fromJson(data);
    } on PostgrestException catch (e) {
      throw DatabaseException(e.message, e);
    }
  }

  /// Subscribes to new messages in a chat room via Realtime.
  RealtimeChannel subscribeToMessages({
    required String chatRoomId,
    required void Function(Message message) onMessage,
  }) {
    return _client
        .channel('messages:$chatRoomId')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: AppConstants.tableMessages,
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'chat_room_id',
            value: chatRoomId,
          ),
          callback: (payload) {
            final message = Message.fromJson(payload.newRecord);
            onMessage(message);
          },
        )
        .subscribe();
  }
}

@riverpod
ChatRepository chatRepository(Ref ref) =>
    ChatRepository(ref.watch(supabaseClientProvider));

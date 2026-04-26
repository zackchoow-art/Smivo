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

  /// Fetches all chat rooms for [userId] with joined context data.
  ///
  /// Includes both participant profiles (buyer & seller), the listing 
  /// preview (title + first image), and the most recent message. 
  /// UI layer picks the "other party" by comparing against userId.
  Future<List<ChatRoom>> fetchChatRooms(String userId) async {
    try {
      final data = await _client
          .from(AppConstants.tableChatRooms)
          .select('''
            *,
            buyer:user_profiles!buyer_id(*),
            seller:user_profiles!seller_id(*),
            listing:listings(id, title, description, price, images:listing_images(image_url)),
            last_message:messages(*)
          ''')
          .or('buyer_id.eq.$userId,seller_id.eq.$userId')
          .order('last_message_at', ascending: false, nullsFirst: false)
          .order('created_at', referencedTable: 'messages', ascending: false)
          .limit(1, referencedTable: 'messages');
      
      return data.map((json) => ChatRoom.fromJson(json)).toList();
    } on PostgrestException catch (e) {
      throw DatabaseException(e.message, e);
    }
  }
  /// Fetches a single chat room by [id] with context data.
  Future<ChatRoom> fetchChatRoom(String id) async {
    try {
      final data = await _client
          .from(AppConstants.tableChatRooms)
          .select('''
            *,
            buyer:user_profiles!buyer_id(*),
            seller:user_profiles!seller_id(*),
            listing:listings(id, title, images:listing_images(image_url))
          ''')
          .eq('id', id)
          .single();
      return ChatRoom.fromJson(data);
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
          .select('*, sender:user_profiles!sender_id(*)')
          .eq('chat_room_id', chatRoomId)
          .order('created_at', ascending: true);
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
          .select('*, sender:user_profiles!sender_id(*)')
          .single();
      return Message.fromJson(data);
    } on PostgrestException catch (e) {
      throw DatabaseException(e.message, e);
    }
  }

  /// Sends an image message in a chat room.
  Future<Message> sendImageMessage({
    required String chatRoomId,
    required String senderId,
    required String imageUrl,
  }) async {
    try {
      final data = await _client
          .from(AppConstants.tableMessages)
          .insert({
            'chat_room_id': chatRoomId,
            'sender_id': senderId,
            'content': '[Image]',
            'message_type': 'image',
            'image_url': imageUrl,
          })
          .select('*, sender:user_profiles!sender_id(*)')
          .single();
      return Message.fromJson(data);
    } on PostgrestException catch (e) {
      throw DatabaseException(e.message, e);
    }
  }

  /// Marks all messages in [chatRoomId] as read for [userId].
  ///
  /// Updates is_read on messages NOT sent by userId, then resets
  /// the appropriate unread_count in chat_rooms based on role.
  Future<void> markMessagesAsRead({
    required String chatRoomId,
    required String userId,
  }) async {
    try {
      // Mark other party's messages as read
      await _client
          .from(AppConstants.tableMessages)
          .update({'is_read': true})
          .eq('chat_room_id', chatRoomId)
          .neq('sender_id', userId)
          .eq('is_read', false);

      // Determine which unread counter to reset based on user role
      final room = await _client
          .from(AppConstants.tableChatRooms)
          .select('buyer_id, seller_id')
          .eq('id', chatRoomId)
          .single();

      final updateField = (room['buyer_id'] == userId)
          ? 'unread_count_buyer'
          : 'unread_count_seller';

      await _client
          .from(AppConstants.tableChatRooms)
          .update({updateField: 0})
          .eq('id', chatRoomId);
    } on PostgrestException catch (e) {
      throw DatabaseException(e.message, e);
    }
  }

  /// Toggle the pinned state of a chat room.
  Future<void> togglePin(String chatRoomId, bool isPinned) async {
    try {
      await _client
          .from(AppConstants.tableChatRooms)
          .update({'is_pinned': isPinned})
          .eq('id', chatRoomId);
    } on PostgrestException catch (e) {
      throw DatabaseException(e.message, e);
    }
  }

  /// Toggle the archived state of a chat room.
  Future<void> toggleArchive(String chatRoomId, bool isArchived) async {
    try {
      await _client
          .from(AppConstants.tableChatRooms)
          .update({'is_archived': isArchived})
          .eq('id', chatRoomId);
    } on PostgrestException catch (e) {
      throw DatabaseException(e.message, e);
    }
  }

  /// Toggle the manual unread override of a chat room.
  Future<void> toggleUnreadOverride(String chatRoomId, bool isUnread) async {
    try {
      await _client
          .from(AppConstants.tableChatRooms)
          .update({'is_unread_override': isUnread})
          .eq('id', chatRoomId);
    } on PostgrestException catch (e) {
      throw DatabaseException(e.message, e);
    }
  }

  /// Subscribes to changes in chat rooms for [userId].
  Stream<List<ChatRoom>> subscribeToChatRooms(String userId) {
    return _client
        .from(AppConstants.tableChatRooms)
        .stream(primaryKey: ['id'])
        // Note: Supabase .stream() doesn't support complex .or() filters.
        // We listen to changes and re-fetch the user's specific rooms.
        .asyncMap((rooms) => fetchChatRooms(userId));
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

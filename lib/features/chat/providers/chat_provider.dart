import 'dart:typed_data';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:smivo/core/constants/app_constants.dart';
import 'package:smivo/core/providers/supabase_provider.dart';
import 'package:smivo/data/models/chat_room.dart';
import 'package:smivo/data/models/message.dart';
import 'package:smivo/data/repositories/chat_repository.dart';
import 'package:smivo/data/repositories/storage_repository.dart';
import 'package:smivo/features/auth/providers/auth_provider.dart';
import 'package:smivo/core/providers/moderation_provider.dart';

part 'chat_provider.g.dart';

/// Display model for the chat list UI.
class ChatConversation {
  final String id;
  final String name;
  final String latestMessage;
  final String time;
  final int unreadCount;
  final String? avatarUrl;
  final String? initials;
  final String listingTitle;
  // Fields for search and feature flags
  final String partnerName;
  final String partnerEmail;
  final String listingDescription;
  final double listingPrice;
  final bool isPinned;
  final bool isArchived;
  final bool isUnreadOverride;

  ChatConversation({
    required this.id,
    required this.name,
    required this.latestMessage,
    required this.time,
    this.unreadCount = 0,
    this.avatarUrl,
    this.initials,
    required this.listingTitle,
    this.partnerName = '',
    this.partnerEmail = '',
    this.listingDescription = '',
    this.listingPrice = 0.0,
    this.isPinned = false,
    this.isArchived = false,
    this.isUnreadOverride = false,
  });
}

/// Fetches the user's chat rooms and subscribes to global message
/// inserts to keep the list fresh.
///
/// When any new message arrives in any room the user participates in,
/// the list is re-fetched so last_message_at, last_message preview,
/// and unread counts all update in real-time.
@riverpod
class ChatRoomList extends _$ChatRoomList {
  RealtimeChannel? _channel;

  @override
  Future<List<ChatRoom>> build() async {
    final user = ref.watch(authStateProvider).valueOrNull;
    if (user == null) return [];

    // Clean up subscription on dispose
    ref.onDispose(() {
      _channel?.unsubscribe();
      _channel = null;
    });

    // Subscribe to new messages
    _subscribe(user.id);

    final allRooms = await ref.read(chatRepositoryProvider).fetchChatRooms(user.id);
    
    // Filter out chat rooms where the other participant is blocked
    final blockedUserIds = ref.watch(blockedUsersProvider).valueOrNull ?? <String>[];
    final blockedSet = blockedUserIds.toSet();
    
    return allRooms.where((room) {
      final otherUserId = room.buyerId == user.id ? room.sellerId : room.buyerId;
      return !blockedSet.contains(otherUserId);
    }).toList();
  }

  void _subscribe(String userId) {
    final client = ref.read(supabaseClientProvider);
    _channel = client
        .channel('chat_rooms_list:$userId')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: AppConstants.tableMessages,
          callback: (payload) {
            // A new message was inserted somewhere in the system.
            // Re-fetch chat rooms to refresh unread counts and last message.
            // RLS ensures we only get messages for rooms we're in.
            ref.invalidateSelf();
          },
        )
        .subscribe();
  }

  /// Toggle pin state and refresh list.
  Future<void> togglePin(String roomId, bool isPinned) async {
    await ref.read(chatRepositoryProvider).togglePin(roomId, isPinned);
    ref.invalidateSelf();
  }

  /// Toggle archive state and refresh list.
  Future<void> toggleArchive(String roomId, bool isArchived) async {
    await ref.read(chatRepositoryProvider).toggleArchive(roomId, isArchived);
    ref.invalidateSelf();
  }

  /// Toggle manual unread override and refresh list.
  Future<void> toggleUnreadOverride(String roomId, bool isUnread) async {
    await ref
        .read(chatRepositoryProvider)
        .toggleUnreadOverride(roomId, isUnread);
    ref.invalidateSelf();
  }
}

/// Manages messages for a single chat room with realtime updates.
///
/// Subscribes to Supabase Realtime on build and unsubscribes on dispose.
/// New messages are appended to state; history is fetched once at build.
@riverpod
class ChatMessages extends _$ChatMessages {
  RealtimeChannel? _channel;

  @override
  Future<List<Message>> build(String chatRoomId) async {
    // Clean up subscription when provider is disposed
    ref.onDispose(() {
      _channel?.unsubscribe();
      _channel = null;
    });

    final repository = ref.watch(chatRepositoryProvider);

    // 1. Fetch message history
    final messages = await repository.fetchMessages(chatRoomId);

    // 2. Subscribe to new messages
    _channel = repository.subscribeToMessages(
      chatRoomId: chatRoomId,
      onMessage: (newMessage) {
        // Append new message to current state
        final currentMessages = state.valueOrNull ?? [];
        // Avoid duplicates (optimistic update + realtime echo)
        if (currentMessages.any((m) => m.id == newMessage.id)) return;
        state = AsyncValue.data([...currentMessages, newMessage]);
      },
    );

    return messages;
  }

  /// Sends a message and marks the chat as read for the sender.
  Future<void> sendMessage(String content) async {
    final user = ref.read(authStateProvider).valueOrNull;
    if (user == null) return;
    if (content.trim().isEmpty) return;

    final repository = ref.read(chatRepositoryProvider);
    
    // The realtime listener will receive the message and update state.
    await repository.sendMessage(
      chatRoomId: chatRoomId,
      senderId: user.id,
      content: content.trim(),
    );
  }

  /// Uploads an image and sends it as a message.
  Future<void> sendImage(Uint8List fileBytes, String fileName) async {
    final user = ref.read(authStateProvider).valueOrNull;
    if (user == null) return;

    final storageRepo = ref.read(storageRepositoryProvider);
    final chatRepo = ref.read(chatRepositoryProvider);

    // 1. Upload image
    final imageUrl = await storageRepo.uploadChatMessageImage(
      chatRoomId: chatRoomId,
      fileName: fileName,
      fileBytes: fileBytes,
    );

    // 2. Send message
    await chatRepo.sendImageMessage(
      chatRoomId: chatRoomId,
      senderId: user.id,
      imageUrl: imageUrl,
    );
  }

  /// Marks all messages in this room as read for the current user.
  Future<void> markAsRead() async {
    final user = ref.read(authStateProvider).valueOrNull;
    if (user == null) return;

    final repository = ref.read(chatRepositoryProvider);
    await repository.markMessagesAsRead(
      chatRoomId: chatRoomId,
      userId: user.id,
    );

    // Invalidate chat room list so unread counts refresh
    ref.invalidate(chatRoomListProvider);
  }
}

/// Total unread messages across all chat rooms for the current user.
@riverpod
Future<int> chatTotalUnread(Ref ref) async {
  final user = ref.watch(authStateProvider).valueOrNull;
  if (user == null) return 0;
  
  final rooms = await ref.watch(chatRoomListProvider.future);
  return rooms.fold<int>(0, (sum, room) {
    final isBuyer = room.buyerId == user.id;
    return sum + (isBuyer ? room.unreadCountBuyer : room.unreadCountSeller);
  });
}
/// Fetches details for a single chat room.
@riverpod
Future<ChatRoom> chatRoom(Ref ref, String chatRoomId) async {
  // NOTE: Use ref.read (not ref.watch) for cache lookup to avoid
  // re-triggering this provider every time the chat list refreshes.
  // This prevents the AppBar contact info from flickering.
  final list = ref.read(chatRoomListProvider).valueOrNull;
  final cached = list?.firstWhere((r) => r.id == chatRoomId);
  if (cached != null) return cached;

  final repository = ref.read(chatRepositoryProvider);
  return repository.fetchChatRoom(chatRoomId);
}

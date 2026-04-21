import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:smivo/data/models/chat_room.dart';
import 'package:smivo/data/models/message.dart';
import 'package:smivo/data/repositories/chat_repository.dart';
import 'package:smivo/features/auth/providers/auth_provider.dart';

part 'chat_provider.g.dart';

/// Fetches the list of chat rooms for the current user.
///
/// Watches authStateProvider so it refreshes when the user logs in/out.
@riverpod
Future<List<ChatRoom>> chatRoomList(Ref ref) async {
  final user = ref.watch(authStateProvider).valueOrNull;
  if (user == null) return [];
  
  final repository = ref.watch(chatRepositoryProvider);
  return repository.fetchChatRooms(user.id);
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

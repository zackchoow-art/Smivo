import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:smivo/core/constants/app_constants.dart';
import 'package:smivo/core/providers/supabase_provider.dart';
import 'package:smivo/data/models/group_chat_room.dart' as model;
import 'package:smivo/data/models/group_message.dart';
import 'package:smivo/data/repositories/group_chat_repository.dart';

part 'group_chat_provider.g.dart';

/// Fetches and manages the group chat room for a carpool trip.
@riverpod
class GroupChatRoomData extends _$GroupChatRoomData {
  @override
  Future<model.GroupChatRoom> build(String tripId) async {
    final repo = ref.watch(groupChatRepositoryProvider);
    return repo.fetchGroupChatRoom(tripId);
  }
}

/// Manages group chat messages with Realtime subscription.
///
/// On build, fetches the full message history and subscribes to
/// new messages via Supabase Realtime. On dispose, unsubscribes
/// the channel to prevent memory leaks and ghost subscriptions.
@riverpod
class GroupChatMessages extends _$GroupChatMessages {
  RealtimeChannel? _channel;
  late String _roomId;

  @override
  Future<List<GroupMessage>> build(String roomId) async {
    _roomId = roomId;
    final repo = ref.watch(groupChatRepositoryProvider);
    final messages = await repo.fetchGroupMessages(roomId);

    // Subscribe to new messages via Realtime
    _channel = repo.subscribeToGroupMessages(
      roomId: roomId,
      onMessage: _onNewMessage,
    );

    // NOTE: Cancel subscription when provider is disposed to prevent
    // duplicate subscriptions when navigating away and back.
    ref.onDispose(() {
      _channel?.unsubscribe();
      _channel = null;
    });

    return messages;
  }

  /// Handles incoming Realtime messages.
  ///
  /// NOTE: Realtime payloads don't include JOIN relations, so sender
  /// will be null. We re-fetch the full list to get complete data.
  /// This is acceptable because group chats are small (max 5 members).
  void _onNewMessage(GroupMessage message) {
    // Optimistic: append the partial message immediately for instant feedback
    state.whenData((messages) {
      // Avoid duplicates if the fetched list already contains this message
      if (messages.any((m) => m.id == message.id)) return;
      state = AsyncValue.data([...messages, message]);
    });

    // Then re-fetch to get sender profile data
    _refetchMessages();
  }

  Future<void> _refetchMessages() async {
    final repo = ref.read(groupChatRepositoryProvider);
    final messages = await repo.fetchGroupMessages(_roomId);
    if (state.hasValue) {
      state = AsyncValue.data(messages);
    }
  }

  /// Sends a text message and appends it to the local list.
  Future<void> sendMessage(String content) async {
    if (content.trim().isEmpty) return;

    final client = ref.read(supabaseClientProvider);
    final userId = client.auth.currentUser?.id;
    if (userId == null) return;

    final repo = ref.read(groupChatRepositoryProvider);
    try {
      final message = await repo.sendGroupMessage(
        roomId: _roomId,
        senderId: userId,
        content: content.trim(),
      );

      // Append to local state (Realtime will also fire, dedup handles it)
      state.whenData((messages) {
        if (!messages.any((m) => m.id == message.id)) {
          state = AsyncValue.data([...messages, message]);
        }
      });
    } catch (e) {
      debugPrint('Failed to send group message: $e');
    }
  }

  /// Sends an image message after the image has been uploaded to Storage.
  Future<void> sendImageMessage(String imageUrl) async {
    final client = ref.read(supabaseClientProvider);
    final userId = client.auth.currentUser?.id;
    if (userId == null) return;

    final repo = ref.read(groupChatRepositoryProvider);
    try {
      final message = await repo.sendGroupImageMessage(
        roomId: _roomId,
        senderId: userId,
        imageUrl: imageUrl,
      );

      state.whenData((messages) {
        if (!messages.any((m) => m.id == message.id)) {
          state = AsyncValue.data([...messages, message]);
        }
      });
    } catch (e) {
      debugPrint('Failed to send group image message: $e');
    }
  }
}

/// Fetches all group chat rooms where the current user is an active member.
///
/// Used by ChatListScreen to show group chats alongside 1-on-1 conversations.
/// Automatically re-fetches when the provider is invalidated.
@riverpod
Future<List<model.GroupChatRoom>> userGroupChatRooms(Ref ref) async {
  final client = ref.read(supabaseClientProvider);
  final userId = client.auth.currentUser?.id;
  if (userId == null) return [];

  // Subscribe to new group messages to refresh the list and unread counts
  final channel = client
      .channel('group_chat_rooms_list:$userId')
      .onPostgresChanges(
        event: PostgresChangeEvent.insert,
        schema: 'public',
        table: AppConstants.tableGroupMessages,
        callback: (payload) {
          // A new group message was inserted.
          // Invalidate the unread counts to refresh badge.
          ref.invalidate(groupUnreadCountsProvider);
          // Invalidate self so the group chat list order and previews update.
          ref.invalidateSelf();
        },
      )
      .subscribe();

  ref.onDispose(() {
    channel.unsubscribe();
  });

  return ref.read(groupChatRepositoryProvider).fetchUserGroupChatRooms(userId);
}

/// Returns a map of { roomId: unreadCount } for all group chats.
///
/// Uses keepAlive to avoid auto-dispose cycles that cause UI flicker.
/// Invalidated explicitly when the user enters/leaves a group chat room.
@riverpod
Future<Map<String, int>> groupUnreadCounts(Ref ref) async {
  // NOTE: keepAlive prevents the provider from being disposed when the
  // chat list scrolls off-screen and back, avoiding loading → data flicker.
  ref.keepAlive();
  final client = ref.read(supabaseClientProvider);
  final userId = client.auth.currentUser?.id;
  if (userId == null) return {};
  return ref.read(groupChatRepositoryProvider).fetchGroupUnreadCounts(userId);
}

/// Marks a group chat room as read and refreshes unread counts.
///
/// Called when the user enters a group chat screen to clear the badge.
/// Also registers the group active session for push suppression.
Future<void> markGroupChatAsRead(WidgetRef ref, String roomId) async {
  final client = ref.read(supabaseClientProvider);
  final userId = client.auth.currentUser?.id;
  if (userId == null) return;

  final repo = ref.read(groupChatRepositoryProvider);

  // Update last_read_at so unread count resets
  await repo.updateLastReadAt(roomId: roomId, userId: userId);

  // Register active session for push suppression
  await repo.setGroupActiveSession(userId: userId, roomId: roomId);

  // Refresh the unread counts in the chat list
  ref.invalidate(groupUnreadCountsProvider);
}

/// Clears the group chat active session when leaving the room.
Future<void> clearGroupChatSession(WidgetRef ref) async {
  final client = ref.read(supabaseClientProvider);
  final userId = client.auth.currentUser?.id;
  if (userId == null) return;

  final repo = ref.read(groupChatRepositoryProvider);
  await repo.clearGroupActiveSession(userId);

  // Refresh unread counts so the list reflects any messages received
  ref.invalidate(groupUnreadCountsProvider);
}

/// Toggles the pin state of a group chat room for the current user.
///
/// [roomId] is the group_chat_rooms.id (not trip_id).
/// After toggling, invalidates [userGroupChatRoomsProvider] so the list
/// re-sorts with pinned rooms at the top.
Future<void> toggleGroupPin(
  WidgetRef ref,
  String roomId,
  bool isPinned,
) async {
  final client = ref.read(supabaseClientProvider);
  final userId = client.auth.currentUser?.id;
  if (userId == null) return;

  await ref.read(groupChatRepositoryProvider).toggleGroupPin(
    roomId: roomId,
    userId: userId,
    isPinned: isPinned,
  );
  ref.invalidate(userGroupChatRoomsProvider);
}

/// Toggles the archive state of a group chat room for the current user.
Future<void> toggleGroupArchive(
  WidgetRef ref,
  String roomId,
  bool isArchived,
) async {
  final client = ref.read(supabaseClientProvider);
  final userId = client.auth.currentUser?.id;
  if (userId == null) return;

  await ref.read(groupChatRepositoryProvider).toggleGroupArchive(
    roomId: roomId,
    userId: userId,
    isArchived: isArchived,
  );
  ref.invalidate(userGroupChatRoomsProvider);
}

/// Toggles the unread-override state of a group chat room for the current user.
Future<void> toggleGroupUnreadOverride(
  WidgetRef ref,
  String roomId,
  bool isUnreadOverride,
) async {
  final client = ref.read(supabaseClientProvider);
  final userId = client.auth.currentUser?.id;
  if (userId == null) return;

  await ref.read(groupChatRepositoryProvider).toggleGroupUnreadOverride(
    roomId: roomId,
    userId: userId,
    isUnreadOverride: isUnreadOverride,
  );
  // NOTE: Also reset the override to false when marking as read
  // is done via markGroupChatAsRead; here we only handle the override flag.
  ref.invalidate(userGroupChatRoomsProvider);
  ref.invalidate(groupUnreadCountsProvider);
}

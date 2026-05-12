import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:smivo/core/providers/supabase_provider.dart';
import 'package:smivo/data/models/group_chat_member.dart';
import 'package:smivo/data/models/group_chat_room.dart' as model;
import 'package:smivo/data/repositories/group_chat_repository.dart';
import 'package:smivo/features/carpool/providers/group_chat_provider.dart';
import 'package:intl/intl.dart';
import 'package:smivo/data/models/carpool_trip.dart';
import 'package:smivo/features/carpool/providers/carpool_detail_provider.dart';
import 'package:smivo/features/carpool/widgets/group_message_bubble.dart';
import 'package:smivo/features/carpool/widgets/group_member_sheet.dart';

/// Full-screen group chat for a carpool trip.
///
/// Displays the message history with Realtime updates and provides
/// a text input for sending new messages. The AppBar shows the room
/// name and a members button to view the participant list.
class GroupChatScreen extends ConsumerStatefulWidget {
  const GroupChatScreen({
    super.key,
    required this.tripId,
  });

  final String tripId;

  @override
  ConsumerState<GroupChatScreen> createState() => _GroupChatScreenState();
}

class _GroupChatScreenState extends ConsumerState<GroupChatScreen> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();
  String? _roomId;
  bool _hasMarkedRead = false;
  // Heartbeat timer: refreshes updated_at in user_active_sessions every 90s
  // to keep the session alive within the Edge Function's 2-minute TTL window.
  Timer? _sessionHeartbeat;

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    // Stop the heartbeat before clearing — prevents a race where the timer
    // fires between clearGroupActiveSession and the next push delivery.
    _sessionHeartbeat?.cancel();
    // Clear active session on leave so push notifications resume
    clearGroupChatSession(ref);
    super.dispose();
  }

  /// Marks the room as read once when the room ID becomes available.
  /// Also starts the heartbeat timer for push suppression.
  void _markAsReadOnce(String roomId) {
    if (_hasMarkedRead) return;
    _hasMarkedRead = true;
    markGroupChatAsRead(ref, roomId);

    // Start heartbeat to keep the session alive
    final userId = ref.read(supabaseClientProvider).auth.currentUser?.id;
    if (userId != null) {
      _sessionHeartbeat = Timer.periodic(
        const Duration(seconds: 90),
        (_) => _writeGroupSession(userId, roomId),
      );
    }
  }

  /// Re-writes the group active session to refresh updated_at.
  void _writeGroupSession(String userId, String roomId) {
    ref
        .read(groupChatRepositoryProvider)
        .setGroupActiveSession(userId: userId, roomId: roomId)
        .catchError((e) {
          debugPrint('[GroupChat] setGroupActiveSession failed: $e');
        });
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      Future.delayed(const Duration(milliseconds: 100), () {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut,
          );
        }
      });
    }
  }

  Future<void> _sendMessage() async {
    final content = _messageController.text.trim();
    if (content.isEmpty || _roomId == null) return;

    _messageController.clear();
    final messagesNotifier =
        ref.read(groupChatMessagesProvider(_roomId!).notifier);
    await messagesNotifier.sendMessage(content);
    _scrollToBottom();
  }

  void _showMemberSheet(model.GroupChatRoom room) {
    final currentUserId =
        ref.read(supabaseClientProvider).auth.currentUser?.id ?? '';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.4,
        minChildSize: 0.25,
        maxChildSize: 0.7,
        expand: false,
        builder: (_, scrollController) => GroupMemberSheet(
          members: room.members,
          creatorId: room.createdBy,
          currentUserId: currentUserId,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currentUserId =
        ref.watch(supabaseClientProvider).auth.currentUser?.id;
    final roomAsync = ref.watch(groupChatRoomDataProvider(widget.tripId));

    return Scaffold(
      appBar: AppBar(
        actions: [
          // Overlapping avatar row — shows up to 5 member avatars in AppBar
          roomAsync.when(
            data: (room) => Padding(
              padding: const EdgeInsets.only(right: 4),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Overlap avatars by using negative spacing via Transform
                  for (int i = 0;
                      i < room.members.take(5).length;
                      i++)
                    Transform.translate(
                      // NOTE: Negative X offset creates the overlapping stack effect.
                      offset: Offset(i * -8.0, 0),
                      child: _MemberAvatar(
                        member: room.members[i],
                        theme: theme,
                      ),
                    ),
                ],
              ),
            ),
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
          ),
          roomAsync.when(
            data: (room) => IconButton(
              icon: const Icon(Icons.group),
              tooltip: 'View Members',
              onPressed: () => _showMemberSheet(room),
            ),
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
          ),
        ],
      ),
      body: roomAsync.when(
        data: (room) {
          _roomId = room.id;
          // Mark as read on first load to clear badge + register session
          _markAsReadOnce(room.id);
          return _buildChatBody(room.id, currentUserId, theme);
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.chat_bubble_outline,
                  size: 48,
                  color: theme.colorScheme.outline,
                ),
                const SizedBox(height: 12),
                Text(
                  'Failed to load chat',
                  style: theme.textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  error.toString(),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.outline,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildChatBody(
    String roomId,
    String? currentUserId,
    ThemeData theme,
  ) {
    final messagesAsync = ref.watch(groupChatMessagesProvider(roomId));
    final tripAsync = ref.watch(carpoolDetailProvider(widget.tripId));

    return Column(
      children: [
        tripAsync.when(
          data: (trip) {
            if (trip == null) return const SizedBox.shrink();
            return _TripHeaderCard(trip: trip, theme: theme);
          },
          loading: () => const SizedBox.shrink(),
          error: (_, __) => const SizedBox.shrink(),
        ),
        // Message list
        Expanded(
          child: messagesAsync.when(
            data: (messages) {
              // Scroll to bottom when new messages arrive
              WidgetsBinding.instance.addPostFrameCallback((_) {
                _scrollToBottom();
              });

              if (messages.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.forum_outlined,
                        size: 48,
                        color: theme.colorScheme.outline.withValues(alpha: 0.5),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'No messages yet',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: theme.colorScheme.outline,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Start the conversation!',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.outline.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),
                );
              }

              return ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 12,
                ),
                itemCount: messages.length,
                itemBuilder: (context, index) {
                  final msg = messages[index];
                  return GroupMessageBubble(
                    message: msg,
                    isMe: msg.senderId == currentUserId,
                  );
                },
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, _) => Center(
              child: Text('Failed to load messages: $error'),
            ),
          ),
        ),

        // Message input
        _MessageInput(
          controller: _messageController,
          onSend: _sendMessage,
          theme: theme,
        ),
      ],
    );
  }
}

/// Message input bar at the bottom of the chat screen.
class _MessageInput extends StatelessWidget {
  const _MessageInput({
    required this.controller,
    required this.onSend,
    required this.theme,
  });

  final TextEditingController controller;
  final VoidCallback onSend;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: 12,
        right: 8,
        top: 8,
        bottom: 8 + MediaQuery.of(context).padding.bottom,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: theme.colorScheme.outline.withValues(alpha: 0.1),
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              decoration: InputDecoration(
                hintText: 'Type a message...',
                hintStyle: TextStyle(color: theme.colorScheme.outline),
                filled: true,
                fillColor: theme.colorScheme.surfaceContainerHighest
                    .withValues(alpha: 0.5),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
              ),
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => onSend(),
              maxLines: 4,
              minLines: 1,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            decoration: BoxDecoration(
              color: theme.colorScheme.primary,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: Icon(
                Icons.send,
                color: theme.colorScheme.onPrimary,
                size: 20,
              ),
              onPressed: onSend,
            ),
          ),
        ],
      ),
    );
  }
}

/// A small circular avatar for a single group chat member in the AppBar.
///
/// Falls back to a person icon when the member has no avatar URL.
class _MemberAvatar extends StatelessWidget {
  const _MemberAvatar({required this.member, required this.theme});

  final GroupChatMember member;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    final avatarUrl = member.user?.avatarUrl;
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        // White border visually separates overlapping avatars
        border: Border.all(color: theme.colorScheme.surface, width: 1.5),
      ),
      child: CircleAvatar(
        radius: 14,
        backgroundColor: theme.colorScheme.surfaceContainerHigh,
        backgroundImage:
            avatarUrl != null && avatarUrl.isNotEmpty
                ? NetworkImage(avatarUrl)
                : null,
        child:
            (avatarUrl == null || avatarUrl.isEmpty)
                ? Icon(
                    Icons.person,
                    size: 14,
                    color: theme.colorScheme.onSurfaceVariant
                        .withValues(alpha: 0.5),
                  )
                : null,
      ),
    );
  }
}

/// Header card displaying trip's from/to/time info at the top of the chat.
class _TripHeaderCard extends StatelessWidget {
  const _TripHeaderCard({required this.trip, required this.theme});

  final CarpoolTrip trip;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.colorScheme.outline.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 24,
                child: Icon(Icons.trip_origin, size: 16, color: Colors.green.shade600),
              ),
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 50,
                      child: Text('From:', style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                    ),
                    Expanded(child: Text(trip.departureAddress, style: theme.textTheme.bodyMedium)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 24,
                child: Icon(Icons.location_on, size: 16, color: Colors.red.shade600),
              ),
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 50,
                      child: Text('To:', style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                    ),
                    Expanded(child: Text(trip.destinationAddress, style: theme.textTheme.bodyMedium)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 24,
                child: Icon(Icons.access_time, size: 16, color: theme.colorScheme.onSurfaceVariant),
              ),
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 50,
                      child: Text('Time:', style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                    ),
                    Expanded(child: Text(DateFormat('MM-dd HH:mm').format(trip.departureTime.toLocal()), style: theme.textTheme.bodyMedium)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}


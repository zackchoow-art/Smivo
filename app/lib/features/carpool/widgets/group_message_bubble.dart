import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:smivo/data/models/group_message.dart';
import 'package:smivo/shared/widgets/smivo_user_avatar.dart';

/// Message bubble for group chat, supporting text, image, and system messages.
///
/// System messages (member joined/left) are rendered as centered, muted text.
/// Regular messages show a sender avatar, sender name, content, and timestamp.
class GroupMessageBubble extends StatelessWidget {
  const GroupMessageBubble({
    super.key,
    required this.message,
    required this.isMe,
  });

  final GroupMessage message;
  final bool isMe;

  @override
  Widget build(BuildContext context) {
    // System messages (join/leave/kick notifications) have no sender identity
    if (message.messageType == 'system') {
      return _SystemMessageBubble(message: message);
    }

    return _ChatMessageBubble(
      message: message,
      isMe: isMe,
    );
  }
}

/// Centered system notification (e.g. "Alice joined the trip!").
class _SystemMessageBubble extends StatelessWidget {
  const _SystemMessageBubble({required this.message});

  final GroupMessage message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 32),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest
                .withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            message.content,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.outline,
              fontStyle: FontStyle.italic,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}

/// Standard chat bubble with sender avatar, sender name, content, and timestamp.
///
/// Layout:
///   Others: [Avatar]  [Bubble: content + "Name · time"]
///   Own:               [Bubble: content + "time"]  [Avatar]
class _ChatMessageBubble extends StatelessWidget {
  const _ChatMessageBubble({
    required this.message,
    required this.isMe,
  });

  final GroupMessage message;
  final bool isMe;

  /// Formats the timestamp as "HH:mm" for today, or "Yesterday HH:mm"
  /// for messages from the previous calendar day.
  String _formatTime(DateTime time) {
    final local = time.toLocal();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final messageDay = DateTime(local.year, local.month, local.day);

    if (messageDay == today) {
      return DateFormat('HH:mm').format(local);
    } else if (today.difference(messageDay).inDays == 1) {
      return 'Yesterday ${DateFormat('HH:mm').format(local)}';
    } else {
      return DateFormat('MM/dd HH:mm').format(local);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final senderName = message.sender?.displayName ?? 'Unknown';
    final timeStr = _formatTime(message.createdAt);

    // Build avatar widget — use SmivoUserAvatar when sender profile is present,
    // fall back to a plain CircleAvatar if profile data is missing (Realtime
    // payloads do not include JOIN relations).
    Widget avatarWidget;
    if (message.sender != null) {
      avatarWidget = SmivoUserAvatar(
        user: message.sender!,
        radius: 12,
        enableTap: false,
      );
    } else {
      avatarWidget = CircleAvatar(
        radius: 12,
        backgroundColor: theme.colorScheme.surfaceContainerHigh,
        child: Icon(
          Icons.person,
          size: 12,
          color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
        ),
      );
    }

    // NOTE: Use LayoutBuilder instead of MediaQuery.size.width so that the
    // bubble max-width is relative to the actual parent column width, not the
    // full screen. On iPad split view the panel is narrower than the screen, so
    // using screen width caused overflow. 0.72 of the parent is safe for both.
    return LayoutBuilder(
      builder: (context, constraints) {
        final bubbleMaxWidth = constraints.maxWidth * 0.72;

        final bubble = Container(
          constraints: BoxConstraints(maxWidth: bubbleMaxWidth),
          margin: const EdgeInsets.symmetric(vertical: 2),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: isMe
                ? theme.colorScheme.primary
                : theme.colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(16),
              topRight: const Radius.circular(16),
              bottomLeft: Radius.circular(isMe ? 16 : 4),
              bottomRight: Radius.circular(isMe ? 4 : 16),
            ),
          ),
          child: Column(
            crossAxisAlignment:
                isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: [
              // Message content
              if (message.messageType == 'image' && message.imageUrl != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    message.imageUrl!,
                    width: 200,
                    height: 200,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const Icon(
                      Icons.broken_image,
                      size: 48,
                    ),
                  ),
                )
              else
                Text(
                  message.content,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: isMe
                        ? theme.colorScheme.onPrimary
                        : theme.colorScheme.onSurface,
                  ),
                ),

              const SizedBox(height: 4),

              // \"Sender Name · HH:mm\" footer (name only for others' messages)
              Text(
                isMe ? timeStr : '$senderName · $timeStr',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: isMe
                      ? theme.colorScheme.onPrimary.withValues(alpha: 0.7)
                      : theme.colorScheme.outline,
                  fontSize: 10,
                ),
              ),
            ],
          ),
        );

        return Padding(
          padding: EdgeInsets.only(
            left: isMe ? 48 : 8,
            right: isMe ? 8 : 48,
            top: 2,
            bottom: 2,
          ),
          child: Row(
            mainAxisAlignment:
                isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: isMe
                ? [bubble, const SizedBox(width: 6), avatarWidget]
                : [avatarWidget, const SizedBox(width: 6), bubble],
          ),
        );
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:smivo/core/theme/theme_extensions.dart';
import 'package:smivo/features/chat/providers/chat_provider.dart';

class ChatListItem extends StatelessWidget {
  const ChatListItem({
    super.key,
    required this.conversation,
    required this.onTap,
    this.isArchiveView = false,
    this.onTogglePin,
    this.onToggleUnread,
    this.onArchive,
  });

  final ChatConversation conversation;
  final VoidCallback onTap;
  // When true, the archive action becomes "Unarchive"
  final bool isArchiveView;
  final VoidCallback? onTogglePin;
  final VoidCallback? onToggleUnread;
  final VoidCallback? onArchive;

  @override
  Widget build(BuildContext context) {
    final colors = context.smivoColors;
    final typo = context.smivoTypo;
    final radius = context.smivoRadius;

    // NOTE: ClipRRect wraps the entire Slidable so action buttons
    // share the same rounded corners as the card — no visual seam.
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius.card),
        child: Slidable(
          key: ValueKey(conversation.id),
          // Right-to-left (start) swipe: Pin + Mark Unread
          startActionPane: ActionPane(
            motion: const BehindMotion(),
            extentRatio: 0.5,
            children: [
              SlidableAction(
                onPressed: (_) => onTogglePin?.call(),
                backgroundColor: colors.primary,
                foregroundColor: colors.onPrimary,
                icon: conversation.isPinned
                    ? Icons.push_pin
                    : Icons.push_pin_outlined,
                label: conversation.isPinned ? 'Unpin' : 'Pin',
              ),
              SlidableAction(
                onPressed: (_) => onToggleUnread?.call(),
                backgroundColor: colors.warning,
                foregroundColor: Colors.white,
                icon: Icons.mark_email_unread_outlined,
                label: 'Unread',
              ),
            ],
          ),
          // Left-to-right (end) swipe: Archive / Unarchive
          endActionPane: ActionPane(
            motion: const BehindMotion(),
            extentRatio: 0.25,
            children: [
              SlidableAction(
                onPressed: (_) => onArchive?.call(),
                backgroundColor: isArchiveView
                    ? colors.success
                    : colors.onSurfaceVariant,
                foregroundColor: Colors.white,
                icon: isArchiveView
                    ? Icons.unarchive_outlined
                    : Icons.archive_outlined,
                label: isArchiveView ? 'Unarchive' : 'Archive',
              ),
            ],
          ),
          child: GestureDetector(
            onTap: onTap,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                // NOTE: Pinned rooms get a slightly tinted background to stand out.
                color: conversation.isPinned
                    ? colors.primary.withValues(alpha: 0.07)
                    : colors.surfaceContainerHigh,
              ),
              child: Row(
                children: [
                  // Avatar with unread indicator
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      CircleAvatar(
                        radius: 24,
                        backgroundColor: colors.surfaceContainer,
                        backgroundImage: conversation.avatarUrl != null
                            ? NetworkImage(conversation.avatarUrl!)
                            : null,
                        child: conversation.avatarUrl == null &&
                                conversation.initials != null
                            ? Text(
                                conversation.initials!,
                                style: typo.titleMedium
                                    .copyWith(color: colors.onSurface),
                              )
                            : null,
                      ),
                      if (conversation.unreadCount > 0)
                        Positioned(
                          top: -4,
                          right: -4,
                          child: Badge(
                            label: Text(
                              conversation.unreadCount > 99
                                  ? '99+'
                                  : conversation.unreadCount.toString(),
                              style: TextStyle(
                                  fontSize: 10, color: colors.onPrimary),
                            ),
                            backgroundColor: colors.error,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(width: 12),

                  // Name, message, and pin indicator
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Row(
                                children: [
                                  // Pin indicator icon
                                  if (conversation.isPinned) ...[
                                    Icon(
                                      Icons.push_pin,
                                      size: 12,
                                      color: colors.primary
                                          .withValues(alpha: 0.7),
                                    ),
                                    const SizedBox(width: 4),
                                  ],
                                  Expanded(
                                    child: Text(
                                      conversation.name,
                                      style: typo.titleMedium.copyWith(
                                        color: colors.onSurface,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              conversation.time,
                              style: typo.labelSmall.copyWith(
                                color: colors.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          conversation.latestMessage,
                          style: typo.bodyMedium.copyWith(
                            color: colors.onSurfaceVariant,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

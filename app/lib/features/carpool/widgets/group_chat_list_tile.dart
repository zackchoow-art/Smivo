import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:smivo/core/theme/theme_extensions.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:intl/intl.dart';

import 'package:smivo/data/models/group_chat_member.dart';
import 'package:smivo/data/models/group_chat_room.dart' as model;
import 'package:smivo/features/carpool/providers/carpool_detail_provider.dart';
import 'package:smivo/shared/widgets/smivo_user_avatar.dart';

/// A chat list tile representing a carpool group chat room.
///
/// Supports swipe gestures identical to 1-on-1 [ChatListItem]:
///   - Right swipe (start pane): Pin / Unpin + Mark Unread
///   - Left swipe (end pane):   Archive / Unarchive
class GroupChatListTile extends ConsumerWidget {
  const GroupChatListTile({
    super.key,
    required this.room,
    required this.onTap,
    this.unreadCount = 0,
    // Per-member preference state — passed from _GroupChatListSection
    this.isPinned = false,
    this.isArchived = false,
    this.isUnreadOverride = false,
    // Swipe action callbacks — null disables that action
    this.onTogglePin,
    this.onToggleArchive,
    this.onToggleUnread,
  });

  final model.GroupChatRoom room;
  final VoidCallback onTap;
  final int unreadCount;

  // Per-member preferences
  final bool isPinned;
  final bool isArchived;
  final bool isUnreadOverride;

  // Swipe callbacks — mirror ChatListItem's pattern
  final VoidCallback? onTogglePin;
  final VoidCallback? onToggleArchive;
  final VoidCallback? onToggleUnread;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.smivoColors;
    final typo = context.smivoTypo;
    final radius = context.smivoRadius;
    final tripAsync = ref.watch(carpoolDetailProvider(room.tripId));

    // Find the organizer profile
    final organizer = room.members
        .where((m) => m.userId == room.createdBy)
        .firstOrNull
        ?.user;
    final buyers = room.members
        .where((m) => m.userId != room.createdBy)
        .toList();

    // Effective unread count: DB count OR force-unread override flag
    final effectiveUnread =
        isUnreadOverride ? (unreadCount > 0 ? unreadCount : 1) : unreadCount;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius.card),
        child: Slidable(
          key: ValueKey(room.id),
          // Right-to-left (start) swipe: Pin + Mark Unread
          startActionPane: ActionPane(
            motion: const BehindMotion(),
            extentRatio: 0.5,
            children: [
              SlidableAction(
                onPressed: (_) => onTogglePin?.call(),
                backgroundColor: colors.primary,
                foregroundColor: colors.onPrimary,
                icon: isPinned ? Icons.push_pin : Icons.push_pin_outlined,
                label: isPinned ? 'Unpin' : 'Pin',
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
                onPressed: (_) => onToggleArchive?.call(),
                backgroundColor:
                    isArchived ? colors.success : colors.onSurfaceVariant,
                foregroundColor: Colors.white,
                icon: isArchived
                    ? Icons.unarchive_outlined
                    : Icons.archive_outlined,
                label: isArchived ? 'Unarchive' : 'Archive',
              ),
            ],
          ),
          child: GestureDetector(
            onTap: onTap,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                // NOTE: Pinned group chats get a tinted background,
                // mirroring the 1-on-1 ChatListItem visual treatment.
                color: isPinned
                    ? colors.primary.withValues(alpha: 0.07)
                    : colors.surfaceContainerHigh,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Left: Organizer Avatar
                  if (organizer != null)
                    SmivoUserAvatar(
                      user: organizer,
                      radius: 24,
                      enableTap: false,
                    )
                  else
                    CircleAvatar(
                      radius: 24,
                      backgroundColor: colors.surfaceContainer,
                      child: Icon(
                        Icons.person,
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  const SizedBox(width: 12),
                  // Middle & Right: Content
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Top row: Name + pin indicator + time + badge
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Row(
                                children: [
                                  // Pin indicator icon
                                  if (isPinned) ...[
                                    Icon(
                                      Icons.push_pin,
                                      size: 12,
                                      color: colors.primary.withValues(
                                        alpha: 0.7,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                  ],
                                  Expanded(
                                    child: Text(
                                      room.name,
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
                            // Time text + unread badge grouped together
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  timeago.format(
                                    room.updatedAt,
                                    locale: 'en_short',
                                  ),
                                  style: typo.labelSmall.copyWith(
                                    color: colors.primary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                if (effectiveUnread > 0) ...[
                                  const SizedBox(width: 6),
                                  Badge(
                                    label: Text(
                                      effectiveUnread > 99
                                          ? '99+'
                                          : effectiveUnread.toString(),
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: colors.onPrimary,
                                      ),
                                    ),
                                    backgroundColor: colors.error,
                                  ),
                                ],
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        // Bottom row: Departure time | Buyer avatars
                        Row(
                          children: [
                            // Departure time
                            tripAsync.when(
                              data: (trip) {
                                if (trip == null) return const SizedBox.shrink();
                                return Text(
                                  DateFormat('MM-dd HH:mm').format(
                                    trip.departureTime.toLocal(),
                                  ),
                                  style: typo.bodyMedium.copyWith(
                                    color: colors.onSurfaceVariant,
                                  ),
                                );
                              },
                              loading: () => const SizedBox.shrink(),
                              error: (_, __) => const SizedBox.shrink(),
                            ),
                            const Spacer(),
                            // Buyer avatars right-aligned
                            if (buyers.isNotEmpty)
                              _MemberAvatarList(members: buyers),
                          ],
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

/// Side-by-side circular avatars showing up to [_maxVisible] member avatars.
class _MemberAvatarList extends StatelessWidget {
  const _MemberAvatarList({required this.members});

  final List<GroupChatMember> members;

  static const int _maxVisible = 3;
  static const double _avatarRadius = 10.0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final visible = members.take(_maxVisible).toList();
    final overflow = members.length - _maxVisible;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (int i = 0; i < visible.length; i++) ...[
          if (i > 0) const SizedBox(width: 4),
          _AvatarCircle(
            avatarUrl: visible[i].user?.avatarUrl,
            radius: _avatarRadius,
            theme: theme,
          ),
        ],
        if (overflow > 0) ...[
          const SizedBox(width: 4),
          CircleAvatar(
            radius: _avatarRadius,
            backgroundColor: theme.colorScheme.secondaryContainer,
            child: Text(
              '+$overflow',
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSecondaryContainer,
                fontWeight: FontWeight.bold,
                fontSize: 8,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

/// A single circular avatar.
class _AvatarCircle extends StatelessWidget {
  const _AvatarCircle({
    required this.avatarUrl,
    required this.radius,
    required this.theme,
  });

  final String? avatarUrl;
  final double radius;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: radius,
      backgroundColor: theme.colorScheme.surfaceContainerHigh,
      backgroundImage:
          avatarUrl != null && avatarUrl!.isNotEmpty
              ? NetworkImage(avatarUrl!)
              : null,
      child:
          (avatarUrl == null || avatarUrl!.isEmpty)
              ? Icon(
                  Icons.person,
                  size: radius,
                  color: theme.colorScheme.onSurfaceVariant.withValues(
                    alpha: 0.5,
                  ),
                )
              : null,
    );
  }
}

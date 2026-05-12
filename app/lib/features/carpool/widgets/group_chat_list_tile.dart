import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;

import 'package:smivo/data/models/group_chat_member.dart';

/// A chat list tile representing a carpool group chat room.
///
/// Designed to blend into the existing ChatListScreen list alongside 1-on-1
/// chat tiles. The overlapping avatar stack (up to 4 + overflow badge)
/// visually distinguishes group chats from individual conversations.
class GroupChatListTile extends StatelessWidget {
  const GroupChatListTile({
    super.key,
    required this.roomName,
    required this.members,
    required this.lastMessage,
    required this.lastMessageTime,
    required this.onTap,
  });

  /// Human-friendly route label, e.g. "Smith College → Airport".
  final String roomName;

  /// All current members of the group chat (filtered by active status).
  final List<GroupChatMember> members;

  /// Preview text of the most recent message in the room.
  final String lastMessage;

  /// Timestamp of the last message for relative time display.
  final DateTime? lastMessageTime;

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 6),
      leading: _MemberAvatarStack(members: members),
      title: Text(
        roomName,
        style: theme.textTheme.bodyLarge?.copyWith(
          fontWeight: FontWeight.w600,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        lastMessage,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
      trailing: lastMessageTime != null
          ? Text(
              timeago.format(lastMessageTime!, locale: 'en_short'),
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.outline,
              ),
            )
          : null,
      onTap: onTap,
    );
  }
}

/// Overlapping circular avatar stack showing up to [_maxVisible] member avatars.
///
/// If the group has more than [_maxVisible] members, a "+N" overflow badge
/// is shown after the last visible avatar to indicate hidden participants.
class _MemberAvatarStack extends StatelessWidget {
  const _MemberAvatarStack({required this.members});

  final List<GroupChatMember> members;

  // NOTE: Keep this low so the stack fits within a standard ListTile leading slot.
  static const int _maxVisible = 4;
  static const double _avatarRadius = 16.0;
  // NOTE: Each avatar overlaps the previous by this amount to form a dense stack.
  static const double _offset = 20.0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final visible = members.take(_maxVisible).toList();
    final overflow = members.length - _maxVisible;
    // Total width needed: first avatar + (n-1) offsets + optional overflow badge.
    final itemCount = overflow > 0 ? visible.length + 1 : visible.length;
    final totalWidth = _avatarRadius * 2 + (itemCount - 1) * _offset;

    return SizedBox(
      width: totalWidth.clamp(40.0, 120.0),
      height: _avatarRadius * 2,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          for (int i = 0; i < visible.length; i++)
            Positioned(
              left: i * _offset,
              child: _AvatarCircle(
                avatarUrl: visible[i].user?.avatarUrl,
                radius: _avatarRadius,
                theme: theme,
              ),
            ),
          if (overflow > 0)
            Positioned(
              left: visible.length * _offset,
              child: CircleAvatar(
                radius: _avatarRadius,
                backgroundColor: theme.colorScheme.secondaryContainer,
                child: Text(
                  '+$overflow',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSecondaryContainer,
                    fontWeight: FontWeight.bold,
                    fontSize: 9,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// A single circular avatar with border to visually separate overlapping items.
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
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        // White border prevents avatars from merging visually when overlapping.
        border: Border.all(
          color: theme.colorScheme.surface,
          width: 1.5,
        ),
      ),
      child: CircleAvatar(
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
                    color: theme.colorScheme.onSurfaceVariant
                        .withValues(alpha: 0.5),
                  )
                : null,
      ),
    );
  }
}

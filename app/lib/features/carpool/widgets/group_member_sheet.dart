import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'package:smivo/data/models/group_chat_member.dart';

/// Bottom sheet showing all members in a group chat room.
///
/// Displays each member's avatar, display name, and join date.
/// The trip creator is marked with a crown icon badge.
class GroupMemberSheet extends StatelessWidget {
  const GroupMemberSheet({
    super.key,
    required this.members,
    required this.creatorId,
    required this.currentUserId,
  });

  final List<GroupChatMember> members;
  final String creatorId;
  final String currentUserId;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.only(top: 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: theme.colorScheme.outline.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 12),

          // Title
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Icon(
                  Icons.group,
                  color: theme.colorScheme.primary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Trip Members',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Spacer(),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${members.length}',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onPrimaryContainer,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          Divider(
            height: 1,
            color: theme.colorScheme.outline.withValues(alpha: 0.1),
          ),

          // Member list
          Flexible(
            child: ListView.builder(
              shrinkWrap: true,
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: members.length,
              itemBuilder: (context, index) {
                final member = members[index];
                final isCreator = member.userId == creatorId;
                final isCurrentUser = member.userId == currentUserId;

                return ListTile(
                  leading: _MemberAvatar(
                    avatarUrl: member.user?.avatarUrl,
                    isCreator: isCreator,
                  ),
                  title: Row(
                    children: [
                      Flexible(
                        child: Text(
                          member.user?.displayName ?? 'Unknown',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      if (isCurrentUser)
                        Padding(
                          padding: const EdgeInsets.only(left: 6),
                          child: Text(
                            '(You)',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.primary,
                            ),
                          ),
                        ),
                    ],
                  ),
                  subtitle: Text(
                    member.user?.email ?? '',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.outline,
                    ),
                  ),
                  trailing: isCreator
                      ? Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.amber.shade100,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'Creator',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: Colors.amber.shade800,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        )
                      : null,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// Circular avatar with optional creator crown badge.
class _MemberAvatar extends StatelessWidget {
  const _MemberAvatar({
    required this.avatarUrl,
    required this.isCreator,
  });

  final String? avatarUrl;
  final bool isCreator;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        CircleAvatar(
          radius: 20,
          backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
          backgroundImage:
              avatarUrl != null ? CachedNetworkImageProvider(avatarUrl!) : null,
          child:
              avatarUrl == null ? const Icon(Icons.person, size: 20) : null,
        ),
        if (isCreator)
          Positioned(
            bottom: -2,
            right: -2,
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: Colors.amber,
                shape: BoxShape.circle,
                border: Border.all(
                  color: Theme.of(context).colorScheme.surface,
                  width: 1.5,
                ),
              ),
              child: const Icon(
                Icons.star,
                size: 10,
                color: Colors.white,
              ),
            ),
          ),
      ],
    );
  }
}

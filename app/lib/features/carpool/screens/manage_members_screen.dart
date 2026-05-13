import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:smivo/data/models/carpool_member.dart';
import 'package:smivo/features/carpool/providers/carpool_members_provider.dart';
import 'package:smivo/shared/widgets/smivo_user_avatar.dart';

/// Full-screen page for the trip creator to manage members.
///
/// Displays all members grouped by status: pending requests first
/// (with approve/reject actions), then approved, then rejected/left.
/// Uses [CarpoolTripMembers] for the member list and
/// [CarpoolMemberActions] for approve/reject mutations.
class ManageMembersScreen extends ConsumerWidget {
  const ManageMembersScreen({
    super.key,
    required this.tripId,
    required this.creatorId,
  });

  final String tripId;
  final String creatorId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final membersAsync = ref.watch(carpoolTripMembersProvider(tripId));

    return Scaffold(
      appBar: AppBar(title: const Text('Manage Members')),
      body: membersAsync.when(
        data: (members) {
          // Exclude the creator from the management list
          final manageable =
              members.where((m) => m.userId != creatorId).toList();

          if (manageable.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.group_off,
                      size: 64, color: theme.dividerColor),
                  const SizedBox(height: 16),
                  Text(
                    'No members yet',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            );
          }

          // Partition members by status for ordered display
          final pending =
              manageable.where((m) => m.status == 'pending').toList();
          final approved =
              manageable.where((m) => m.status == 'approved').toList();
          final others = manageable
              .where(
                  (m) => m.status != 'pending' && m.status != 'approved')
              .toList();

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(carpoolTripMembersProvider(tripId));
            },
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              children: [
                if (pending.isNotEmpty) ...[
                  _SectionHeader(
                    title: 'Pending Requests',
                    count: pending.length,
                    color: Colors.orange,
                  ),
                  ...pending.map((m) => _MemberTile(
                        member: m,
                        tripId: tripId,
                        status: 'pending',
                      )),
                ],
                if (approved.isNotEmpty) ...[
                  _SectionHeader(
                    title: 'Approved',
                    count: approved.length,
                    color: Colors.green,
                  ),
                  ...approved.map((m) => _MemberTile(
                        member: m,
                        tripId: tripId,
                        status: 'approved',
                      )),
                ],
                if (others.isNotEmpty) ...[
                  _SectionHeader(
                    title: 'Rejected / Left',
                    count: others.length,
                    color: Colors.grey,
                  ),
                  ...others.map((m) => _MemberTile(
                        member: m,
                        tripId: tripId,
                        status: m.status,
                      )),
                ],
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(error.toString(), textAlign: TextAlign.center),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () =>
                    ref.invalidate(carpoolTripMembersProvider(tripId)),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Section header with colored dot indicator and member count.
class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    required this.count,
    required this.color,
  });

  final String title;
  final int count;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            title,
            style: theme.textTheme.titleSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
          const Spacer(),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              '$count',
              style: theme.textTheme.labelSmall?.copyWith(
                color: color,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Individual member tile with avatar, name, status chip, and action buttons.
///
/// NOTE: Approve/reject actions use [CarpoolMemberActions] which atomically
/// handles seat count, group chat membership, and system messages via RPC.
class _MemberTile extends ConsumerWidget {
  const _MemberTile({
    required this.member,
    required this.tripId,
    required this.status,
  });

  final CarpoolMember member;
  final String tripId;
  final String status;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final user = member.user;

    return ListTile(
      leading: _buildAvatar(theme),
      title: Text(
        user?.displayName ?? 'Unknown User',
        style: theme.textTheme.bodyMedium?.copyWith(
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        user?.email ?? '',
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.outline,
        ),
      ),
      trailing: _buildTrailing(context, ref, theme),
    );
  }

  Widget _buildAvatar(ThemeData theme) {
    final user = member.user;
    if (user != null) {
      return SmivoUserAvatar(
        user: user,
        radius: 20,
        enableTap: true,
      );
    }
    return CircleAvatar(
      radius: 20,
      backgroundColor: theme.colorScheme.surfaceContainerHighest,
      child: const Icon(Icons.person, size: 20),
    );
  }

  Widget? _buildTrailing(
      BuildContext context, WidgetRef ref, ThemeData theme) {
    if (status == 'pending') {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Reject button
          IconButton(
            icon: Icon(Icons.close, color: theme.colorScheme.error),
            tooltip: 'Reject',
            onPressed: () => _handleReject(context, ref),
          ),
          const SizedBox(width: 4),
          // Approve button
          IconButton(
            icon: Icon(Icons.check, color: Colors.green.shade600),
            tooltip: 'Approve',
            style: IconButton.styleFrom(
              backgroundColor: Colors.green.shade50,
            ),
            onPressed: () => _handleApprove(context, ref),
          ),
        ],
      );
    }

    // Status chip for non-pending members
    final (label, chipColor) = switch (status) {
      'approved' => ('Joined', Colors.green),
      'rejected' => ('Rejected', Colors.red),
      'left' => ('Left', Colors.grey),
      _ => (status, Colors.grey),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: chipColor.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: theme.textTheme.labelSmall?.copyWith(
          color: chipColor,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Future<void> _handleApprove(BuildContext context, WidgetRef ref) async {
    try {
      await ref
          .read(carpoolMemberActionsProvider.notifier)
          .approveMember(member.id, tripId);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${member.user?.displayName ?? "Member"} approved',
          ),
        ),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to approve: $e')),
      );
    }
  }

  Future<void> _handleReject(BuildContext context, WidgetRef ref) async {
    // Confirm before rejecting to prevent accidental taps
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reject Request'),
        content: Text(
          'Are you sure you want to reject '
          '${member.user?.displayName ?? "this member"}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Reject'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await ref
          .read(carpoolMemberActionsProvider.notifier)
          .rejectMember(member.id, tripId);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${member.user?.displayName ?? "Member"} rejected',
          ),
        ),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to reject: $e')),
      );
    }
  }
}

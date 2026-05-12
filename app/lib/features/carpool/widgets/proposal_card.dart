import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:smivo/data/models/carpool_member.dart';
import 'package:smivo/data/models/carpool_proposal.dart';
import 'package:smivo/features/carpool/providers/carpool_proposals_provider.dart';

/// Card displaying a single proposal with vote progress and action buttons.
///
/// System messages (kick, change_time, etc.) are rendered with appropriate
/// Chinese labels. The vote button row is only shown for pending proposals
/// where the current user is not the proposer.
class ProposalCard extends ConsumerWidget {
  const ProposalCard({
    super.key,
    required this.proposal,
    required this.currentUserId,
    required this.members,
    required this.tripId,
  });

  final CarpoolProposal proposal;
  final String currentUserId;
  final List<CarpoolMember> members;
  final String tripId;

  /// Maps proposal type to a human-readable Chinese title.
  String _buildTitle() {
    switch (proposal.proposalType) {
      case 'kick_member':
        final target = members
            .where((m) => m.userId == proposal.targetUserId)
            .firstOrNull;
        final name = target?.user?.displayName ?? 'Unknown User';
        return 'Remove Member: $name';
      case 'change_time':
        return 'Change Departure Time';
      case 'change_departure':
        return 'Change Departure Location';
      case 'change_destination':
        return 'Change Destination';
      default:
        return 'Proposal';
    }
  }

  /// Status chip color and label.
  (Color, String) _statusInfo(ThemeData theme) {
    switch (proposal.status) {
      case 'pending':
        return (theme.colorScheme.primary, 'Voting');
      case 'approved':
        return (Colors.green, 'Approved');
      case 'rejected':
        return (Colors.red, 'Rejected');
      case 'expired':
        return (Colors.grey, 'Expired');
      default:
        return (Colors.grey, proposal.status);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final (chipColor, chipLabel) = _statusInfo(theme);
    final progress = proposal.requiredVotes > 0
        ? proposal.currentVotes / proposal.requiredVotes
        : 0.0;
    final canVote =
        proposal.status == 'pending' && currentUserId != proposal.proposerId;

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title + status chip
            Row(
              children: [
                Expanded(
                  child: Text(
                    _buildTitle(),
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: chipColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    chipLabel,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: chipColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),

            // Change details (not for kick_member)
            if (proposal.proposalType != 'kick_member' &&
                (proposal.oldValue != null ||
                    proposal.newValue != null)) ...[
              const SizedBox(height: 12),
              if (proposal.oldValue != null)
                _DetailRow(label: 'Previous', value: proposal.oldValue!),
              if (proposal.newValue != null)
                _DetailRow(label: 'Change to', value: proposal.newValue!),
            ],

            // Vote progress
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: progress,
                      backgroundColor:
                          theme.colorScheme.surfaceContainerHighest,
                      minHeight: 6,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  '${proposal.currentVotes}/${proposal.requiredVotes} votes',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),

            // Vote action buttons
            if (canVote) ...[
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton(
                    onPressed: () => _castVote(ref, context, 'reject'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: theme.colorScheme.error,
                    ),
                    child: const Text('Reject'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () => _castVote(ref, context, 'approve'),
                    child: const Text('Approve'),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _castVote(WidgetRef ref, BuildContext context, String vote) async {
    try {
      await ref.read(castVoteProvider.notifier).castVote(
            proposalId: proposal.id,
            vote: vote,
            tripId: tripId,
          );
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(vote == 'approve' ? 'Voted to approve' : 'Voted to reject')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Vote failed, you may have already voted')),
        );
      }
    }
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 40,
            child: Text(
              '$label:',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.outline,
              ),
            ),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              value,
              style: theme.textTheme.bodySmall,
            ),
          ),
        ],
      ),
    );
  }
}

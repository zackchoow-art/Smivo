import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'package:smivo/data/models/carpool_member.dart';
import 'package:smivo/core/providers/supabase_provider.dart';
import 'package:smivo/features/carpool/providers/carpool_detail_provider.dart';
import 'package:smivo/features/carpool/providers/carpool_lifecycle_provider.dart';
import 'package:smivo/features/carpool/widgets/review_batch_sheet.dart';

/// Guides the trip creator through arrival confirmation and peer review.
///
/// Shown after the creator taps "已到达" in the trip detail screen.
/// On confirmation it transitions status to 'arrived' then opens the
/// review sheet so members can be rated before the window closes.
class ArrivalConfirmationScreen extends ConsumerWidget {
  const ArrivalConfirmationScreen({super.key, required this.tripId});

  final String tripId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tripAsync = ref.watch(carpoolDetailProvider(tripId));

    return Scaffold(
      appBar: AppBar(title: const Text('到达确认')),
      body: tripAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('加载失败：$e')),
        data: (trip) {
          if (trip == null) {
            return const Center(child: Text('行程不存在'));
          }

          final dateFormat = DateFormat('MM/dd HH:mm');

          return Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ── Trip summary card ──────────────────────────────────────
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '行程摘要',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 12),
                        _InfoRow(
                          icon: Icons.location_on_outlined,
                          label: '出发地',
                          value: trip.departureAddress,
                        ),
                        const SizedBox(height: 8),
                        _InfoRow(
                          icon: Icons.flag_outlined,
                          label: '目的地',
                          value: trip.destinationAddress,
                        ),
                        const SizedBox(height: 8),
                        _InfoRow(
                          icon: Icons.schedule,
                          label: '出发时间',
                          value: dateFormat.format(trip.departureTime.toLocal()),
                        ),
                        if (trip.estimatedArrivalTime != null) ...[
                          const SizedBox(height: 8),
                          _InfoRow(
                            icon: Icons.access_time_filled,
                            label: '预计到达',
                            value: dateFormat
                                .format(trip.estimatedArrivalTime!.toLocal()),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                Text(
                  '您已到达目的地吗？',
                  style: Theme.of(context).textTheme.headlineSmall,
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 8),

                Text(
                  '确认到达后，您将可以对同行者进行评价',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                  textAlign: TextAlign.center,
                ),

                const Spacer(),

                // ── Action buttons ─────────────────────────────────────────
                ElevatedButton(
                  onPressed: () => _confirmArrival(context, ref, trip.members),
                  child: const Text('是的，已到达'),
                ),

                const SizedBox(height: 12),

                OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('还没有'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _confirmArrival(
    BuildContext context,
    WidgetRef ref,
    List<CarpoolMember> allMembers,
  ) async {
    // Mark the trip as arrived.
    await ref.read(tripLifecycleProvider(tripId).notifier).markArrived();

    if (!context.mounted) return;

    // Filter to only approved members, excluding self.
    final currentUserId =
        ref.read(supabaseClientProvider).auth.currentUser?.id;
    final reviewableMembers = allMembers
        .where(
          (m) => m.status == 'approved' && m.userId != currentUserId,
        )
        .toList();

    if (reviewableMembers.isEmpty) {
      Navigator.of(context).pop();
      return;
    }

    // Open the batch review sheet.
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ReviewBatchSheet(
        tripId: tripId,
        members: reviewableMembers,
      ),
    );

    if (context.mounted) Navigator.of(context).pop();
  }
}

/// A labeled icon + value row for the trip summary card.
class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: theme.colorScheme.primary),
        const SizedBox(width: 8),
        SizedBox(
          width: 60,
          child: Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        Expanded(
          child: Text(value, style: theme.textTheme.bodyMedium),
        ),
      ],
    );
  }
}

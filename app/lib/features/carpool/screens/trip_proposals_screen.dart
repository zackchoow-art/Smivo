import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'package:smivo/data/models/carpool_member.dart';
import 'package:smivo/data/models/carpool_trip.dart';
import 'package:smivo/features/carpool/providers/carpool_detail_provider.dart';
import 'package:smivo/features/carpool/providers/carpool_proposals_provider.dart';
import 'package:smivo/features/carpool/widgets/proposal_card.dart';
import 'package:smivo/core/providers/supabase_provider.dart';

/// Full-screen page listing all proposals for a trip with a FAB to create new ones.
class TripProposalsScreen extends ConsumerWidget {
  const TripProposalsScreen({super.key, required this.tripId});

  final String tripId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final currentUserId =
        ref.watch(supabaseClientProvider).auth.currentUser?.id ?? '';
    final proposalsAsync = ref.watch(tripProposalsProvider(tripId));
    final detailAsync = ref.watch(carpoolDetailProvider(tripId));

    return Scaffold(
      appBar: AppBar(title: const Text('提案与投票')),
      body: proposalsAsync.when(
        data: (proposals) {
          // Also need members for proposal cards
          final members = detailAsync.value?.members
                  .where((m) => m.status == 'approved')
                  .toList() ??
              [];

          if (proposals.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.how_to_vote_outlined,
                    size: 56,
                    color: theme.colorScheme.outline.withValues(alpha: 0.4),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '暂无提案',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.outline,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '点击右下角 + 发起新提案',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.outline.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: proposals.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (_, index) => ProposalCard(
              proposal: proposals[index],
              currentUserId: currentUserId,
              members: members,
              tripId: tripId,
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('加载失败: $error'),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () => ref.invalidate(tripProposalsProvider(tripId)),
                child: const Text('重试'),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCreateSheet(context, ref, detailAsync),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showCreateSheet(
    BuildContext context,
    WidgetRef ref,
    AsyncValue<CarpoolTrip?> detailAsync,
  ) {
    final trip = detailAsync.value;
    if (trip == null) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: _CreateProposalSheet(trip: trip, tripId: tripId),
      ),
    );
  }
}

/// Bottom sheet for creating a new proposal.
///
/// Dynamically switches form fields based on the selected proposal type:
/// - kick_member: shows member dropdown
/// - change_time: shows date/time pickers
/// - change_departure/destination: shows text fields
class _CreateProposalSheet extends ConsumerStatefulWidget {
  const _CreateProposalSheet({
    required this.trip,
    required this.tripId,
  });

  final CarpoolTrip trip;
  final String tripId;

  @override
  ConsumerState<_CreateProposalSheet> createState() =>
      _CreateProposalSheetState();
}

class _CreateProposalSheetState extends ConsumerState<_CreateProposalSheet> {
  String _type = 'change_time';
  String? _targetUserId;
  DateTime? _newTime;
  final _newValueController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _newValueController.dispose();
    super.dispose();
  }

  /// Members eligible for kick (exclude creator and self).
  List<CarpoolMember> get _kickableMembers {
    final currentUserId =
        ref.read(supabaseClientProvider).auth.currentUser?.id;
    return widget.trip.members
        .where((m) =>
            m.status == 'approved' &&
            m.userId != widget.trip.creatorId &&
            m.userId != currentUserId)
        .toList();
  }

  String _oldValueForType() {
    switch (_type) {
      case 'change_time':
        return DateFormat('yyyy-MM-dd HH:mm')
            .format(widget.trip.departureTime.toLocal());
      case 'change_departure':
        return widget.trip.departureAddress;
      case 'change_destination':
        return widget.trip.destinationAddress;
      default:
        return '';
    }
  }

  Future<void> _submit() async {
    setState(() => _isSubmitting = true);

    // NOTE: requiredVotes = approved members - 1 (exclude proposer)
    final approvedCount =
        widget.trip.members.where((m) => m.status == 'approved').length;
    final requiredVotes = approvedCount > 1 ? approvedCount - 1 : 1;

    String? newValue;
    if (_type == 'change_time' && _newTime != null) {
      newValue = _newTime!.toUtc().toIso8601String();
    } else if (_type != 'kick_member') {
      newValue = _newValueController.text.trim();
    }

    try {
      await ref
          .read(tripProposalsProvider(widget.tripId).notifier)
          .createProposal(
            proposalType: _type,
            requiredVotes: requiredVotes,
            oldValue: _type != 'kick_member' ? _oldValueForType() : null,
            newValue: newValue,
            targetUserId: _type == 'kick_member' ? _targetUserId : null,
            expiresAt: DateTime.now().add(const Duration(hours: 24)),
          );

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('提案已提交')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('提交失败: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Future<void> _pickNewTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 90)),
    );
    if (date == null || !mounted) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (time == null) return;

    setState(() {
      _newTime = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: theme.colorScheme.outline.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),

          Text('发起新提案', style: theme.textTheme.titleLarge),
          const SizedBox(height: 16),

          // Type selector
          DropdownButtonFormField<String>(
            initialValue: _type,
            decoration: const InputDecoration(
              labelText: '提案类型',
              border: OutlineInputBorder(),
            ),
            items: const [
              DropdownMenuItem(value: 'change_time', child: Text('修改出发时间')),
              DropdownMenuItem(
                  value: 'change_departure', child: Text('修改出发地点')),
              DropdownMenuItem(
                  value: 'change_destination', child: Text('修改目的地点')),
              DropdownMenuItem(value: 'kick_member', child: Text('踢出成员')),
            ],
            onChanged: (val) {
              if (val != null) setState(() => _type = val);
            },
          ),
          const SizedBox(height: 16),

          // Dynamic form based on type
          if (_type == 'kick_member') ...[
            DropdownButtonFormField<String>(
              initialValue: _targetUserId,
              decoration: const InputDecoration(
                labelText: '选择成员',
                border: OutlineInputBorder(),
              ),
              items: _kickableMembers
                  .map((m) => DropdownMenuItem(
                        value: m.userId,
                        child: Text(m.user?.displayName ?? '未知'),
                      ))
                  .toList(),
              onChanged: (val) => setState(() => _targetUserId = val),
            ),
          ] else if (_type == 'change_time') ...[
            Text(
              '当前: ${_oldValueForType()}',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.outline,
              ),
            ),
            const SizedBox(height: 8),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.access_time),
              title: Text(_newTime != null
                  ? DateFormat('yyyy-MM-dd HH:mm').format(_newTime!)
                  : '选择新时间'),
              trailing: const Icon(Icons.calendar_today, size: 20),
              onTap: _pickNewTime,
            ),
          ] else ...[
            Text(
              '当前: ${_oldValueForType()}',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.outline,
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _newValueController,
              decoration: const InputDecoration(
                labelText: '新地点',
                border: OutlineInputBorder(),
              ),
            ),
          ],

          const SizedBox(height: 24),

          // Submit button
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: _isSubmitting ? null : _submit,
              child: _isSubmitting
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('提交提案'),
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

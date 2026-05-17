import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'package:smivo/data/models/carpool_trip.dart';
import 'package:smivo/features/carpool/providers/carpool_lifecycle_provider.dart';
import 'package:smivo/core/maps/map_service.dart';
import 'package:smivo/shared/widgets/action_error_dialog.dart';
import 'package:smivo/shared/widgets/action_success_dialog.dart';

/// A vertical timeline showing the full lifecycle of a carpool trip.
///
/// Events are built dynamically from trip data:
///   - Trip created
///   - Each member's join event
///   - Cancellations with lead-time note
///   - Trip lifecycle transitions (departed → arrived → settled)
///
/// Follows the same three-column layout as OrderDetailScreen:
///   date (left) │ dot/line (center) │ event label (right)
class TripTimeline extends StatelessWidget {
  const TripTimeline({super.key, required this.trip});

  final CarpoolTrip trip;

  @override
  Widget build(BuildContext context) {
    final events = _buildEvents(context);
    if (events.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(0, 0, 0, 12),
          child: Text(
            'Trip Timeline',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
        ),
        for (int i = 0; i < events.length; i++)
          _TimelineRow(
            event: events[i],
            isLast: i == events.length - 1,
          ),
      ],
    );
  }

  List<_TimelineEvent> _buildEvents(BuildContext context) {
    final events = <_TimelineEvent>[];
    final dateFormat = DateFormat('MMM d, h:mm a');

    // 1. Trip created
    events.add(_TimelineEvent(
      label: 'Trip Created',
      subtitle: null,
      time: dateFormat.format(trip.createdAt.toLocal()),
      isCompleted: true,
      isHighlighted: false,
    ));

    // 2. Each approved member's join event (sorted by joinedAt)
    final joined = trip.members
        .where((m) => m.joinedAt != null && m.cancelledAt == null)
        .toList()
      ..sort((a, b) => a.joinedAt!.compareTo(b.joinedAt!));

    for (final member in joined) {
      final name = member.user?.displayName ?? 'Unknown';
      events.add(_TimelineEvent(
        label: '$name joined',
        subtitle: null,
        time: dateFormat.format(member.joinedAt!.toLocal()),
        isCompleted: true,
        isHighlighted: false,
      ));
    }

    // 3. Cancellation events (members who left before the trip)
    final cancelled = trip.members
        .where((m) => m.cancelledAt != null)
        .toList()
      ..sort((a, b) => a.cancelledAt!.compareTo(b.cancelledAt!));

    for (final member in cancelled) {
      final name = member.user?.displayName ?? 'Unknown';
      // Show how far in advance they cancelled as a risk signal
      final leadTime = member.cancelLeadTimeMinutes != null
          ? _formatLeadTime(member.cancelLeadTimeMinutes!)
          : null;
      events.add(_TimelineEvent(
        label: '$name left',
        subtitle: leadTime != null ? '$leadTime before departure' : null,
        time: dateFormat.format(member.cancelledAt!.toLocal()),
        isCompleted: true,
        isHighlighted: true, // Red to flag the cancellation
      ));
    }

    // 3.5. Trip Confirmed
    final hasConfirmed = ['confirmed', 'departed', 'arrived', 'completed']
        .contains(trip.status);
    if (hasConfirmed) {
      events.add(_TimelineEvent(
        label: 'Trip Confirmed',
        subtitle: 'Trip locked and members finalized',
        time: 'Confirmed',
        isCompleted: true,
        isHighlighted: false,
      ));
    }

    // 4. Departed event
    final hasDeparted = ['departed', 'arrived', 'completed']
        .contains(trip.status);
    events.add(_TimelineEvent(
      label: 'Departed',
      subtitle: null,
      // NOTE: We don't have a departed_at timestamp field currently,
      // so use departure_time as the planned time for display.
      time: hasDeparted
          ? dateFormat.format(trip.departureTime.toLocal())
          : 'Scheduled: ${dateFormat.format(trip.departureTime.toLocal())}',
      isCompleted: hasDeparted,
      isHighlighted: false,
    ));

    // 5. Arrived event
    final hasArrived = ['arrived', 'completed'].contains(trip.status);
    
    DateTime? calculatedArrival = trip.estimatedArrivalTime;
    if (calculatedArrival == null &&
        trip.departureLat != null && trip.departureLng != null &&
        trip.destinationLat != null && trip.destinationLng != null) {
      final route = estimateRoute(
        MapLocation(latitude: trip.departureLat!, longitude: trip.departureLng!),
        MapLocation(latitude: trip.destinationLat!, longitude: trip.destinationLng!),
      );
      calculatedArrival = trip.departureTime.add(Duration(minutes: route.durationMinutes));
    }

    events.add(_TimelineEvent(
      label: 'Arrived',
      subtitle: null,
      time: hasArrived
          ? (calculatedArrival != null
              ? dateFormat.format(calculatedArrival.toLocal())
              : 'Confirmed')
          : 'Pending',
      isCompleted: hasArrived,
      isHighlighted: false,
    ));

    // 6. Cost settled event (only if settlement data exists)
    if (trip.actualTotalCost != null && trip.settledAt != null) {
      final perPerson = _perPersonCost(trip);
      events.add(_TimelineEvent(
        label:
            'Cost settled: \$${trip.actualTotalCost!.toStringAsFixed(2)} total',
        subtitle: perPerson != null
            ? '\$$perPerson/person'
            : null,
        time: dateFormat.format(trip.settledAt!.toLocal()),
        isCompleted: true,
        isHighlighted: false,
      ));
    }

    return events;
  }

  /// Converts minutes to a human-readable lead-time string (e.g. "2h 30m").
  String _formatLeadTime(int minutes) {
    if (minutes >= 60) {
      final hours = minutes ~/ 60;
      final mins = minutes % 60;
      return mins > 0 ? '${hours}h ${mins}m' : '${hours}h';
    }
    return '${minutes}m';
  }

  /// Calculates per-person cost from actual total and approved member count.
  /// Returns null if the member count cannot be determined.
  String? _perPersonCost(CarpoolTrip trip) {
    final activeCount = trip.members
        .where((m) =>
            m.cancelledAt == null &&
            (m.status == 'approved' || m.role == 'creator'))
        .length;
    if (activeCount <= 0 || trip.actualTotalCost == null) return null;
    final perPerson = trip.actualTotalCost! / activeCount;
    return perPerson.toStringAsFixed(2);
  }
}

/// A single row in the trip timeline.
class _TimelineRow extends StatelessWidget {
  const _TimelineRow({required this.event, required this.isLast});

  final _TimelineEvent event;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dotColor = event.isHighlighted
        ? theme.colorScheme.error
        : event.isCompleted
            ? theme.colorScheme.primary
            : theme.colorScheme.outline.withValues(alpha: 0.4);

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left column: date/time
          SizedBox(
            width: 110,
            child: Padding(
              padding: const EdgeInsets.only(top: 2, right: 8),
              child: Text(
                event.time,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: event.isHighlighted
                      ? theme.colorScheme.error
                      : theme.colorScheme.onSurfaceVariant,
                  fontSize: 10,
                ),
                textAlign: TextAlign.right,
              ),
            ),
          ),

          // Center column: dot + connecting line
          Column(
            children: [
              Container(
                width: 10,
                height: 10,
                margin: const EdgeInsets.only(top: 3),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: dotColor,
                ),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    color: theme.colorScheme.outline.withValues(alpha: 0.2),
                  ),
                ),
            ],
          ),

          // Right column: event label + subtitle
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: 10, bottom: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event.label,
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: event.isHighlighted
                          ? theme.colorScheme.error
                          : theme.colorScheme.onSurface,
                    ),
                  ),
                  if (event.subtitle != null)
                    Text(
                      event.subtitle!,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Immutable data holder for a single timeline step.
class _TimelineEvent {
  const _TimelineEvent({
    required this.label,
    required this.subtitle,
    required this.time,
    required this.isCompleted,
    required this.isHighlighted,
  });

  final String label;
  final String? subtitle;
  final String time;
  // Controls dot fill vs. hollow rendering.
  final bool isCompleted;
  // When true (e.g. cancellations), renders in error/red color.
  final bool isHighlighted;
}

// ── Cost Settlement Card ──────────────────────────────────────────────────────

/// Shows the cost settlement UI after trip arrival.
///
/// Creator sees an editable amount field and submit button.
/// Regular members see the settled total and their calculated share (read-only).
class CostSettlementCard extends ConsumerStatefulWidget {
  const CostSettlementCard({
    super.key,
    required this.trip,
    required this.isCreator,
    required this.activeMemberCount,
  });

  final CarpoolTrip trip;
  final bool isCreator;
  // Number of active (non-cancelled) members including the creator.
  final int activeMemberCount;

  @override
  ConsumerState<CostSettlementCard> createState() => _CostSettlementCardState();
}

class _CostSettlementCardState extends ConsumerState<CostSettlementCard> {
  final _formKey = GlobalKey<FormState>();
  final _costController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _costController.dispose();
    super.dispose();
  }

  Future<void> _submitSettlement() async {
    if (!_formKey.currentState!.validate()) return;
    final cost = double.tryParse(_costController.text.trim());
    if (cost == null) return;

    setState(() => _isSubmitting = true);
    try {
      await ref
          .read(tripLifecycleProvider(widget.trip.id).notifier)
          .settleTripCost(widget.trip.id, cost);
      if (mounted) {
        showDialog(
          context: context,
          builder: (ctx) => const ActionSuccessDialog(
            title: 'Settled',
            message: 'Trip cost has been settled successfully.',
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        showDialog(
          context: context,
          builder: (ctx) => ActionErrorDialog(
            title: 'Settlement Failed',
            message: e.toString(),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isSettled = widget.trip.settledAt != null;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Cost Settlement',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 12),

            if (widget.isCreator && !isSettled) ...[
              // Creator input form
              Form(
                key: _formKey,
                child: TextFormField(
                  controller: _costController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: const InputDecoration(
                    labelText: 'Actual Total Cost (\$)',
                    prefixText: '\$ ',
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Required';
                    if (double.tryParse(v.trim()) == null) {
                      return 'Enter a valid amount';
                    }
                    return null;
                  },
                  // NOTE: Show live per-person split as user types
                  onChanged: (_) => setState(() {}),
                ),
              ),

              if (_costController.text.isNotEmpty &&
                  double.tryParse(_costController.text.trim()) != null) ...[
                const SizedBox(height: 8),
                Text(
                  'Per person: \$${(double.parse(_costController.text.trim()) / widget.activeMemberCount.clamp(1, 99)).toStringAsFixed(2)} '
                  '(${widget.activeMemberCount} people)',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],

              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submitSettlement,
                  child: _isSubmitting
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Confirm Settlement'),
                ),
              ),
            ] else if (isSettled) ...[
              // Settled state — show amounts for everyone
              _SettledRow(
                label: 'Total',
                value:
                    '\$${widget.trip.actualTotalCost!.toStringAsFixed(2)}',
              ),
              const SizedBox(height: 4),
              _SettledRow(
                label: 'Your share',
                value:
                    '\$${(widget.trip.actualTotalCost! / widget.activeMemberCount.clamp(1, 99)).toStringAsFixed(2)}',
              ),
            ] else ...[
              // Not settled yet — waiting on creator
              Row(
                children: [
                  Icon(
                    Icons.hourglass_empty,
                    size: 16,
                    color: theme.colorScheme.outline,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Waiting for organizer to enter the total cost...',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// A single labeled value row in the settled state display.
class _SettledRow extends StatelessWidget {
  const _SettledRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: theme.textTheme.bodyMedium),
        Text(
          value,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: theme.colorScheme.primary,
          ),
        ),
      ],
    );
  }
}

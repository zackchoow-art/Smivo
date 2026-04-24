import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:smivo/core/theme/theme_extensions.dart';

class TimelineStep {
  const TimelineStep({
    required this.label,
    required this.isCompleted,
    this.date,
  });
  final String label;
  final DateTime? date;
  final bool isCompleted;
}

class OrderTimeline extends StatelessWidget {
  const OrderTimeline({super.key, required this.steps});
  final List<TimelineStep> steps;

  @override
  Widget build(BuildContext context) {
    final colors = context.smivoColors;
    final typo = context.smivoTypo;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'ORDER TIMELINE',
          style: typo.labelSmall.copyWith(
            color: colors.onSurface.withValues(alpha: 0.5),
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 12),
        ...steps.asMap().entries.map((entry) => _buildTimelineRow(
              context,
              entry.value,
              entry.key == steps.length - 1,
            )),
      ],
    );
  }

  Widget _buildTimelineRow(BuildContext context, TimelineStep step, bool isLast) {
    final colors = context.smivoColors;
    final typo = context.smivoTypo;
    final dateStr = step.date != null
        ? DateFormat('MMM d, yyyy · h:mm a').format(step.date!.toLocal())
        : '—';

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 32,
            child: Column(
              children: [
                Container(
                  width: 14,
                  height: 14,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: step.isCompleted
                        ? colors.primary
                        : colors.surfaceContainerHigh,
                    border: Border.all(
                      color: step.isCompleted
                          ? colors.primary
                          : colors.outlineVariant,
                      width: 2,
                    ),
                  ),
                  child: step.isCompleted
                      ? const Icon(Icons.check, size: 8, color: Colors.white)
                      : null,
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      color: step.isCompleted
                          ? colors.primary
                          : colors.surfaceContainerHigh,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    step.label,
                    style: typo.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                      color: step.isCompleted
                          ? colors.onSurface
                          : colors.outlineVariant,
                    ),
                  ),
                  if (step.date != null)
                    Text(
                      dateStr,
                      style: typo.bodySmall.copyWith(color: colors.outlineVariant),
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

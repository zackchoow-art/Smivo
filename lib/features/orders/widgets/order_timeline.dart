import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:smivo/core/theme/theme_extensions.dart';

/// Data model for a single step in the order timeline.
/// [subtitle] shows additional context (buyer name, pickup location, etc.)
/// [isCancelled] renders the step in red (cancelled / missed states).
class TimelineStep {
  const TimelineStep({
    required this.label,
    required this.isCompleted,
    this.date,
    this.subtitle,
    this.isCancelled,
  });
  final String label;
  final DateTime? date;
  final bool isCompleted;
  final String? subtitle;
  final bool? isCancelled;
}

class OrderTimeline extends StatelessWidget {
  const OrderTimeline({super.key, required this.steps});
  final List<TimelineStep> steps;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ...steps.asMap().entries.map(
              (entry) => _buildTimelineRow(
                context,
                entry.value,
                entry.key == steps.length - 1,
              ),
            ),
      ],
    );
  }

  Widget _buildTimelineRow(
    BuildContext context,
    TimelineStep step,
    bool isLast,
  ) {
    final colors = context.smivoColors;
    final typo = context.smivoTypo;

    final isCancelled = step.isCancelled ?? false;

    // NOTE: Determine dot and line color based on completion / cancellation state
    final Color dotColor = isCancelled
        ? colors.error
        : step.isCompleted
            ? colors.primary
            : colors.surfaceContainerHigh;

    final Color dotBorderColor = isCancelled
        ? colors.error
        : step.isCompleted
            ? colors.primary
            : colors.outlineVariant;

    final Color lineColor = step.isCompleted
        ? colors.primary.withValues(alpha: 0.4)
        : colors.surfaceContainerHigh;

    final Color labelColor = isCancelled
        ? colors.error
        : step.isCompleted
            ? colors.onSurface
            : colors.outlineVariant;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left column: date + time (fixed 88px width)
          SizedBox(
            width: 88,
            child: Padding(
              padding: const EdgeInsets.only(top: 1),
              child: step.date != null
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          DateFormat('MMM d').format(step.date!.toLocal()),
                          style: typo.bodySmall.copyWith(
                            color: colors.onSurface.withValues(alpha: 0.7),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          DateFormat('h:mm a').format(step.date!.toLocal()),
                          style: typo.labelSmall.copyWith(
                            color: colors.outlineVariant,
                          ),
                        ),
                      ],
                    )
                  : Text(
                      '—',
                      style: typo.bodySmall.copyWith(
                        color: colors.outlineVariant,
                      ),
                    ),
            ),
          ),

          // Centre column: dot + vertical line
          SizedBox(
            width: 24,
            child: Column(
              children: [
                Container(
                  width: 14,
                  height: 14,
                  margin: const EdgeInsets.only(top: 2),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: dotColor,
                    border: Border.all(color: dotBorderColor, width: 2),
                  ),
                  // NOTE: Cancelled dot shows X icon; completed shows check
                  child: isCancelled
                      ? const Icon(Icons.close, size: 8, color: Colors.white)
                      : step.isCompleted
                          ? const Icon(
                              Icons.check,
                              size: 8,
                              color: Colors.white,
                            )
                          : null,
                ),
                if (!isLast)
                  Expanded(
                    child: Center(
                      child: Container(
                        width: 2,
                        color: lineColor,
                      ),
                    ),
                  ),
              ],
            ),
          ),

          const SizedBox(width: 10),

          // Right column: label + subtitle
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
                      color: labelColor,
                    ),
                  ),
                  if (step.subtitle != null)
                    Text(
                      step.subtitle!,
                      style: typo.bodySmall.copyWith(
                        color: colors.outlineVariant,
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

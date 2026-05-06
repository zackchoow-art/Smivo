import 'package:flutter/material.dart';
import 'package:smivo/core/theme/theme_extensions.dart';
import 'package:timeago/timeago.dart' as timeago;

/// Displays "X minutes ago" badge for a user's last active time.
///
/// Shows:
/// - "Online" (green dot) if within 10 minutes
/// - "5m ago", "2h ago", "3d ago" using timeago package
/// - Nothing if lastActiveAt is null (user never sent heartbeat)
class LastActiveBadge extends StatelessWidget {
  final DateTime? lastActiveAt;

  const LastActiveBadge({super.key, this.lastActiveAt});

  @override
  Widget build(BuildContext context) {
    if (lastActiveAt == null) return const SizedBox.shrink();

    final now = DateTime.now().toUtc();
    final diff = now.difference(lastActiveAt!);

    final isOnline = diff.inMinutes <= 10;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isOnline ? Colors.green : Colors.grey,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          isOnline ? 'Online' : timeago.format(lastActiveAt!),
          style: context.smivoTypo.labelSmall.copyWith(
            color:
                isOnline ? Colors.green : context.smivoColors.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

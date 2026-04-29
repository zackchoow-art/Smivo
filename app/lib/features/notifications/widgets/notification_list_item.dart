import 'package:flutter/material.dart';
import 'package:smivo/core/theme/theme_extensions.dart';
import 'package:smivo/data/models/notification.dart';

/// A single notification row in the notification center list.
class NotificationListItem extends StatelessWidget {
  const NotificationListItem({
    super.key,
    required this.notification,
    required this.onTap,
  });
  final AppNotification notification;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isUnread = !notification.isRead;
    final hasAction = notification.actionType != 'none';
    final colors = context.smivoColors;
    final typo = context.smivoTypo;
    final radius = context.smivoRadius;

    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color:
              isUnread
                  ? colors.primary.withValues(alpha: 0.04)
                  : Colors.transparent,
          border: Border(
            bottom: BorderSide(
              color: colors.outlineVariant.withValues(alpha: 0.2),
            ),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 6, right: 12),
              child: Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isUnread ? colors.primary : Colors.transparent,
                ),
              ),
            ),
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: _iconBgColor(colors).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(radius.md),
              ),
              child: Icon(_iconData, color: _iconBgColor(colors), size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    notification.title,
                    style: typo.bodyMedium.copyWith(
                      fontWeight: isUnread ? FontWeight.w600 : FontWeight.w400,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    notification.body,
                    style: typo.bodySmall.copyWith(
                      color: colors.onSurface.withValues(alpha: 0.6),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatTimeAgo(notification.createdAt),
                    style: typo.bodySmall.copyWith(
                      color: colors.outlineVariant,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            if (hasAction)
              Padding(
                padding: const EdgeInsets.only(top: 8, left: 4),
                child: Icon(
                  Icons.chevron_right,
                  color: colors.outlineVariant,
                  size: 20,
                ),
              ),
          ],
        ),
      ),
    );
  }

  IconData get _iconData => switch (notification.type) {
    'order_placed' => Icons.shopping_bag_outlined,
    'order_accepted' => Icons.check_circle_outline,
    'order_cancelled' => Icons.cancel_outlined,
    'order_delivered' => Icons.local_shipping_outlined,
    'order_completed' => Icons.celebration_outlined,
    'system' => Icons.campaign_outlined,
    _ => Icons.notifications_outlined,
  };

  Color _iconBgColor(SmivoColors colors) => switch (notification.type) {
    'order_placed' => colors.primary,
    'order_accepted' => colors.success,
    'order_cancelled' => colors.error,
    'order_delivered' => colors.warning,
    'order_completed' => colors.statusPending,
    'system' => colors.outlineVariant,
    _ => colors.outlineVariant,
  };

  String _formatTimeAgo(DateTime dateTime) {
    final diff = DateTime.now().difference(dateTime.toLocal());
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[dateTime.month - 1]} ${dateTime.day}';
  }
}

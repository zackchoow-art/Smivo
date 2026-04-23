import 'package:flutter/material.dart';
import 'package:smivo/core/theme/app_spacing.dart';
import 'package:smivo/core/theme/app_text_styles.dart';
import 'package:smivo/core/theme/app_colors.dart';
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

    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        decoration: BoxDecoration(
          color: isUnread
              ? AppColors.primary.withValues(alpha: 0.04)
              : Colors.transparent,
          border: Border(
            bottom: BorderSide(
              color: AppColors.outlineVariant.withValues(alpha: 0.2),
            ),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Unread indicator
            Padding(
              padding: const EdgeInsets.only(top: 6, right: 12),
              child: Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isUnread
                      ? AppColors.primary
                      : Colors.transparent,
                ),
              ),
            ),

            // Type icon
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: _iconBackgroundColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              ),
              child: Icon(
                _iconData,
                color: _iconBackgroundColor,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),

            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    notification.title,
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: isUnread ? FontWeight.w600 : FontWeight.w400,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    notification.body,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.onSurface.withValues(alpha: 0.6),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatTimeAgo(notification.createdAt),
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.outlineVariant,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),

            // Arrow for actionable notifications
            if (hasAction)
              Padding(
                padding: const EdgeInsets.only(top: 8, left: 4),
                child: Icon(
                  Icons.chevron_right,
                  color: AppColors.outlineVariant,
                  size: 20,
                ),
              ),
          ],
        ),
      ),
    );
  }

  IconData get _iconData {
    switch (notification.type) {
      case 'order_placed':
        return Icons.shopping_bag_outlined;
      case 'order_accepted':
        return Icons.check_circle_outline;
      case 'order_cancelled':
        return Icons.cancel_outlined;
      case 'order_delivered':
        return Icons.local_shipping_outlined;
      case 'order_completed':
        return Icons.celebration_outlined;
      case 'system':
        return Icons.campaign_outlined;
      default:
        return Icons.notifications_outlined;
    }
  }

  Color get _iconBackgroundColor {
    switch (notification.type) {
      case 'order_placed':
        return AppColors.primary;
      case 'order_accepted':
        return const Color(0xFF2E7D32); // green
      case 'order_cancelled':
        return const Color(0xFFC62828); // red
      case 'order_delivered':
        return const Color(0xFFE65100); // orange
      case 'order_completed':
        return const Color(0xFFF9A825); // gold
      case 'system':
        return AppColors.outlineVariant;
      default:
        return AppColors.outlineVariant;
    }
  }

  String _formatTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final diff = now.difference(dateTime.toLocal());

    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    // Longer than a week: show date
    final months = [
      'Jan','Feb','Mar','Apr','May','Jun',
      'Jul','Aug','Sep','Oct','Nov','Dec',
    ];
    return '${months[dateTime.month - 1]} ${dateTime.day}';
  }
}

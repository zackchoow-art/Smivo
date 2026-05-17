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

    final iconSpec = _iconSpec(notification.type);

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
            // ── Unread dot ──────────────────────────────────────────
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

            // ── Colored icon badge ─────────────────────────────────
            // NOTE: Each notification type gets a unique tinted rounded-square
            // with a colored icon inside — matching the screenshot style where
            // the badge color communicates the notification category at a glance.
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: iconSpec.bgColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                iconSpec.icon,
                color: iconSpec.iconColor,
                size: 22,
              ),
            ),

            const SizedBox(width: 12),

            // ── Text content ───────────────────────────────────────
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    notification.title,
                    style: typo.bodyMedium.copyWith(
                      fontWeight:
                          isUnread ? FontWeight.w600 : FontWeight.w400,
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

            // ── Chevron ────────────────────────────────────────────
            if (hasAction)
              Padding(
                padding: const EdgeInsets.only(top: 10, left: 4),
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

  // ── Icon spec lookup ──────────────────────────────────────────────

  /// Returns a [_IconSpec] (icon + background color + icon color) for [type].
  ///
  /// NOTE: Colors are intentionally NOT pulled from SmivoColors here because
  /// these are semantic, fixed-meaning colors (e.g. green always means
  /// "accepted", red always means "cancelled") and must stay consistent
  /// regardless of which SmivoTheme variant is active.
  static _IconSpec _iconSpec(String type) => switch (type) {
    'order_placed' => _IconSpec(
      icon: Icons.shopping_bag_rounded,
      bgColor: const Color(0xFFE8EAF6), // indigo-50
      iconColor: const Color(0xFF3F51B5), // indigo-600
    ),
    'order_accepted' => _IconSpec(
      icon: Icons.check_circle_rounded,
      bgColor: const Color(0xFFE8F5E9), // green-50
      iconColor: const Color(0xFF388E3C), // green-700
    ),
    'order_cancelled' => _IconSpec(
      icon: Icons.cancel_rounded,
      bgColor: const Color(0xFFFFEBEE), // red-50
      iconColor: const Color(0xFFD32F2F), // red-700
    ),
    'order_delivered' => _IconSpec(
      icon: Icons.local_shipping_rounded,
      bgColor: const Color(0xFFFFF3E0), // orange-50
      iconColor: const Color(0xFFE65100), // orange-900
    ),
    'order_completed' => _IconSpec(
      icon: Icons.celebration_rounded,
      bgColor: const Color(0xFFFFFDE7), // yellow-50
      iconColor: const Color(0xFFF9A825), // yellow-800
    ),
    'rental_extension' => _IconSpec(
      icon: Icons.edit_calendar_rounded,
      bgColor: const Color(0xFFF3E5F5), // purple-50
      iconColor: const Color(0xFF7B1FA2), // purple-700
    ),
    'rental_reminder' => _IconSpec(
      icon: Icons.alarm_rounded,
      bgColor: const Color(0xFFE3F2FD), // blue-50
      iconColor: const Color(0xFF1565C0), // blue-800
    ),
    'system' => _IconSpec(
      icon: Icons.campaign_rounded,
      bgColor: const Color(0xFFF5F5F5), // grey-100
      iconColor: const Color(0xFF616161), // grey-700
    ),
    'report_resolved' => _IconSpec(
      icon: Icons.verified_user_rounded,
      bgColor: const Color(0xFFE8F5E9),
      iconColor: const Color(0xFF2E7D32),
    ),
    'report_dismissed' => _IconSpec(
      icon: Icons.info_rounded,
      bgColor: const Color(0xFFF5F5F5),
      iconColor: const Color(0xFF757575),
    ),
    'moderation_warned' => _IconSpec(
      icon: Icons.warning_rounded,
      bgColor: const Color(0xFFFFF8E1), // amber-50
      iconColor: const Color(0xFFFF8F00), // amber-800
    ),
    'moderation_restricted' => _IconSpec(
      icon: Icons.block_rounded,
      bgColor: const Color(0xFFFFEBEE),
      iconColor: const Color(0xFFC62828),
    ),
    'feedback_responded' => _IconSpec(
      icon: Icons.mark_email_read_rounded,
      bgColor: const Color(0xFFE8EAF6),
      iconColor: const Color(0xFF283593),
    ),
    // Carpool-related notification types.
    'carpool_request' => _IconSpec(
      icon: Icons.directions_car_rounded,
      bgColor: const Color(0xFFE0F2F1), // teal-50
      iconColor: const Color(0xFF00695C), // teal-800
    ),
    'carpool_accepted' => _IconSpec(
      icon: Icons.check_circle_rounded,
      bgColor: const Color(0xFFE8F5E9),
      iconColor: const Color(0xFF388E3C),
    ),
    'carpool_rejected' => _IconSpec(
      icon: Icons.directions_car_rounded,
      bgColor: const Color(0xFFFFEBEE),
      iconColor: const Color(0xFFD32F2F),
    ),
    _ => _IconSpec(
      icon: Icons.notifications_rounded,
      bgColor: const Color(0xFFF5F5F5),
      iconColor: const Color(0xFF757575),
    ),
  };

  // ── Time formatter ────────────────────────────────────────────────

  String _formatTimeAgo(DateTime dateTime) {
    final diff = DateTime.now().difference(dateTime.toLocal());
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${months[dateTime.month - 1]} ${dateTime.day}';
  }
}

// ── Data class ───────────────────────────────────────────────────────

/// Holds the visual spec for a notification type's icon badge.
class _IconSpec {
  const _IconSpec({
    required this.icon,
    required this.bgColor,
    required this.iconColor,
  });

  final IconData icon;
  final Color bgColor;
  final Color iconColor;
}

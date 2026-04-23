import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:smivo/core/router/app_routes.dart';
import 'package:smivo/core/theme/app_colors.dart';
import 'package:smivo/core/theme/app_spacing.dart';
import 'package:smivo/core/theme/app_text_styles.dart';
import 'package:smivo/data/models/notification.dart';
import 'package:smivo/features/notifications/providers/notification_provider.dart';
import 'package:smivo/features/notifications/widgets/notification_list_item.dart';
import 'package:url_launcher/url_launcher.dart';

class NotificationCenterScreen extends ConsumerWidget {
  const NotificationCenterScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notificationsAsync = ref.watch(notificationListProvider);
    final unreadCount = ref.watch(totalUnreadNotificationsProvider)
        .valueOrNull ?? 0;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Notifications',
          style: AppTextStyles.headlineSmall,
        ),
        actions: [
          if (unreadCount > 0)
            TextButton(
              onPressed: () {
                ref.read(notificationListProvider.notifier).markAllAsRead();
              },
              child: Text(
                'Mark All Read',
                style: AppTextStyles.labelSmall.copyWith(
                  color: AppColors.primary,
                ),
              ),
            ),
        ],
      ),
      body: notificationsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Text(
            'Error loading notifications',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.error,
            ),
          ),
        ),
        data: (notifications) {
          if (notifications.isEmpty) {
            return _buildEmptyState();
          }

          return ListView.builder(
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              final notification = notifications[index];
              return NotificationListItem(
                notification: notification,
                onTap: () => _handleTap(context, ref, notification),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_none_outlined,
            size: 64,
            color: AppColors.outlineVariant.withValues(alpha: 0.5),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'No notifications yet',
            style: AppTextStyles.bodyLarge.copyWith(
              color: AppColors.outlineVariant,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            "We'll notify you when something happens.",
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.outlineVariant,
            ),
          ),
        ],
      ),
    );
  }

  void _handleTap(
    BuildContext context,
    WidgetRef ref,
    AppNotification notification,
  ) {
    // Mark as read on tap
    if (!notification.isRead) {
      ref.read(notificationListProvider.notifier)
          .markAsRead(notification.id);
    }

    switch (notification.actionType) {
      case 'order':
        if (notification.relatedOrderId != null) {
          context.pushNamed(
            AppRoutes.orderDetail,
            pathParameters: {'id': notification.relatedOrderId!},
          );
        }
        break;
      case 'url':
        if (notification.actionUrl != null) {
          launchUrl(Uri.parse(notification.actionUrl!));
        }
        break;
      case 'route':
        if (notification.actionUrl != null) {
          context.push(notification.actionUrl!);
        }
        break;
      case 'none':
      default:
        // Just mark as read, no navigation
        break;
    }
  }
}

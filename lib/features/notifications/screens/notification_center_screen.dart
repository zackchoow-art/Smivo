import 'package:flutter/material.dart';
import 'package:smivo/core/theme/theme_extensions.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:smivo/core/router/app_routes.dart';
import 'package:smivo/data/models/notification.dart';
import 'package:smivo/features/notifications/providers/notification_provider.dart';
import 'package:smivo/features/notifications/widgets/notification_list_item.dart';
import 'package:url_launcher/url_launcher.dart';

class NotificationCenterScreen extends ConsumerWidget {
  const NotificationCenterScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notificationsAsync = ref.watch(notificationListProvider);
    final unreadCount = ref.watch(totalUnreadNotificationsProvider).valueOrNull ?? 0;
    final colors = context.smivoColors;
    final typo = context.smivoTypo;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.background,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.goNamed(AppRoutes.home);
            }
          },
        ),
        title: Text('Notifications', style: typo.headlineSmall),
        actions: [
          if (unreadCount > 0)
            TextButton(
              onPressed: () => ref.read(notificationListProvider.notifier).markAllAsRead(),
              child: Text('Mark All Read', style: typo.labelSmall.copyWith(color: colors.primary)),
            ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(notificationListProvider);
          await ref.read(notificationListProvider.future);
        },
        child: notificationsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Center(
              child: Padding(
                padding: const EdgeInsets.only(top: 100),
                child: Text('Error loading notifications', style: typo.bodyMedium.copyWith(color: colors.error)),
              ),
            ),
          ),
          data: (notifications) {
            if (notifications.isEmpty) return _buildEmptyState(context);
            return ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: notifications.length,
              itemBuilder: (context, index) {
                final notification = notifications[index];
                return NotificationListItem(notification: notification, onTap: () => _handleTap(context, ref, notification));
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final colors = context.smivoColors;
    final typo = context.smivoTypo;
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.only(top: 100),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.notifications_none_outlined, size: 64, color: colors.outlineVariant.withValues(alpha: 0.5)),
              const SizedBox(height: 12),
              Text('No notifications yet', style: typo.bodyLarge.copyWith(color: colors.outlineVariant)),
              const SizedBox(height: 4),
              Text("We'll notify you when something happens.", style: typo.bodySmall.copyWith(color: colors.outlineVariant)),
            ],
          ),
        ),
      ),
    );
  }

  void _handleTap(BuildContext context, WidgetRef ref, AppNotification notification) {
    if (!notification.isRead) {
      ref.read(notificationListProvider.notifier).markAsRead(notification.id);
    }
    switch (notification.actionType) {
      case 'order':
        if (notification.relatedOrderId != null) {
          context.pushNamed(AppRoutes.orderDetail, pathParameters: {'id': notification.relatedOrderId!});
        }
      case 'url':
        if (notification.actionUrl != null) launchUrl(Uri.parse(notification.actionUrl!));
      case 'route':
        if (notification.actionUrl != null) context.push(notification.actionUrl!);
      case 'none':
      default:
        break;
    }
  }
}

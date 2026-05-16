import 'package:flutter/material.dart';
import 'package:smivo/core/theme/theme_extensions.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:smivo/core/router/app_routes.dart';
import 'package:smivo/data/models/notification.dart';
import 'package:smivo/features/notifications/providers/notification_provider.dart';
import 'package:smivo/features/notifications/widgets/notification_list_item.dart';
import 'package:smivo/shared/widgets/content_width_constraint.dart';
import 'package:smivo/shared/widgets/unified_page_header.dart';
import 'package:smivo/core/theme/breakpoints.dart';
import 'package:url_launcher/url_launcher.dart';

class NotificationCenterScreen extends ConsumerStatefulWidget {
  const NotificationCenterScreen({super.key, this.showBackButton = true});

  final bool showBackButton;

  @override
  ConsumerState<NotificationCenterScreen> createState() =>
      _NotificationCenterScreenState();
}

class _NotificationCenterScreenState
    extends ConsumerState<NotificationCenterScreen> {
  bool _unreadExpanded = true;
  bool _todayExpanded = true;
  bool _yesterdayExpanded = true;
  bool _thisWeekExpanded = true;
  bool _olderExpanded = true;

  @override
  Widget build(BuildContext context) {
    final notificationsAsync = ref.watch(notificationListProvider);
    final colors = context.smivoColors;
    final typo = context.smivoTypo;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: Breakpoints.isMobile(MediaQuery.of(context).size.width)
          ? AppBar(
              backgroundColor: colors.surfaceContainerLowest,
              surfaceTintColor: Colors.transparent,
              elevation: 0,
              leading:
                  widget.showBackButton
                      ? IconButton(
                        icon: Icon(
                          Icons.arrow_back_ios_new,
                          size: 20,
                          color: colors.onSurface,
                        ),
                        onPressed: () {
                          if (context.canPop()) {
                            context.pop();
                          } else {
                            context.goNamed(AppRoutes.home);
                          }
                        },
                      )
                      : null,
              title: Text(
                'Notifications',
                style: typo.headlineSmall.copyWith(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () async {
                    await ref.read(notificationListProvider.notifier).markAllAsRead();
                  },
                  child: Text(
                    'Mark Read',
                    style: typo.labelLarge.copyWith(color: colors.primary),
                  ),
                ),
              ],
            )
          : null,
      body: SelectionArea(
        child: Center(
          child: ContentWidthConstraint(
            maxWidth: 768,
            child: RefreshIndicator(
              onRefresh: () async {
                ref.invalidate(notificationListProvider);
                await ref.read(notificationListProvider.future);
              },
              child: notificationsAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error:
                    (e, _) => SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 100),
                          child: Text(
                            'Error loading notifications',
                            style: typo.bodyMedium.copyWith(
                              color: colors.error,
                            ),
                          ),
                        ),
                      ),
                    ),
                data: (notifications) {
                  if (notifications.isEmpty) return _buildEmptyState(context);

                  final unread = <AppNotification>[];
                  final today = <AppNotification>[];
                  final yesterday = <AppNotification>[];
                  final thisWeek = <AppNotification>[];
                  final older = <AppNotification>[];

                  final now = DateTime.now();
                  final todayStart = DateTime(now.year, now.month, now.day);
                  final yesterdayStart = todayStart.subtract(
                    const Duration(days: 1),
                  );
                  final weekStart = todayStart.subtract(
                    const Duration(days: 7),
                  );

                  for (final n in notifications) {
                    if (!n.isRead) {
                      unread.add(n);
                    } else {
                      final date = n.createdAt.toLocal();
                      if (date.isAfter(todayStart) ||
                          date.isAtSameMomentAs(todayStart)) {
                        today.add(n);
                      } else if (date.isAfter(yesterdayStart) ||
                          date.isAtSameMomentAs(yesterdayStart)) {
                        yesterday.add(n);
                      } else if (date.isAfter(weekStart) ||
                          date.isAtSameMomentAs(weekStart)) {
                        thisWeek.add(n);
                      } else {
                        older.add(n);
                      }
                    }
                  }

                  return ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: [
                      if (!Breakpoints.isMobile(MediaQuery.of(context).size.width))
                        Padding(
                          padding: const EdgeInsets.only(right: 24),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              const UnifiedPageHeader(title: 'Notifications'),
                              Padding(
                                padding: const EdgeInsets.only(bottom: 32),
                                child: TextButton(
                                  onPressed: () async {
                                    await ref.read(notificationListProvider.notifier).markAllAsRead();
                                  },
                                  child: Text(
                                    'Mark Read',
                                    style: typo.labelLarge.copyWith(color: colors.primary),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      if (unread.isNotEmpty)
                        _buildSection(
                          title: 'Unread',
                          items: unread,
                          isExpanded: _unreadExpanded,
                          onToggle:
                              () => setState(
                                () => _unreadExpanded = !_unreadExpanded,
                              ),
                        ),
                      if (today.isNotEmpty)
                        _buildSection(
                          title: 'Today',
                          items: today,
                          isExpanded: _todayExpanded,
                          onToggle:
                              () => setState(
                                () => _todayExpanded = !_todayExpanded,
                              ),
                        ),
                      if (yesterday.isNotEmpty)
                        _buildSection(
                          title: 'Yesterday',
                          items: yesterday,
                          isExpanded: _yesterdayExpanded,
                          onToggle:
                              () => setState(
                                () => _yesterdayExpanded = !_yesterdayExpanded,
                              ),
                        ),
                      if (thisWeek.isNotEmpty)
                        _buildSection(
                          title: 'This Week',
                          items: thisWeek,
                          isExpanded: _thisWeekExpanded,
                          onToggle:
                              () => setState(
                                () => _thisWeekExpanded = !_thisWeekExpanded,
                              ),
                        ),
                      if (older.isNotEmpty)
                        _buildSection(
                          title: 'Older',
                          items: older,
                          isExpanded: _olderExpanded,
                          onToggle:
                              () => setState(
                                () => _olderExpanded = !_olderExpanded,
                              ),
                        ),
                      const SizedBox(height: 24),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required List<AppNotification> items,
    required bool isExpanded,
    required VoidCallback onToggle,
  }) {
    final colors = context.smivoColors;
    final typo = context.smivoTypo;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        InkWell(
          onTap: onToggle,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              children: [
                Icon(
                  isExpanded
                      ? Icons.keyboard_arrow_down
                      : Icons.keyboard_arrow_right,
                  color: colors.onSurfaceVariant,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: typo.titleMedium.copyWith(
                    fontWeight: FontWeight.w700,
                    color: colors.onSurface,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: colors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    items.length.toString(),
                    style: typo.labelSmall.copyWith(
                      color: colors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: Icon(
                    Icons.cleaning_services,
                    size: 20,
                    color: colors.onSurface,
                  ),
                  onPressed: () async {
                    final ids = items.map((e) => e.id).toList();
                    await ref
                        .read(notificationListProvider.notifier)
                        .deleteNotifications(ids);
                  },
                ),
              ],
            ),
          ),
        ),
        if (isExpanded)
          ...items.map(
            (notification) => NotificationListItem(
              notification: notification,
              onTap: () => _handleTap(context, ref, notification),
            ),
          ),
      ],
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
              Icon(
                Icons.notifications_none_outlined,
                size: 64,
                color: colors.onSurfaceVariant.withValues(alpha: 0.6),
              ),
              const SizedBox(height: 12),
              Text(
                'No notifications yet',
                style: typo.bodyLarge.copyWith(color: colors.outlineVariant),
              ),
              const SizedBox(height: 4),
              Text(
                "We'll notify you when something happens.",
                style: typo.bodySmall.copyWith(color: colors.outlineVariant),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleTap(
    BuildContext context,
    WidgetRef ref,
    AppNotification notification,
  ) {
    if (!notification.isRead) {
      ref.read(notificationListProvider.notifier).markAsRead(notification.id);
    }
    switch (notification.actionType) {
      case 'order':
        if (notification.relatedOrderId != null) {
          context.pushNamed(
            AppRoutes.orderDetail,
            pathParameters: {'id': notification.relatedOrderId!},
          );
        }
      case 'url':
        if (notification.actionUrl != null) {
          launchUrl(Uri.parse(notification.actionUrl!));
        }
      case 'route':
        if (notification.actionUrl != null) {
          context.push(notification.actionUrl!);
        }
      case 'none':
      default:
        break;
    }
  }
}

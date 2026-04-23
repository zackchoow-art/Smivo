# Task 021: Notification Center Page

## Objective
Create a dedicated notification center page accessible from the home
screen bell icon. Displays system and order notifications in a list,
with tap-to-navigate for order-related items.

## Design Reference
See: `.agent/scratchpad/notification-center-plan.md`

## Files to CREATE:
1. `supabase/migrations/00022_notification_action_type.sql`
2. `lib/features/notifications/screens/notification_center_screen.dart`
3. `lib/features/notifications/widgets/notification_list_item.dart`

## Files to MODIFY:
4. `lib/data/models/notification.dart` — add actionType + actionUrl
5. `lib/core/router/app_routes.dart` — add route constant
6. `lib/core/router/router.dart` — register route
7. `lib/features/home/widgets/home_header.dart` — change icon + navigation
8. `lib/shared/widgets/message_badge_icon.dart` — rename to bell icon style

## Files to RUN:
9. `dart run build_runner build --delete-conflicting-outputs`

**DO NOT** modify any other files.

---

## Step 1: Create DB migration

Create `supabase/migrations/00022_notification_action_type.sql`:

```sql
-- ════════════════════════════════════════════════════════════
-- 00022: Notification Action Type Extension
--
-- Adds action_type and action_url to support different click
-- behaviors: navigate to order, open URL, or app route.
-- ════════════════════════════════════════════════════════════

ALTER TABLE public.notifications
  ADD COLUMN IF NOT EXISTS action_type text NOT NULL DEFAULT 'none'
    CHECK (action_type IN ('none', 'order', 'url', 'route')),
  ADD COLUMN IF NOT EXISTS action_url text;

-- Backfill existing order notifications with action_type = 'order'
UPDATE public.notifications
SET action_type = 'order'
WHERE type IN (
  'order_placed', 'order_accepted', 'order_cancelled',
  'order_delivered', 'order_completed'
)
AND related_order_id IS NOT NULL;

-- Update existing triggers to set action_type = 'order' on insert.
-- notify_order_placed
CREATE OR REPLACE FUNCTION public.notify_order_placed()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = ''
AS $$
DECLARE
  v_listing_title text;
BEGIN
  SELECT title INTO v_listing_title
  FROM public.listings
  WHERE id = NEW.listing_id;

  INSERT INTO public.notifications
    (user_id, type, title, body, related_order_id, action_type)
  VALUES (
    NEW.seller_id,
    'order_placed',
    'New order received',
    'Someone placed an order for "' || coalesce(v_listing_title, 'your listing') || '"',
    NEW.id,
    'order'
  );
  RETURN NEW;
END;
$$;

-- notify_order_status_change
CREATE OR REPLACE FUNCTION public.notify_order_status_change()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = ''
AS $$
DECLARE
  v_listing_title text;
  v_title_snippet text;
BEGIN
  IF old.status IS NOT DISTINCT FROM new.status THEN
    RETURN NEW;
  END IF;

  SELECT title INTO v_listing_title
  FROM public.listings
  WHERE id = NEW.listing_id;
  v_title_snippet := coalesce(v_listing_title, 'your order');

  IF old.status = 'pending' AND new.status = 'confirmed' THEN
    INSERT INTO public.notifications
      (user_id, type, title, body, related_order_id, action_type)
    VALUES (
      NEW.buyer_id, 'order_accepted', 'Order accepted',
      'The seller accepted your order for "' || v_title_snippet || '"',
      NEW.id, 'order'
    );
  END IF;

  IF new.status = 'cancelled' THEN
    INSERT INTO public.notifications
      (user_id, type, title, body, related_order_id, action_type)
    VALUES
      (NEW.buyer_id, 'order_cancelled', 'Order cancelled',
       'Your order for "' || v_title_snippet || '" was cancelled',
       NEW.id, 'order'),
      (NEW.seller_id, 'order_cancelled', 'Order cancelled',
       'The order for "' || v_title_snippet || '" was cancelled',
       NEW.id, 'order');
  END IF;

  IF new.status = 'completed' THEN
    INSERT INTO public.notifications
      (user_id, type, title, body, related_order_id, action_type)
    VALUES
      (NEW.buyer_id, 'order_completed', 'Order completed',
       'Your order for "' || v_title_snippet || '" is complete',
       NEW.id, 'order'),
      (NEW.seller_id, 'order_completed', 'Order completed',
       'The order for "' || v_title_snippet || '" is complete',
       NEW.id, 'order');
  END IF;

  RETURN NEW;
END;
$$;

-- notify_delivery_confirmed
CREATE OR REPLACE FUNCTION public.notify_delivery_confirmed()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = ''
AS $$
DECLARE
  v_listing_title text;
  v_title_snippet text;
BEGIN
  SELECT title INTO v_listing_title
  FROM public.listings
  WHERE id = NEW.listing_id;
  v_title_snippet := coalesce(v_listing_title, 'your order');

  IF old.delivery_confirmed_by_buyer = false
     AND new.delivery_confirmed_by_buyer = true THEN
    INSERT INTO public.notifications
      (user_id, type, title, body, related_order_id, action_type)
    VALUES (
      NEW.seller_id, 'order_delivered', 'Buyer confirmed delivery',
      'The buyer confirmed delivery for "' || v_title_snippet || '"',
      NEW.id, 'order'
    );
  END IF;

  IF old.delivery_confirmed_by_seller = false
     AND new.delivery_confirmed_by_seller = true THEN
    INSERT INTO public.notifications
      (user_id, type, title, body, related_order_id, action_type)
    VALUES (
      NEW.buyer_id, 'order_delivered', 'Seller confirmed delivery',
      'The seller confirmed delivery for "' || v_title_snippet || '"',
      NEW.id, 'order'
    );
  END IF;

  RETURN NEW;
END;
$$;
```

**⚠️ USER 需手动执行此 SQL。**

---

## Step 2: Update notification model

Modify `lib/data/models/notification.dart`:

```dart
// ignore_for_file: invalid_annotation_target
import 'package:freezed_annotation/freezed_annotation.dart';

part 'notification.freezed.dart';
part 'notification.g.dart';

/// System notification for the current user.
///
/// Maps to the `notifications` table. Notifications are auto-generated
/// by database triggers when order events occur.
///
/// action_type determines click behavior:
/// - 'none': mark as read only
/// - 'order': navigate to order detail via related_order_id
/// - 'url': open action_url in external browser (future)
/// - 'route': navigate to action_url as app route (future)
@freezed
abstract class AppNotification with _$AppNotification {
  const factory AppNotification({
    required String id,
    @JsonKey(name: 'user_id') required String userId,
    required String type,
    required String title,
    required String body,
    @JsonKey(name: 'is_read') @Default(false) bool isRead,
    @JsonKey(name: 'related_order_id') String? relatedOrderId,
    @JsonKey(name: 'action_type') @Default('none') String actionType,
    @JsonKey(name: 'action_url') String? actionUrl,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    @JsonKey(name: 'updated_at') required DateTime updatedAt,
  }) = _AppNotification;

  factory AppNotification.fromJson(Map<String, dynamic> json) =>
      _$AppNotificationFromJson(json);
}
```

---

## Step 3: Add route constants

In `lib/core/router/app_routes.dart`, add:

```dart
  // Route Names — add:
  static const String notificationCenter = 'notificationCenter';

  // Route Paths — add:
  static const String notificationCenterPath = '/notifications';
```

---

## Step 4: Register route in router.dart

In `lib/core/router/router.dart`, add this import at the top:

```dart
import 'package:smivo/features/notifications/screens/notification_center_screen.dart';
```

Add this route after the Buyer Center route block (around line 253):

```dart
      // ── Notification Center ──────────────────────────────
      GoRoute(
        name: AppRoutes.notificationCenter,
        path: AppRoutes.notificationCenterPath,
        builder: (context, state) => const NotificationCenterScreen(),
      ),
```

---

## Step 5: Create notification_list_item.dart

Create `lib/features/notifications/widgets/notification_list_item.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:smivo/core/theme/app_colors.dart';
import 'package:smivo/core/theme/app_spacing.dart';
import 'package:smivo/core/theme/app_text_styles.dart';
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
```

---

## Step 6: Create notification_center_screen.dart

Create `lib/features/notifications/screens/notification_center_screen.dart`:

```dart
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
```

---

## Step 7: Update home_header.dart

Modify `lib/features/home/widgets/home_header.dart`:

Change the icon from `MessageBadgeIcon` to a bell icon that navigates
to the notification center.

Find in the Row:
```dart
                  MessageBadgeIcon(unreadCount: unreadCount),
```

Replace with:
```dart
                  _NotificationBellIcon(unreadCount: unreadCount),
```

Remove the import:
```dart
import 'package:smivo/shared/widgets/message_badge_icon.dart';
```

Add this private widget at the bottom of the file (before the closing):

```dart
class _NotificationBellIcon extends StatelessWidget {
  const _NotificationBellIcon({required this.unreadCount});

  final int unreadCount;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () => context.pushNamed(AppRoutes.notificationCenter),
      icon: Stack(
        clipBehavior: Clip.none,
        children: [
          Icon(
            unreadCount > 0
                ? Icons.notifications_active
                : Icons.notifications_outlined,
            color: AppColors.primary,
            size: 28,
          ),
          if (unreadCount > 0)
            Positioned(
              right: -4,
              top: -4,
              child: Container(
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  color: const Color(0xFFCC3300),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 1.5),
                ),
                constraints: const BoxConstraints(
                  minWidth: 18,
                  minHeight: 18,
                ),
                child: Center(
                  child: Text(
                    unreadCount > 9 ? '9+' : unreadCount.toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      height: 1,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
```

Make sure `AppRoutes` and `AppColors` are imported.

---

## Step 8: Check url_launcher dependency

Run:
```bash
grep "url_launcher" pubspec.yaml
```

If not found, add it:
```bash
cd /Users/george/smivo && flutter pub add url_launcher
```

If `url_launcher` is not desired right now, remove the `launchUrl` call
in the notification center screen and replace with a TODO comment.
An acceptable alternative: skip the `case 'url':` branch entirely for
now since no URL notifications exist yet.

---

## Step 9: Run build_runner

```bash
cd /Users/george/smivo && dart run build_runner build --delete-conflicting-outputs
```

---

## Step 10: Verify

```bash
cd /Users/george/smivo && flutter analyze
```

Report ONLY errors. Write report to `.agent/reports/report-021.md`.

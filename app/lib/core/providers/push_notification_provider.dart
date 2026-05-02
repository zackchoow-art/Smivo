import 'package:flutter/foundation.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:smivo/data/repositories/profile_repository.dart';
import 'package:smivo/features/auth/providers/auth_provider.dart';
import 'package:smivo/features/chat/providers/chat_provider.dart';
import 'package:smivo/core/router/router.dart';
import 'package:smivo/core/router/app_routes.dart';

part 'push_notification_provider.g.dart';

/// Manages OneSignal push notification lifecycle:
/// - Requests permission on first login
/// - Stores player ID in user_profiles
/// - Handles login/logout identity
/// - Listens for notification opened events
@riverpod
class PushNotificationManager extends _$PushNotificationManager {
  @override
  Future<void> build() async {
    final user = ref.watch(authStateProvider).value;

    if (user == null) {
      // NOTE: Logout clears OneSignal identity so pushes stop
      if (!kIsWeb) {
        OneSignal.logout();
      }
      return;
    }

    // Associate Supabase user ID with OneSignal
    if (!kIsWeb) {
      OneSignal.login(user.id);
    }

    // Request push permission (iOS shows native dialog once)
    // NOTE: On web/Android this is a no-op or auto-granted
    if (!kIsWeb) {
      final granted = await OneSignal.Notifications.requestPermission(true);
      debugPrint('Push permission granted: $granted');
    }

    // Store player ID in DB for server-side push targeting
    _storePlayerId(user.id);

    // Setup notification opened handler
    if (!kIsWeb) {
      OneSignal.Notifications.addClickListener(_onNotificationClicked);
      OneSignal.Notifications.addForegroundWillDisplayListener(
        _onForegroundNotification,
      );

      ref.onDispose(() {
        OneSignal.Notifications.removeClickListener(_onNotificationClicked);
        OneSignal.Notifications.removeForegroundWillDisplayListener(
          _onForegroundNotification,
        );
      });
    }
  }

  void _onForegroundNotification(OSNotificationWillDisplayEvent event) {
    // If the notification is for the chat room currently being viewed,
    // suppress it to avoid distracting the user.
    final activeRoomId = ref.read(activeChatRoomProvider);
    final notificationData = event.notification.additionalData;

    debugPrint('[Push] Foreground notification received.');
    debugPrint('[Push] activeChatRoomProvider = $activeRoomId');
    debugPrint('[Push] notification data = $notificationData');

    if (notificationData != null) {
      // NOTE: Use toString() instead of 'as String?' because OneSignal may
      // deserialize the UUID as a non-String dynamic object on some platforms.
      final rawValue = notificationData['chat_room_id'];
      final chatRoomId = rawValue?.toString();

      debugPrint('[Push] parsed chat_room_id = $chatRoomId');

      if (activeRoomId != null && chatRoomId != null && chatRoomId == activeRoomId) {
        debugPrint('[Push] Suppressing notification — user is in the active chat room.');
        event.preventDefault();
        return;
      }
    }

    debugPrint('[Push] Notification will be displayed.');
  }

  void _onNotificationClicked(OSNotificationClickEvent event) {
    debugPrint('Notification clicked: ${event.notification.title}');
    final data = event.notification.additionalData;
    if (data == null) return;

    final type = data['type'] as String?;
    final orderId = data['order_id'] as String?;
    final actionUrl = data['action_url'] as String?;

    final router = ref.read(routerProvider);

    // order_placed has a special route: Transaction Management Offers tab
    // Other order notifications still go to order detail
    if (actionUrl != null && actionUrl.isNotEmpty) {
      router.push(actionUrl);
    } else if (type != null && type.startsWith('order_') && orderId != null) {
      router.pushNamed(AppRoutes.orderDetail, pathParameters: {'id': orderId});
    }
  }

  Future<void> _storePlayerId(String userId) async {
    try {
      if (kIsWeb) return;
      // NOTE: OneSignal v5 uses subscription ID instead of player ID
      final subscriptionId = OneSignal.User.pushSubscription.id;
      if (subscriptionId != null && subscriptionId.isNotEmpty) {
        final profileRepo = ref.read(profileRepositoryProvider);
        await profileRepo.updatePushToken(
          userId: userId,
          playerId: subscriptionId,
        );
      }
    } catch (e) {
      // HACK: Silently fail — push token storage is non-critical
      debugPrint('Failed to store push token: $e');
    }
  }
}

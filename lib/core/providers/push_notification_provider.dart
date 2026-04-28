import 'package:flutter/foundation.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:smivo/data/repositories/profile_repository.dart';
import 'package:smivo/features/auth/providers/auth_provider.dart';

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
    final user = ref.watch(authStateProvider).valueOrNull;

    if (user == null) {
      // NOTE: Logout clears OneSignal identity so pushes stop
      OneSignal.logout();
      return;
    }

    // Associate Supabase user ID with OneSignal
    OneSignal.login(user.id);

    // Request push permission (iOS shows native dialog once)
    // NOTE: On web/Android this is a no-op or auto-granted
    if (!kIsWeb) {
      final granted = await OneSignal.Notifications.requestPermission(true);
      debugPrint('Push permission granted: $granted');
    }

    // Store player ID in DB for server-side push targeting
    _storePlayerId(user.id);

    // Setup notification opened handler
    OneSignal.Notifications.addClickListener(_onNotificationClicked);

    ref.onDispose(() {
      OneSignal.Notifications.removeClickListener(_onNotificationClicked);
    });
  }

  void _onNotificationClicked(OSNotificationClickEvent event) {
    debugPrint('Notification clicked: ${event.notification.title}');
  }

  Future<void> _storePlayerId(String userId) async {
    try {
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

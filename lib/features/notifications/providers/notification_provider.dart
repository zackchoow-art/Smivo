import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:smivo/data/models/notification.dart';
import 'package:smivo/data/repositories/notification_repository.dart';
import 'package:smivo/features/auth/providers/auth_provider.dart';

part 'notification_provider.g.dart';

/// Fetches the user's notification list and subscribes to new ones
/// in real-time. Refreshes itself when new notifications arrive.
@riverpod
class NotificationList extends _$NotificationList {
  RealtimeChannel? _channel;

  @override
  Future<List<AppNotification>> build() async {
    final user = ref.watch(authStateProvider).valueOrNull;
    if (user == null) return [];

    // Clean up subscription on dispose
    ref.onDispose(() {
      _channel?.unsubscribe();
      _channel = null;
    });

    final repository = ref.read(notificationRepositoryProvider);

    // Subscribe to new notifications for this user
    _channel = repository.subscribeToNotifications(
      userId: user.id,
      onNotification: (newNotification) {
        // Prepend new notification to the current list
        final current = state.valueOrNull ?? [];
        if (current.any((n) => n.id == newNotification.id)) return;
        state = AsyncValue.data([newNotification, ...current]);
      },
    );

    // Initial fetch
    return repository.fetchNotifications(user.id);
  }

  /// Marks a single notification as read.
  Future<void> markAsRead(String notificationId) async {
    final repository = ref.read(notificationRepositoryProvider);
    await repository.markAsRead(notificationId);

    // Update local state optimistically
    final current = state.valueOrNull ?? [];
    state = AsyncValue.data(
      current.map((n) {
        if (n.id == notificationId) {
          return n.copyWith(isRead: true);
        }
        return n;
      }).toList(),
    );
  }

  /// Marks all notifications for the current user as read.
  Future<void> markAllAsRead() async {
    final user = ref.read(authStateProvider).valueOrNull;
    if (user == null) return;

    final repository = ref.read(notificationRepositoryProvider);
    await repository.markAllAsRead(user.id);

    // Update local state optimistically
    final current = state.valueOrNull ?? [];
    state = AsyncValue.data(
      current.map((n) => n.copyWith(isRead: true)).toList(),
    );
  }
}

/// Total unread notification count for the current user.
/// Used by the home screen notification icon badge.
@riverpod
Future<int> totalUnreadNotifications(Ref ref) async {
  final notifications = await ref.watch(notificationListProvider.future);
  return notifications.where((n) => !n.isRead).length;
}

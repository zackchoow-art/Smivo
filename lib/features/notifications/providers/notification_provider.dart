import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_app_badger/flutter_app_badger.dart';

import 'package:smivo/data/models/notification.dart';
import 'package:smivo/data/repositories/notification_repository.dart';
import 'package:smivo/features/auth/providers/auth_provider.dart';

part 'notification_provider.g.dart';

/// Fetches the user's notification list and subscribes to new ones
/// in real-time. Refreshes itself when new notifications arrive.
@riverpod
class NotificationList extends _$NotificationList {
  RealtimeChannel? _channel;
  bool _isDisposed = false;

  @override
  Future<List<AppNotification>> build() async {
    final user = ref.watch(authStateProvider).valueOrNull;

    // Cleanup if user logs out or build re-runs
    if (user == null) {
      _unsubscribe();
      _updateAppBadge([]);
      return [];
    }

    // Subscribe once per Notifier instance lifecycle
    if (_channel == null) {
      final repository = ref.read(notificationRepositoryProvider);

      _channel = repository.subscribeToNotifications(
        userId: user.id,
        onNotification: (newNotification) {
          // Safety check: don't update state if we're disposed or disposing
          if (_isDisposed) return;

          final current = state.valueOrNull ?? [];
          if (current.any((n) => n.id == newNotification.id)) return;
          final updated = [newNotification, ...current];
          state = AsyncValue.data(updated);
          _updateAppBadge(updated);
        },
      );

      ref.onDispose(() {
        _isDisposed = true;
        _unsubscribe();
      });
    }

    final repository = ref.read(notificationRepositoryProvider);
    final notifications = await repository.fetchNotifications(user.id);
    _updateAppBadge(notifications);
    return notifications;
  }

  void _unsubscribe() {
    _channel?.unsubscribe();
    _channel = null;
  }

  void _updateAppBadge(List<AppNotification> notifications) {
    final unreadCount = notifications.where((n) => !n.isRead).length;
    if (unreadCount > 0) {
      FlutterAppBadger.updateBadgeCount(unreadCount);
    } else {
      FlutterAppBadger.removeBadge();
    }
  }

  /// Marks a single notification as read.
  Future<void> markAsRead(String notificationId) async {
    final repository = ref.read(notificationRepositoryProvider);
    await repository.markAsRead(notificationId);

    // Update local state optimistically
    final current = state.valueOrNull ?? [];
    final updated =
        current.map((n) {
          if (n.id == notificationId) {
            return n.copyWith(isRead: true);
          }
          return n;
        }).toList();
    state = AsyncValue.data(updated);
    _updateAppBadge(updated);
  }

  /// Marks all notifications for the current user as read.
  Future<void> markAllAsRead() async {
    final user = ref.read(authStateProvider).valueOrNull;
    if (user == null) return;

    final repository = ref.read(notificationRepositoryProvider);
    await repository.markAllAsRead(user.id);

    // Update local state optimistically
    final current = state.valueOrNull ?? [];
    final updated = current.map((n) => n.copyWith(isRead: true)).toList();
    state = AsyncValue.data(updated);
    _updateAppBadge(updated);
  }

  /// Deletes specific notifications.
  Future<void> deleteNotifications(List<String> notificationIds) async {
    final repository = ref.read(notificationRepositoryProvider);
    await repository.deleteNotifications(notificationIds);

    // Update local state optimistically
    final current = state.valueOrNull ?? [];
    final updated =
        current.where((n) => !notificationIds.contains(n.id)).toList();
    state = AsyncValue.data(updated);
    _updateAppBadge(updated);
  }

  /// Marks all as read and deletes all notifications.
  Future<void> clearAll() async {
    final user = ref.read(authStateProvider).valueOrNull;
    if (user == null) return;

    final repository = ref.read(notificationRepositoryProvider);
    await repository.clearAllNotifications(user.id);

    state = const AsyncValue.data([]);
    _updateAppBadge([]);
  }
}

/// Total unread notification count for the current user.
/// Used by the home screen notification icon badge.
@riverpod
Future<int> totalUnreadNotifications(Ref ref) async {
  final notifications = await ref.watch(notificationListProvider.future);
  return notifications.where((n) => !n.isRead).length;
}

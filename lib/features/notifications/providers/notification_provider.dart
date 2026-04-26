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
  bool _isDisposed = false;

  @override
  Future<List<AppNotification>> build() async {
    final user = ref.watch(authStateProvider).valueOrNull;
    
    // Cleanup if user logs out or build re-runs
    if (user == null) {
      _unsubscribe();
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
          state = AsyncValue.data([newNotification, ...current]);
        },
      );

      ref.onDispose(() {
        _isDisposed = true;
        _unsubscribe();
      });
    }

    final repository = ref.read(notificationRepositoryProvider);
    return repository.fetchNotifications(user.id);
  }

  void _unsubscribe() {
    _channel?.unsubscribe();
    _channel = null;
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

  /// Deletes specific notifications.
  Future<void> deleteNotifications(List<String> notificationIds) async {
    final repository = ref.read(notificationRepositoryProvider);
    await repository.deleteNotifications(notificationIds);

    // Update local state optimistically
    final current = state.valueOrNull ?? [];
    state = AsyncValue.data(
      current.where((n) => !notificationIds.contains(n.id)).toList(),
    );
  }

  /// Marks all as read and deletes all notifications.
  Future<void> clearAll() async {
    final user = ref.read(authStateProvider).valueOrNull;
    if (user == null) return;

    final repository = ref.read(notificationRepositoryProvider);
    await repository.clearAllNotifications(user.id);

    state = const AsyncValue.data([]);
  }
}

/// Total unread notification count for the current user.
/// Used by the home screen notification icon badge.
@riverpod
Future<int> totalUnreadNotifications(Ref ref) async {
  final notifications = await ref.watch(notificationListProvider.future);
  return notifications.where((n) => !n.isRead).length;
}

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:smivo/core/exceptions/app_exception.dart';
import 'package:smivo/core/providers/supabase_provider.dart';
import 'package:smivo/data/models/notification.dart';

part 'notification_repository.g.dart';

/// Handles system notification operations + Realtime.
class NotificationRepository {
  const NotificationRepository(this._client);

  final SupabaseClient _client;

  /// Fetches all notifications for [userId], newest first.
  Future<List<AppNotification>> fetchNotifications(String userId) async {
    try {
      final data = await _client
          .from('notifications')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);
      return data.map((json) => AppNotification.fromJson(json)).toList();
    } on PostgrestException catch (e) {
      throw DatabaseException(e.message, e);
    }
  }

  /// Marks a single notification as read.
  Future<void> markAsRead(String notificationId) async {
    try {
      await _client
          .from('notifications')
          .update({'is_read': true})
          .eq('id', notificationId);
    } on PostgrestException catch (e) {
      throw DatabaseException(e.message, e);
    }
  }

  /// Marks all notifications for [userId] as read.
  Future<void> markAllAsRead(String userId) async {
    try {
      await _client
          .from('notifications')
          .update({'is_read': true})
          .eq('user_id', userId)
          .eq('is_read', false);
    } on PostgrestException catch (e) {
      throw DatabaseException(e.message, e);
    }
  }

  /// Deletes a list of notifications by their IDs.
  Future<void> deleteNotifications(List<String> notificationIds) async {
    if (notificationIds.isEmpty) return;
    try {
      await _client
          .from('notifications')
          .delete()
          .inFilter('id', notificationIds);
    } on PostgrestException catch (e) {
      throw DatabaseException(e.message, e);
    }
  }

  /// Marks all unread notifications as read and deletes all notifications for [userId].
  Future<void> clearAllNotifications(String userId) async {
    try {
      await markAllAsRead(userId);
      await _client.from('notifications').delete().eq('user_id', userId);
    } on PostgrestException catch (e) {
      throw DatabaseException(e.message, e);
    }
  }

  /// Subscribes to new notifications for [userId] via Realtime.
  RealtimeChannel subscribeToNotifications({
    required String userId,
    required void Function(AppNotification notification) onNotification,
  }) {
    return _client
        .channel('notifications:$userId')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'notifications',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'user_id',
            value: userId,
          ),
          callback: (payload) {
            final notification = AppNotification.fromJson(payload.newRecord);
            onNotification(notification);
          },
        )
        .subscribe();
  }
}

@riverpod
NotificationRepository notificationRepository(Ref ref) =>
    NotificationRepository(ref.watch(supabaseClientProvider));

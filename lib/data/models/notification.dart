// ignore_for_file: invalid_annotation_target
import 'package:freezed_annotation/freezed_annotation.dart';

part 'notification.freezed.dart';
part 'notification.g.dart';

/// System notification for the current user.
///
/// Maps to the `notifications` table. Notifications are auto-generated
/// by database triggers when order events occur.
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

// ignore_for_file: invalid_annotation_target
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:smivo/data/models/school.dart';

part 'user_profile.freezed.dart';
part 'user_profile.g.dart';

@freezed
abstract class UserProfile with _$UserProfile {
  const factory UserProfile({
    required String id,
    required String email,
    @JsonKey(name: 'display_name') String? displayName,
    @JsonKey(name: 'avatar_url') String? avatarUrl,
    @Default('Smith College') String school,
    @JsonKey(name: 'school_id') required String schoolId,
    @JsonKey(name: 'is_verified') @Default(false) bool isVerified,
    // Nested join — populated when querying with school join
    School? schoolData,
    @JsonKey(name: 'created_at') DateTime? createdAt,
    @JsonKey(name: 'updated_at') DateTime? updatedAt,
    // User preference for receiving email notifications
    @JsonKey(name: 'email_notifications_enabled') @Default(true) bool emailNotificationsEnabled,
    // OneSignal device token for push notifications
    @JsonKey(name: 'onesignal_player_id') String? onesignalPlayerId,
    // Master push notification toggle
    @JsonKey(name: 'push_notifications_enabled') @Default(true) bool pushNotificationsEnabled,
    // Push preference for new chat messages
    @JsonKey(name: 'push_messages') @Default(true) bool pushMessages,
    // Push preference for order status updates
    @JsonKey(name: 'push_order_updates') @Default(true) bool pushOrderUpdates,
  }) = _UserProfile;

  factory UserProfile.fromJson(Map<String, dynamic> json) =>
      _$UserProfileFromJson(json);
}

// ignore_for_file: invalid_annotation_target
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:smivo/data/models/school.dart';

part 'user_profile.freezed.dart';
part 'user_profile.g.dart';

bool _parseBool(dynamic value) {
  if (value is bool) return value;
  if (value is num) return value > 0;
  if (value is String) return value.toLowerCase() == 'true' || value == '1';
  return false;
}

@freezed
abstract class UserProfile with _$UserProfile {
  const factory UserProfile({
    required String id,
    required String email,
    @JsonKey(name: 'display_name') String? displayName,
    @JsonKey(name: 'avatar_url') String? avatarUrl,
    @Default('Data Not Found') String school,
    @JsonKey(name: 'school_id') required String schoolId,
    @JsonKey(name: 'is_verified', fromJson: _parseBool) @Default(false) bool isVerified,
    // Nested join — populated when querying with school join
    School? schoolData,
    @JsonKey(name: 'created_at') DateTime? createdAt,
    @JsonKey(name: 'updated_at') DateTime? updatedAt,
    // User preference for receiving email notifications
    @JsonKey(name: 'email_notifications_enabled', fromJson: _parseBool)
    @Default(false)
    bool emailNotificationsEnabled,
    // OneSignal device token for push notifications
    @JsonKey(name: 'onesignal_player_id') String? onesignalPlayerId,
    // Master push notification toggle
    @JsonKey(name: 'push_notifications_enabled', fromJson: _parseBool)
    @Default(true)
    bool pushNotificationsEnabled,

    // -- Messages --
    @JsonKey(name: 'push_messages', fromJson: _parseBool) @Default(true) bool pushMessages,
    @JsonKey(name: 'email_messages', fromJson: _parseBool) @Default(false) bool emailMessages,

    // -- Order Updates --
    @JsonKey(name: 'push_order_updates', fromJson: _parseBool) @Default(true) bool pushOrderUpdates,
    @JsonKey(name: 'email_order_updates', fromJson: _parseBool)
    @Default(false)
    bool emailOrderUpdates,

    // -- Campus Announcements --
    @JsonKey(name: 'push_campus_announcements', fromJson: _parseBool)
    @Default(true)
    bool pushCampusAnnouncements,
    @JsonKey(name: 'email_campus_announcements', fromJson: _parseBool)
    @Default(false)
    bool emailCampusAnnouncements,

    // -- Platform Announcements --
    @JsonKey(name: 'push_announcements', fromJson: _parseBool) @Default(true) bool pushAnnouncements,
    @JsonKey(name: 'email_announcements', fromJson: _parseBool)
    @Default(false)
    bool emailAnnouncements,

    // -- Ratings --
    @JsonKey(name: 'buyer_rating') @Default(0.0) double buyerRating,
    @JsonKey(name: 'buyer_rating_count') @Default(0) int buyerRatingCount,
    @JsonKey(name: 'seller_rating') @Default(0.0) double sellerRating,
    @JsonKey(name: 'seller_rating_count') @Default(0) int sellerRatingCount,

    // -- Community Contribution --
    @JsonKey(name: 'contribution_score') @Default(0) int contributionScore,
    @JsonKey(name: 'contribution_level') @Default(1) int contributionLevel,
    @JsonKey(name: 'last_active_at') DateTime? lastActiveAt,
    // Soft-delete timestamp — set when user deletes their account.
    // Profile row is kept (anonymized) so FK references still resolve.
    @JsonKey(name: 'deleted_at') DateTime? deletedAt,
  }) = _UserProfile;

  factory UserProfile.fromJson(Map<String, dynamic> json) =>
      _$UserProfileFromJson(json);
}

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
    @JsonKey(name: 'email_notifications_enabled')
    @Default(false)
    bool emailNotificationsEnabled,
    // OneSignal device token for push notifications
    @JsonKey(name: 'onesignal_player_id') String? onesignalPlayerId,
    // Master push notification toggle
    @JsonKey(name: 'push_notifications_enabled')
    @Default(true)
    bool pushNotificationsEnabled,

    // -- Messages --
    @JsonKey(name: 'push_messages') @Default(true) bool pushMessages,
    @JsonKey(name: 'email_messages') @Default(false) bool emailMessages,

    // -- Order Updates --
    @JsonKey(name: 'push_order_updates') @Default(true) bool pushOrderUpdates,
    @JsonKey(name: 'email_order_updates')
    @Default(false)
    bool emailOrderUpdates,

    // -- Campus Announcements --
    @JsonKey(name: 'push_campus_announcements')
    @Default(true)
    bool pushCampusAnnouncements,
    @JsonKey(name: 'email_campus_announcements')
    @Default(false)
    bool emailCampusAnnouncements,

    // -- Platform Announcements --
    @JsonKey(name: 'push_announcements') @Default(true) bool pushAnnouncements,
    @JsonKey(name: 'email_announcements')
    @Default(false)
    bool emailAnnouncements,

    // -- Ratings --
    @JsonKey(name: 'buyer_rating') @Default(0.0) double buyerRating,
    @JsonKey(name: 'buyer_rating_count') @Default(0) int buyerRatingCount,
    @JsonKey(name: 'seller_rating') @Default(0.0) double sellerRating,
    @JsonKey(name: 'seller_rating_count') @Default(0) int sellerRatingCount,
  }) = _UserProfile;

  factory UserProfile.fromJson(Map<String, dynamic> json) =>
      _$UserProfileFromJson(json);
}

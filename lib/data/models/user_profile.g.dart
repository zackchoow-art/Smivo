// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_profile.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_UserProfile _$UserProfileFromJson(Map<String, dynamic> json) => _UserProfile(
  id: json['id'] as String,
  email: json['email'] as String,
  displayName: json['display_name'] as String?,
  avatarUrl: json['avatar_url'] as String?,
  school: json['school'] as String? ?? 'Smith College',
  schoolId: json['school_id'] as String,
  isVerified: json['is_verified'] as bool? ?? false,
  schoolData:
      json['schoolData'] == null
          ? null
          : School.fromJson(json['schoolData'] as Map<String, dynamic>),
  createdAt:
      json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
  updatedAt:
      json['updated_at'] == null
          ? null
          : DateTime.parse(json['updated_at'] as String),
  emailNotificationsEnabled:
      json['email_notifications_enabled'] as bool? ?? false,
  onesignalPlayerId: json['onesignal_player_id'] as String?,
  pushNotificationsEnabled: json['push_notifications_enabled'] as bool? ?? true,
  pushMessages: json['push_messages'] as bool? ?? true,
  emailMessages: json['email_messages'] as bool? ?? false,
  pushOrderUpdates: json['push_order_updates'] as bool? ?? true,
  emailOrderUpdates: json['email_order_updates'] as bool? ?? false,
  pushCampusAnnouncements: json['push_campus_announcements'] as bool? ?? true,
  emailCampusAnnouncements:
      json['email_campus_announcements'] as bool? ?? false,
  pushAnnouncements: json['push_announcements'] as bool? ?? true,
  emailAnnouncements: json['email_announcements'] as bool? ?? false,
  buyerRating: (json['buyer_rating'] as num?)?.toDouble() ?? 0.0,
  buyerRatingCount: (json['buyer_rating_count'] as num?)?.toInt() ?? 0,
  sellerRating: (json['seller_rating'] as num?)?.toDouble() ?? 0.0,
  sellerRatingCount: (json['seller_rating_count'] as num?)?.toInt() ?? 0,
);

Map<String, dynamic> _$UserProfileToJson(_UserProfile instance) =>
    <String, dynamic>{
      'id': instance.id,
      'email': instance.email,
      'display_name': instance.displayName,
      'avatar_url': instance.avatarUrl,
      'school': instance.school,
      'school_id': instance.schoolId,
      'is_verified': instance.isVerified,
      'schoolData': instance.schoolData,
      'created_at': instance.createdAt?.toIso8601String(),
      'updated_at': instance.updatedAt?.toIso8601String(),
      'email_notifications_enabled': instance.emailNotificationsEnabled,
      'onesignal_player_id': instance.onesignalPlayerId,
      'push_notifications_enabled': instance.pushNotificationsEnabled,
      'push_messages': instance.pushMessages,
      'email_messages': instance.emailMessages,
      'push_order_updates': instance.pushOrderUpdates,
      'email_order_updates': instance.emailOrderUpdates,
      'push_campus_announcements': instance.pushCampusAnnouncements,
      'email_campus_announcements': instance.emailCampusAnnouncements,
      'push_announcements': instance.pushAnnouncements,
      'email_announcements': instance.emailAnnouncements,
      'buyer_rating': instance.buyerRating,
      'buyer_rating_count': instance.buyerRatingCount,
      'seller_rating': instance.sellerRating,
      'seller_rating_count': instance.sellerRatingCount,
    };

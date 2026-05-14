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
  school: json['school'] as String? ?? 'Data Not Found',
  schoolId: json['school_id'] as String,
  isVerified:
      json['is_verified'] == null ? false : _parseBool(json['is_verified']),
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
      json['email_notifications_enabled'] == null
          ? false
          : _parseBool(json['email_notifications_enabled']),
  onesignalPlayerId: json['onesignal_player_id'] as String?,
  pushNotificationsEnabled:
      json['push_notifications_enabled'] == null
          ? true
          : _parseBool(json['push_notifications_enabled']),
  pushMessages:
      json['push_messages'] == null ? true : _parseBool(json['push_messages']),
  emailMessages:
      json['email_messages'] == null
          ? false
          : _parseBool(json['email_messages']),
  pushOrderUpdates:
      json['push_order_updates'] == null
          ? true
          : _parseBool(json['push_order_updates']),
  emailOrderUpdates:
      json['email_order_updates'] == null
          ? false
          : _parseBool(json['email_order_updates']),
  pushCampusAnnouncements:
      json['push_campus_announcements'] == null
          ? true
          : _parseBool(json['push_campus_announcements']),
  emailCampusAnnouncements:
      json['email_campus_announcements'] == null
          ? false
          : _parseBool(json['email_campus_announcements']),
  pushAnnouncements:
      json['push_announcements'] == null
          ? true
          : _parseBool(json['push_announcements']),
  emailAnnouncements:
      json['email_announcements'] == null
          ? false
          : _parseBool(json['email_announcements']),
  buyerRating: (json['buyer_rating'] as num?)?.toDouble() ?? 0.0,
  buyerRatingCount: (json['buyer_rating_count'] as num?)?.toInt() ?? 0,
  sellerRating: (json['seller_rating'] as num?)?.toDouble() ?? 0.0,
  sellerRatingCount: (json['seller_rating_count'] as num?)?.toInt() ?? 0,
  contributionScore: (json['contribution_score'] as num?)?.toInt() ?? 0,
  contributionLevel: (json['contribution_level'] as num?)?.toInt() ?? 1,
  lastActiveAt:
      json['last_active_at'] == null
          ? null
          : DateTime.parse(json['last_active_at'] as String),
  deletedAt:
      json['deleted_at'] == null
          ? null
          : DateTime.parse(json['deleted_at'] as String),
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
      'contribution_score': instance.contributionScore,
      'contribution_level': instance.contributionLevel,
      'last_active_at': instance.lastActiveAt?.toIso8601String(),
      'deleted_at': instance.deletedAt?.toIso8601String(),
    };

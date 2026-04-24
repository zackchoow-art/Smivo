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
      json['email_notifications_enabled'] as bool? ?? true,
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
    };

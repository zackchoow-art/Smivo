// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_feedback.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_UserFeedback _$UserFeedbackFromJson(Map<String, dynamic> json) =>
    _UserFeedback(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      type: json['type'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      screenshotUrl: json['screenshot_url'] as String?,
      deviceInfo: json['device_info'] as Map<String, dynamic>?,
      status: json['status'] as String? ?? 'submitted',
      adminResponse: json['admin_response'] as String?,
      pointsAwarded: (json['points_awarded'] as num?)?.toInt() ?? 0,
      createdAt:
          json['created_at'] == null
              ? null
              : DateTime.parse(json['created_at'] as String),
      updatedAt:
          json['updated_at'] == null
              ? null
              : DateTime.parse(json['updated_at'] as String),
    );

Map<String, dynamic> _$UserFeedbackToJson(_UserFeedback instance) =>
    <String, dynamic>{
      'id': instance.id,
      'user_id': instance.userId,
      'type': instance.type,
      'title': instance.title,
      'description': instance.description,
      'screenshot_url': instance.screenshotUrl,
      'device_info': instance.deviceInfo,
      'status': instance.status,
      'admin_response': instance.adminResponse,
      'points_awarded': instance.pointsAwarded,
      'created_at': instance.createdAt?.toIso8601String(),
      'updated_at': instance.updatedAt?.toIso8601String(),
    };

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'carpool_member.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_CarpoolMember _$CarpoolMemberFromJson(Map<String, dynamic> json) =>
    _CarpoolMember(
      id: json['id'] as String,
      tripId: json['trip_id'] as String,
      userId: json['user_id'] as String,
      role: json['role'] as String,
      status: json['status'] as String? ?? 'pending',
      joinedAt:
          json['joined_at'] == null
              ? null
              : DateTime.parse(json['joined_at'] as String),
      createdAt: DateTime.parse(json['created_at'] as String),
      user:
          json['user'] == null
              ? null
              : UserProfile.fromJson(json['user'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$CarpoolMemberToJson(_CarpoolMember instance) =>
    <String, dynamic>{
      'id': instance.id,
      'trip_id': instance.tripId,
      'user_id': instance.userId,
      'role': instance.role,
      'status': instance.status,
      'joined_at': instance.joinedAt?.toIso8601String(),
      'created_at': instance.createdAt.toIso8601String(),
      'user': instance.user,
    };

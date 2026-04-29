// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_role.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_AdminRole _$AdminRoleFromJson(Map<String, dynamic> json) => _AdminRole(
  id: json['id'] as String,
  userId: json['user_id'] as String,
  role: json['role'] as String,
  scopeType: json['scope_type'] as String,
  scopeId: json['scope_id'] as String?,
  isActive: json['is_active'] as bool? ?? true,
  createdAt: DateTime.parse(json['created_at'] as String),
  updatedAt: DateTime.parse(json['updated_at'] as String),
  userEmail: json['user_email'] as String?,
  userName: json['user_name'] as String?,
  schoolName: json['school_name'] as String?,
);

Map<String, dynamic> _$AdminRoleToJson(_AdminRole instance) =>
    <String, dynamic>{
      'id': instance.id,
      'user_id': instance.userId,
      'role': instance.role,
      'scope_type': instance.scopeType,
      'scope_id': instance.scopeId,
      'is_active': instance.isActive,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
      'user_email': instance.userEmail,
      'user_name': instance.userName,
      'school_name': instance.schoolName,
    };

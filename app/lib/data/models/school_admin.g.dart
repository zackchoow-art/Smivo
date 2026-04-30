// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'school_admin.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_SchoolAdmin _$SchoolAdminFromJson(Map<String, dynamic> json) => _SchoolAdmin(
  id: json['id'] as String,
  schoolId: json['school_id'] as String,
  userId: json['user_id'] as String,
  role: json['role'] as String? ?? 'admin',
  createdAt: DateTime.parse(json['created_at'] as String),
  updatedAt: DateTime.parse(json['updated_at'] as String),
);

Map<String, dynamic> _$SchoolAdminToJson(_SchoolAdmin instance) =>
    <String, dynamic>{
      'id': instance.id,
      'school_id': instance.schoolId,
      'user_id': instance.userId,
      'role': instance.role,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
    };

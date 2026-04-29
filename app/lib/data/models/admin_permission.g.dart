// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_permission.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_AdminPermission _$AdminPermissionFromJson(Map<String, dynamic> json) =>
    _AdminPermission(
      id: json['id'] as String,
      roleId: json['role_id'] as String,
      module: json['module'] as String,
      permission: json['permission'] as String? ?? 'none',
      createdAt:
          json['created_at'] == null
              ? null
              : DateTime.parse(json['created_at'] as String),
      updatedAt:
          json['updated_at'] == null
              ? null
              : DateTime.parse(json['updated_at'] as String),
    );

Map<String, dynamic> _$AdminPermissionToJson(_AdminPermission instance) =>
    <String, dynamic>{
      'id': instance.id,
      'role_id': instance.roleId,
      'module': instance.module,
      'permission': instance.permission,
      'created_at': instance.createdAt?.toIso8601String(),
      'updated_at': instance.updatedAt?.toIso8601String(),
    };

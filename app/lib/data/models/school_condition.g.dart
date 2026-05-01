// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'school_condition.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_SchoolCondition _$SchoolConditionFromJson(Map<String, dynamic> json) =>
    _SchoolCondition(
      id: json['id'] as String,
      schoolId: json['school_id'] as String,
      slug: json['slug'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      displayOrder: (json['display_order'] as num?)?.toInt() ?? 0,
      isActive: json['is_active'] as bool? ?? true,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );

Map<String, dynamic> _$SchoolConditionToJson(_SchoolCondition instance) =>
    <String, dynamic>{
      'id': instance.id,
      'school_id': instance.schoolId,
      'slug': instance.slug,
      'name': instance.name,
      'description': instance.description,
      'display_order': instance.displayOrder,
      'is_active': instance.isActive,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
    };

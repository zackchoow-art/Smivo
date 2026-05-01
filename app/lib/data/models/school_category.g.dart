// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'school_category.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_SchoolCategory _$SchoolCategoryFromJson(Map<String, dynamic> json) =>
    _SchoolCategory(
      id: json['id'] as String,
      schoolId: json['school_id'] as String,
      slug: json['slug'] as String,
      name: json['name'] as String,
      icon: json['icon'] as String?,
      displayOrder: (json['display_order'] as num?)?.toInt() ?? 0,
      isActive: json['is_active'] as bool? ?? true,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );

Map<String, dynamic> _$SchoolCategoryToJson(_SchoolCategory instance) =>
    <String, dynamic>{
      'id': instance.id,
      'school_id': instance.schoolId,
      'slug': instance.slug,
      'name': instance.name,
      'icon': instance.icon,
      'display_order': instance.displayOrder,
      'is_active': instance.isActive,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
    };

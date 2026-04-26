// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'system_dictionary.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_SystemDictionary _$SystemDictionaryFromJson(Map<String, dynamic> json) =>
    _SystemDictionary(
      id: json['id'] as String,
      dictType: json['dict_type'] as String,
      dictKey: json['dict_key'] as String,
      dictValue: json['dict_value'] as String,
      description: json['description'] as String?,
      extra: json['extra'] as Map<String, dynamic>?,
      displayOrder: (json['display_order'] as num?)?.toInt() ?? 0,
      isActive: json['is_active'] as bool? ?? true,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );

Map<String, dynamic> _$SystemDictionaryToJson(_SystemDictionary instance) =>
    <String, dynamic>{
      'id': instance.id,
      'dict_type': instance.dictType,
      'dict_key': instance.dictKey,
      'dict_value': instance.dictValue,
      'description': instance.description,
      'extra': instance.extra,
      'display_order': instance.displayOrder,
      'is_active': instance.isActive,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
    };

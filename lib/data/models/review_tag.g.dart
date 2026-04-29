// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'review_tag.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ReviewTag _$ReviewTagFromJson(Map<String, dynamic> json) => _ReviewTag(
  id: json['id'] as String,
  name: json['name'] as String,
  type: json['type'] as String,
  createdAt: DateTime.parse(json['created_at'] as String),
);

Map<String, dynamic> _$ReviewTagToJson(_ReviewTag instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'type': instance.type,
      'created_at': instance.createdAt.toIso8601String(),
    };

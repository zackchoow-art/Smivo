// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'contribution_entry.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ContributionEntry _$ContributionEntryFromJson(Map<String, dynamic> json) =>
    _ContributionEntry(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      points: (json['points'] as num).toInt(),
      sourceType: json['source_type'] as String,
      sourceId: json['source_id'] as String?,
      description: json['description'] as String,
      createdAt:
          json['created_at'] == null
              ? null
              : DateTime.parse(json['created_at'] as String),
    );

Map<String, dynamic> _$ContributionEntryToJson(_ContributionEntry instance) =>
    <String, dynamic>{
      'id': instance.id,
      'user_id': instance.userId,
      'points': instance.points,
      'source_type': instance.sourceType,
      'source_id': instance.sourceId,
      'description': instance.description,
      'created_at': instance.createdAt?.toIso8601String(),
    };

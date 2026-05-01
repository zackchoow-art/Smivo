// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pickup_location.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_PickupLocation _$PickupLocationFromJson(Map<String, dynamic> json) =>
    _PickupLocation(
      id: json['id'] as String,
      schoolId: json['school_id'] as String,
      name: json['name'] as String,
      displayOrder: (json['display_order'] as num?)?.toInt() ?? 0,
      isActive: json['is_active'] as bool? ?? true,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );

Map<String, dynamic> _$PickupLocationToJson(_PickupLocation instance) =>
    <String, dynamic>{
      'id': instance.id,
      'school_id': instance.schoolId,
      'name': instance.name,
      'display_order': instance.displayOrder,
      'is_active': instance.isActive,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
    };

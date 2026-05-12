// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'group_chat_room.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_GroupChatRoom _$GroupChatRoomFromJson(Map<String, dynamic> json) =>
    _GroupChatRoom(
      id: json['id'] as String,
      tripId: json['trip_id'] as String,
      name: json['name'] as String,
      createdBy: json['created_by'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      members:
          (json['members'] as List<dynamic>?)
              ?.map((e) => GroupChatMember.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );

Map<String, dynamic> _$GroupChatRoomToJson(_GroupChatRoom instance) =>
    <String, dynamic>{
      'id': instance.id,
      'trip_id': instance.tripId,
      'name': instance.name,
      'created_by': instance.createdBy,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
      'members': instance.members,
    };

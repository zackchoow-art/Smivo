// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'group_message.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_GroupMessage _$GroupMessageFromJson(Map<String, dynamic> json) =>
    _GroupMessage(
      id: json['id'] as String,
      roomId: json['room_id'] as String,
      senderId: json['sender_id'] as String,
      content: json['content'] as String,
      messageType: json['message_type'] as String? ?? 'text',
      imageUrl: json['image_url'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      sender:
          json['sender'] == null
              ? null
              : UserProfile.fromJson(json['sender'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$GroupMessageToJson(_GroupMessage instance) =>
    <String, dynamic>{
      'id': instance.id,
      'room_id': instance.roomId,
      'sender_id': instance.senderId,
      'content': instance.content,
      'message_type': instance.messageType,
      'image_url': instance.imageUrl,
      'created_at': instance.createdAt.toIso8601String(),
      'sender': instance.sender,
    };

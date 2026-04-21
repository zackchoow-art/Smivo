// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'message.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Message _$MessageFromJson(Map<String, dynamic> json) => _Message(
  id: json['id'] as String,
  chatRoomId: json['chat_room_id'] as String,
  senderId: json['sender_id'] as String,
  content: json['content'] as String,
  messageType: json['message_type'] as String? ?? 'text',
  imageUrl: json['image_url'] as String?,
  isRead: json['is_read'] as bool? ?? false,
  createdAt: DateTime.parse(json['created_at'] as String),
  updatedAt: DateTime.parse(json['updated_at'] as String),
);

Map<String, dynamic> _$MessageToJson(_Message instance) => <String, dynamic>{
  'id': instance.id,
  'chat_room_id': instance.chatRoomId,
  'sender_id': instance.senderId,
  'content': instance.content,
  'message_type': instance.messageType,
  'image_url': instance.imageUrl,
  'is_read': instance.isRead,
  'created_at': instance.createdAt.toIso8601String(),
  'updated_at': instance.updatedAt.toIso8601String(),
};

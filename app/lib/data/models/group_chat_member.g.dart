// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'group_chat_member.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_GroupChatMember _$GroupChatMemberFromJson(Map<String, dynamic> json) =>
    _GroupChatMember(
      id: json['id'] as String,
      roomId: json['room_id'] as String,
      userId: json['user_id'] as String,
      joinedAt: DateTime.parse(json['joined_at'] as String),
      user:
          json['user'] == null
              ? null
              : UserProfile.fromJson(json['user'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$GroupChatMemberToJson(_GroupChatMember instance) =>
    <String, dynamic>{
      'id': instance.id,
      'room_id': instance.roomId,
      'user_id': instance.userId,
      'joined_at': instance.joinedAt.toIso8601String(),
      'user': instance.user,
    };

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
      lastReadAt:
          json['last_read_at'] == null
              ? null
              : DateTime.parse(json['last_read_at'] as String),
      isPinned: json['is_pinned'] as bool? ?? false,
      isArchived: json['is_archived'] as bool? ?? false,
      isUnreadOverride: json['is_unread_override'] as bool? ?? false,
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
      'last_read_at': instance.lastReadAt?.toIso8601String(),
      'is_pinned': instance.isPinned,
      'is_archived': instance.isArchived,
      'is_unread_override': instance.isUnreadOverride,
      'user': instance.user,
    };

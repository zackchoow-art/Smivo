// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_room.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ChatRoom _$ChatRoomFromJson(Map<String, dynamic> json) => _ChatRoom(
  id: json['id'] as String,
  listingId: json['listingId'] as String,
  buyerId: json['buyerId'] as String,
  sellerId: json['sellerId'] as String,
  unreadCountBuyer: (json['unread_count_buyer'] as num?)?.toInt() ?? 0,
  unreadCountSeller: (json['unread_count_seller'] as num?)?.toInt() ?? 0,
  lastMessageAt:
      json['lastMessageAt'] == null
          ? null
          : DateTime.parse(json['lastMessageAt'] as String),
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$ChatRoomToJson(_ChatRoom instance) => <String, dynamic>{
  'id': instance.id,
  'listingId': instance.listingId,
  'buyerId': instance.buyerId,
  'sellerId': instance.sellerId,
  'unread_count_buyer': instance.unreadCountBuyer,
  'unread_count_seller': instance.unreadCountSeller,
  'lastMessageAt': instance.lastMessageAt?.toIso8601String(),
  'createdAt': instance.createdAt.toIso8601String(),
  'updatedAt': instance.updatedAt.toIso8601String(),
};

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_room.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ChatRoom _$ChatRoomFromJson(Map<String, dynamic> json) => _ChatRoom(
  id: json['id'] as String,
  listingId: json['listing_id'] as String,
  buyerId: json['buyer_id'] as String,
  sellerId: json['seller_id'] as String,
  unreadCountBuyer: (json['unread_count_buyer'] as num?)?.toInt() ?? 0,
  unreadCountSeller: (json['unread_count_seller'] as num?)?.toInt() ?? 0,
  lastMessageAt:
      json['last_message_at'] == null
          ? null
          : DateTime.parse(json['last_message_at'] as String),
  createdAt: DateTime.parse(json['created_at'] as String),
  updatedAt: DateTime.parse(json['updated_at'] as String),
  isPinned: json['is_pinned'] as bool? ?? false,
  isArchived: json['is_archived'] as bool? ?? false,
  isUnreadOverride: json['is_unread_override'] as bool? ?? false,
  buyer:
      json['buyer'] == null
          ? null
          : UserProfile.fromJson(json['buyer'] as Map<String, dynamic>),
  seller:
      json['seller'] == null
          ? null
          : UserProfile.fromJson(json['seller'] as Map<String, dynamic>),
  listing:
      json['listing'] == null
          ? null
          : ChatListingPreview.fromJson(
            json['listing'] as Map<String, dynamic>,
          ),
  lastMessage:
      (json['last_message'] as List<dynamic>?)
          ?.map((e) => Message.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
);

Map<String, dynamic> _$ChatRoomToJson(_ChatRoom instance) => <String, dynamic>{
  'id': instance.id,
  'listing_id': instance.listingId,
  'buyer_id': instance.buyerId,
  'seller_id': instance.sellerId,
  'unread_count_buyer': instance.unreadCountBuyer,
  'unread_count_seller': instance.unreadCountSeller,
  'last_message_at': instance.lastMessageAt?.toIso8601String(),
  'created_at': instance.createdAt.toIso8601String(),
  'updated_at': instance.updatedAt.toIso8601String(),
  'is_pinned': instance.isPinned,
  'is_archived': instance.isArchived,
  'is_unread_override': instance.isUnreadOverride,
  'buyer': instance.buyer,
  'seller': instance.seller,
  'listing': instance.listing,
  'last_message': instance.lastMessage,
};

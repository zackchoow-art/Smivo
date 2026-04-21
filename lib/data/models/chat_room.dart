// ignore_for_file: invalid_annotation_target
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:smivo/data/models/chat_listing_preview.dart';
import 'package:smivo/data/models/message.dart';
import 'package:smivo/data/models/user_profile.dart';

part 'chat_room.freezed.dart';
part 'chat_room.g.dart';

/// Represents a 1-on-1 chat conversation tied to a listing.
///
/// Maps to the `chat_rooms` table. Each unique combination of
/// listing + buyer + seller creates exactly one chat room.
@freezed
abstract class ChatRoom with _$ChatRoom {
  const factory ChatRoom({
    required String id,
    @JsonKey(name: 'listing_id') required String listingId,
    @JsonKey(name: 'buyer_id') required String buyerId,
    @JsonKey(name: 'seller_id') required String sellerId,
    @JsonKey(name: 'unread_count_buyer') @Default(0) int unreadCountBuyer,
    @JsonKey(name: 'unread_count_seller') @Default(0) int unreadCountSeller,
    @JsonKey(name: 'last_message_at') DateTime? lastMessageAt,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    @JsonKey(name: 'updated_at') required DateTime updatedAt,
    // Nested join data — populated only by fetchChatRooms query
    UserProfile? buyer,
    UserProfile? seller,
    ChatListingPreview? listing,
    @JsonKey(name: 'last_message') @Default([]) List<Message> lastMessage,
  }) = _ChatRoom;

  factory ChatRoom.fromJson(Map<String, dynamic> json) =>
      _$ChatRoomFromJson(json);
}

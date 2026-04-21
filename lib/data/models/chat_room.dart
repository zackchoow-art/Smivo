import 'package:freezed_annotation/freezed_annotation.dart';

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
    required String listingId,
    required String buyerId,
    required String sellerId,
    @JsonKey(name: 'unread_count_buyer') @Default(0) int unreadCountBuyer,
    @JsonKey(name: 'unread_count_seller') @Default(0) int unreadCountSeller,
    DateTime? lastMessageAt,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _ChatRoom;

  factory ChatRoom.fromJson(Map<String, dynamic> json) =>
      _$ChatRoomFromJson(json);
}

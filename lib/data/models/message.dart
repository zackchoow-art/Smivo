import 'package:freezed_annotation/freezed_annotation.dart';

part 'message.freezed.dart';
part 'message.g.dart';

/// Represents a single chat message within a chat room.
///
/// Maps to the `messages` table. Delivered in real-time via
/// Supabase Realtime subscriptions.
@freezed
abstract class Message with _$Message {
  const factory Message({
    required String id,
    required String chatRoomId,
    required String senderId,
    required String content,
    @JsonKey(name: 'message_type') @Default('text') String messageType,
    @JsonKey(name: 'image_url') String? imageUrl,
    @Default(false) bool isRead,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _Message;

  factory Message.fromJson(Map<String, dynamic> json) =>
      _$MessageFromJson(json);
}

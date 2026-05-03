// ignore_for_file: invalid_annotation_target
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:smivo/data/models/user_profile.dart';

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
    @JsonKey(name: 'chat_room_id') required String chatRoomId,
    @JsonKey(name: 'sender_id') required String senderId,
    required String content,
    @JsonKey(name: 'message_type') @Default('text') String messageType,
    @JsonKey(name: 'image_url') String? imageUrl,
    @JsonKey(name: 'is_read') @Default(false) bool isRead,
    // NOTE: is_hidden is set by admin via admin_hide_messages RPC when a
    // message is reported and resolved as violating. Hidden messages are
    // shown as a placeholder in the UI rather than deleted for audit purposes.
    @JsonKey(name: 'is_hidden') @Default(false) bool isHidden,
    @JsonKey(name: 'hidden_reason') String? hiddenReason,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    @JsonKey(name: 'updated_at') required DateTime updatedAt,
    // Nested join data
    UserProfile? sender,
  }) = _Message;

  factory Message.fromJson(Map<String, dynamic> json) =>
      _$MessageFromJson(json);
}


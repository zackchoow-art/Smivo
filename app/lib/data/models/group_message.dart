// ignore_for_file: invalid_annotation_target
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:smivo/data/models/user_profile.dart';

part 'group_message.freezed.dart';
part 'group_message.g.dart';

/// Represents a message sent in a group chat room.
///
/// Maps to the `group_messages` table. The [messageType] field drives
/// rendering: 'text' shows [content], 'image' renders [imageUrl],
/// and 'system' displays automated event notifications (e.g. member joined).
@freezed
abstract class GroupMessage with _$GroupMessage {
  const factory GroupMessage({
    required String id,
    @JsonKey(name: 'room_id') required String roomId,
    @JsonKey(name: 'sender_id') required String senderId,
    required String content,
    // NOTE: 'system' messages have senderId set to a placeholder and are
    // rendered differently in the UI (centered, dimmed text, no avatar).
    @JsonKey(name: 'message_type') @Default('text') String messageType,
    @JsonKey(name: 'image_url') String? imageUrl,
    @JsonKey(name: 'created_at') required DateTime createdAt,

    // Nested join — populated only when queried with sender join
    UserProfile? sender,
  }) = _GroupMessage;

  factory GroupMessage.fromJson(Map<String, dynamic> json) =>
      _$GroupMessageFromJson(json);
}

// ignore_for_file: invalid_annotation_target
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:smivo/data/models/user_profile.dart';

part 'group_chat_member.freezed.dart';
part 'group_chat_member.g.dart';

/// Represents a participant in a group chat room.
///
/// Maps to the `group_chat_members` table. Membership is automatically
/// managed by the carpool join/leave flow — members are added when
/// their carpool application is approved and removed when they leave.
@freezed
abstract class GroupChatMember with _$GroupChatMember {
  const factory GroupChatMember({
    required String id,
    @JsonKey(name: 'room_id') required String roomId,
    @JsonKey(name: 'user_id') required String userId,
    @JsonKey(name: 'joined_at') required DateTime joinedAt,
    // Tracks when the user last opened this group chat.
    // Messages created after this timestamp are considered unread.
    @JsonKey(name: 'last_read_at') DateTime? lastReadAt,

    // NOTE: Per-member UI preferences — each member sets these independently.
    // Mirrors is_pinned / is_archived / is_unread_override on chat_rooms.
    @JsonKey(name: 'is_pinned') @Default(false) bool isPinned,
    @JsonKey(name: 'is_archived') @Default(false) bool isArchived,
    @JsonKey(name: 'is_unread_override') @Default(false) bool isUnreadOverride,

    // Nested join — populated only when queried with user join
    UserProfile? user,
  }) = _GroupChatMember;

  factory GroupChatMember.fromJson(Map<String, dynamic> json) =>
      _$GroupChatMemberFromJson(json);
}

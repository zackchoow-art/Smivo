// ignore_for_file: invalid_annotation_target
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:smivo/data/models/group_chat_member.dart';

part 'group_chat_room.freezed.dart';
part 'group_chat_room.g.dart';

/// Represents the group chat room associated with a carpool trip.
///
/// Maps to the `group_chat_rooms` table. Each carpool trip has exactly
/// one group chat room (1:1 relationship via [tripId]). The room is
/// created automatically when a trip is published.
@freezed
abstract class GroupChatRoom with _$GroupChatRoom {
  const factory GroupChatRoom({
    required String id,
    @JsonKey(name: 'trip_id') required String tripId,
    required String name,
    @JsonKey(name: 'created_by') required String createdBy,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    @JsonKey(name: 'updated_at') required DateTime updatedAt,

    // Nested join — populated only when queried with members join
    @Default([]) List<GroupChatMember> members,
  }) = _GroupChatRoom;

  factory GroupChatRoom.fromJson(Map<String, dynamic> json) =>
      _$GroupChatRoomFromJson(json);
}

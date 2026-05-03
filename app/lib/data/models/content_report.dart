// ignore_for_file: invalid_annotation_target
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:smivo/data/models/user_profile.dart';
import 'package:smivo/data/models/listing.dart';

part 'content_report.freezed.dart';
part 'content_report.g.dart';

@freezed
abstract class ContentReport with _$ContentReport {
  const factory ContentReport({
    required String id,
    @JsonKey(name: 'reporter_id') required String reporterId,
    @JsonKey(name: 'reported_user_id') required String reportedUserId,
    @JsonKey(name: 'listing_id') String? listingId,
    @JsonKey(name: 'chat_room_id') String? chatRoomId,
    required String reason,
    required String status,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    @JsonKey(name: 'updated_at') required DateTime updatedAt,
    @JsonKey(name: 'resolution_note') String? resolutionNote,
    @JsonKey(name: 'selected_message_ids') List<String>? selectedMessageIds,
    Map<String, dynamic>? evidence,

    // NOTE: Outcome fields written by admin when resolving (migration 00072).
    // action_taken = 'warn'/'restrict' -> penalty applied to reported user.
    // action_taken = null -> dismissed or not yet resolved.
    @JsonKey(name: 'action_taken') String? actionTaken,
    // Points awarded to the reporter for a valid report.
    @JsonKey(name: 'reporter_reward_points') @Default(0) int reporterRewardPoints,

    // Joined data for display
    @JsonKey(name: 'reported_user') UserProfile? reportedUser,
    Listing? listing,
  }) = _ContentReport;

  factory ContentReport.fromJson(Map<String, dynamic> json) =>
      _$ContentReportFromJson(json);
}

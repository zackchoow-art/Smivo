// ignore_for_file: invalid_annotation_target
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:smivo/data/models/user_profile.dart';

part 'carpool_member.freezed.dart';
part 'carpool_member.g.dart';

/// Represents a member of a carpool trip.
///
/// Maps to the `carpool_members` table. The [role] field distinguishes
/// between the trip creator and regular passengers. [status] tracks
/// the approval lifecycle for manual-approval trips.
@freezed
abstract class CarpoolMember with _$CarpoolMember {
  const factory CarpoolMember({
    required String id,
    @JsonKey(name: 'trip_id') required String tripId,
    @JsonKey(name: 'user_id') required String userId,
    // NOTE: 'creator' is set when the trip creator is added as a member
    // automatically; 'member' is set for everyone who joins afterward.
    required String role,
    // NOTE: Default 'pending' supports manual approval mode.
    // Auto-approval trips immediately set this to 'approved' via DB trigger.
    @Default('pending') String status,
    @JsonKey(name: 'joined_at') DateTime? joinedAt,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    // V2 — cancellation tracking for risk assessment
    @JsonKey(name: 'cancelled_at') DateTime? cancelledAt,
    @JsonKey(name: 'cancel_lead_time_minutes') int? cancelLeadTimeMinutes,
    @JsonKey(name: 'last_acknowledged_snapshot') Map<String, dynamic>? lastAcknowledgedSnapshot,

    // Nested join — populated only when queried with user join
    UserProfile? user,
  }) = _CarpoolMember;

  factory CarpoolMember.fromJson(Map<String, dynamic> json) =>
      _$CarpoolMemberFromJson(json);
}

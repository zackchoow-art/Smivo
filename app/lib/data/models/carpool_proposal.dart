// ignore_for_file: invalid_annotation_target
import 'package:freezed_annotation/freezed_annotation.dart';

part 'carpool_proposal.freezed.dart';
part 'carpool_proposal.g.dart';

/// Represents a change proposal submitted to the group for consensus voting.
///
/// Maps to the `carpool_proposals` table. Members vote on proposals to
/// change trip details or kick a member. A proposal is resolved when
/// [currentVotes] reaches [requiredVotes] or when it [expiresAt].
@freezed
abstract class CarpoolProposal with _$CarpoolProposal {
  const factory CarpoolProposal({
    required String id,
    @JsonKey(name: 'trip_id') required String tripId,
    @JsonKey(name: 'proposer_id') required String proposerId,
    // NOTE: proposal_type drives which fields are relevant:
    //   'kick_member'       → target_user_id is required
    //   'change_time'       → old_value/new_value are ISO-8601 strings
    //   'change_departure'  → old_value/new_value are address strings
    //   'change_destination'→ old_value/new_value are address strings
    @JsonKey(name: 'proposal_type') required String proposalType,
    @JsonKey(name: 'old_value') String? oldValue,
    @JsonKey(name: 'new_value') String? newValue,
    @JsonKey(name: 'target_user_id') String? targetUserId,
    @Default('pending') String status,
    @JsonKey(name: 'required_votes') required int requiredVotes,
    @JsonKey(name: 'current_votes') @Default(0) int currentVotes,
    @JsonKey(name: 'expires_at') DateTime? expiresAt,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    @JsonKey(name: 'updated_at') required DateTime updatedAt,
  }) = _CarpoolProposal;

  factory CarpoolProposal.fromJson(Map<String, dynamic> json) =>
      _$CarpoolProposalFromJson(json);
}

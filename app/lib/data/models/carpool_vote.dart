// ignore_for_file: invalid_annotation_target
import 'package:freezed_annotation/freezed_annotation.dart';

part 'carpool_vote.freezed.dart';
part 'carpool_vote.g.dart';

/// Represents a single member's vote on a carpool proposal.
///
/// Maps to the `carpool_votes` table. The unique constraint on
/// (proposal_id, voter_id) is enforced at the database level,
/// so each member can only cast one vote per proposal.
@freezed
abstract class CarpoolVote with _$CarpoolVote {
  const factory CarpoolVote({
    required String id,
    @JsonKey(name: 'proposal_id') required String proposalId,
    @JsonKey(name: 'voter_id') required String voterId,
    // NOTE: 'approve' counts toward required_votes; 'reject' does not
    // but may trigger early proposal expiry depending on business rules.
    required String vote,
    @JsonKey(name: 'created_at') required DateTime createdAt,
  }) = _CarpoolVote;

  factory CarpoolVote.fromJson(Map<String, dynamic> json) =>
      _$CarpoolVoteFromJson(json);
}

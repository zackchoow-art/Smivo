// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'carpool_vote.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_CarpoolVote _$CarpoolVoteFromJson(Map<String, dynamic> json) => _CarpoolVote(
  id: json['id'] as String,
  proposalId: json['proposal_id'] as String,
  voterId: json['voter_id'] as String,
  vote: json['vote'] as String,
  createdAt: DateTime.parse(json['created_at'] as String),
);

Map<String, dynamic> _$CarpoolVoteToJson(_CarpoolVote instance) =>
    <String, dynamic>{
      'id': instance.id,
      'proposal_id': instance.proposalId,
      'voter_id': instance.voterId,
      'vote': instance.vote,
      'created_at': instance.createdAt.toIso8601String(),
    };

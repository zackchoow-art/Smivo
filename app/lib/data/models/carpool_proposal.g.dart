// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'carpool_proposal.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_CarpoolProposal _$CarpoolProposalFromJson(Map<String, dynamic> json) =>
    _CarpoolProposal(
      id: json['id'] as String,
      tripId: json['trip_id'] as String,
      proposerId: json['proposer_id'] as String,
      proposalType: json['proposal_type'] as String,
      oldValue: json['old_value'] as String?,
      newValue: json['new_value'] as String?,
      targetUserId: json['target_user_id'] as String?,
      status: json['status'] as String? ?? 'pending',
      requiredVotes: (json['required_votes'] as num).toInt(),
      currentVotes: (json['current_votes'] as num?)?.toInt() ?? 0,
      expiresAt:
          json['expires_at'] == null
              ? null
              : DateTime.parse(json['expires_at'] as String),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );

Map<String, dynamic> _$CarpoolProposalToJson(_CarpoolProposal instance) =>
    <String, dynamic>{
      'id': instance.id,
      'trip_id': instance.tripId,
      'proposer_id': instance.proposerId,
      'proposal_type': instance.proposalType,
      'old_value': instance.oldValue,
      'new_value': instance.newValue,
      'target_user_id': instance.targetUserId,
      'status': instance.status,
      'required_votes': instance.requiredVotes,
      'current_votes': instance.currentVotes,
      'expires_at': instance.expiresAt?.toIso8601String(),
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
    };

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'carpool_review.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_CarpoolReview _$CarpoolReviewFromJson(Map<String, dynamic> json) =>
    _CarpoolReview(
      id: json['id'] as String,
      tripId: json['trip_id'] as String,
      reviewerId: json['reviewer_id'] as String,
      revieweeId: json['reviewee_id'] as String,
      rating: (json['rating'] as num).toInt(),
      comment: json['comment'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      reviewer:
          json['reviewer'] == null
              ? null
              : UserProfile.fromJson(json['reviewer'] as Map<String, dynamic>),
      reviewee:
          json['reviewee'] == null
              ? null
              : UserProfile.fromJson(json['reviewee'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$CarpoolReviewToJson(_CarpoolReview instance) =>
    <String, dynamic>{
      'id': instance.id,
      'trip_id': instance.tripId,
      'reviewer_id': instance.reviewerId,
      'reviewee_id': instance.revieweeId,
      'rating': instance.rating,
      'comment': instance.comment,
      'created_at': instance.createdAt.toIso8601String(),
      'reviewer': instance.reviewer,
      'reviewee': instance.reviewee,
    };

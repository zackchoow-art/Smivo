// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_review.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_UserReview _$UserReviewFromJson(Map<String, dynamic> json) => _UserReview(
  id: json['id'] as String,
  orderId: json['order_id'] as String,
  reviewerId: json['reviewer_id'] as String,
  targetUserId: json['target_user_id'] as String,
  role: json['role'] as String,
  rating: (json['rating'] as num).toInt(),
  comment: json['comment'] as String?,
  createdAt: DateTime.parse(json['created_at'] as String),
  reviewer:
      json['reviewer'] == null
          ? null
          : UserProfile.fromJson(json['reviewer'] as Map<String, dynamic>),
  tags:
      (json['tags'] as List<dynamic>?)
          ?.map((e) => ReviewTag.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
);

Map<String, dynamic> _$UserReviewToJson(_UserReview instance) =>
    <String, dynamic>{
      'id': instance.id,
      'order_id': instance.orderId,
      'reviewer_id': instance.reviewerId,
      'target_user_id': instance.targetUserId,
      'role': instance.role,
      'rating': instance.rating,
      'comment': instance.comment,
      'created_at': instance.createdAt.toIso8601String(),
      'reviewer': instance.reviewer,
      'tags': instance.tags,
    };

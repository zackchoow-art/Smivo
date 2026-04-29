// ignore_for_file: invalid_annotation_target
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:smivo/data/models/user_profile.dart';
import 'package:smivo/data/models/review_tag.dart';

part 'user_review.freezed.dart';
part 'user_review.g.dart';

@freezed
abstract class UserReview with _$UserReview {
  const UserReview._();

  const factory UserReview({
    required String id,
    @JsonKey(name: 'order_id') required String orderId,
    @JsonKey(name: 'reviewer_id') required String reviewerId,
    @JsonKey(name: 'target_user_id') required String targetUserId,
    required String role, // 'buyer' or 'seller' (the role of the target user)
    required int rating,
    String? comment,
    @JsonKey(name: 'created_at') required DateTime createdAt,

    // Nested join data
    UserProfile? reviewer,
    @JsonKey(name: 'tags') @Default([]) List<ReviewTag> tags,
  }) = _UserReview;

  factory UserReview.fromJson(Map<String, dynamic> json) => _$UserReviewFromJson(json);

  factory UserReview.fromSupabase(Map<String, dynamic> json) {
    if (json['user_review_tag_links'] != null) {
      final List<dynamic> links = json['user_review_tag_links'] as List<dynamic>;
      json['tags'] = links.map((link) => link['review_tags']).toList();
    }
    return UserReview.fromJson(json);
  }
}

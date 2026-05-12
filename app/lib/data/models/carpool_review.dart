// ignore_for_file: invalid_annotation_target
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:smivo/data/models/user_profile.dart';

part 'carpool_review.freezed.dart';
part 'carpool_review.g.dart';

/// Represents a peer review submitted after a carpool trip is completed.
///
/// Maps to the `carpool_reviews` table. Each approved member can review
/// every other member once per trip. The unique constraint on
/// (trip_id, reviewer_id, reviewee_id) is enforced at the DB level.
@freezed
abstract class CarpoolReview with _$CarpoolReview {
  const factory CarpoolReview({
    required String id,
    @JsonKey(name: 'trip_id') required String tripId,
    @JsonKey(name: 'reviewer_id') required String reviewerId,
    @JsonKey(name: 'reviewee_id') required String revieweeId,
    // NOTE: DB CHECK constraint enforces rating between 1 and 5.
    required int rating,
    String? comment,
    @JsonKey(name: 'created_at') required DateTime createdAt,

    // Nested join — populated only by specific join queries
    UserProfile? reviewer,
    UserProfile? reviewee,
  }) = _CarpoolReview;

  factory CarpoolReview.fromJson(Map<String, dynamic> json) =>
      _$CarpoolReviewFromJson(json);
}

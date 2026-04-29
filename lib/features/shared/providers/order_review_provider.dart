import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:smivo/data/models/review_tag.dart';
import 'package:smivo/data/repositories/review_repository.dart';

import 'package:smivo/data/models/user_review.dart';

part 'order_review_provider.g.dart';

@riverpod
Future<UserReview?> orderReview(
  OrderReviewRef ref, {
  required String orderId,
  required String reviewerId,
}) {
  return ref
      .read(reviewRepositoryProvider)
      .getOrderReview(orderId, reviewerId);
}

@riverpod
Future<List<ReviewTag>> reviewTags(ReviewTagsRef ref, {required String role}) {
  return ref.read(reviewRepositoryProvider).fetchTags(role);
}

@riverpod
class OrderReviewActions extends _$OrderReviewActions {
  @override
  FutureOr<void> build() {}

  Future<void> submitReview({
    required String orderId,
    required String reviewerId,
    required String targetUserId,
    required String role,
    required int rating,
    String? comment,
    required List<String> tagIds,
  }) async {
    state = const AsyncLoading();
    try {
      await ref
          .read(reviewRepositoryProvider)
          .submitReview(
            orderId: orderId,
            reviewerId: reviewerId,
            targetUserId: targetUserId,
            role: role,
            rating: rating,
            comment: comment,
            tagIds: tagIds,
          );
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }
}

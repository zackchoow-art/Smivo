import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:smivo/data/models/review_tag.dart';
import 'package:smivo/data/repositories/review_repository.dart';

import 'package:smivo/data/models/user_review.dart';
import 'package:smivo/core/providers/content_filter_provider.dart';

part 'order_review_provider.g.dart';

@riverpod
Future<UserReview?> orderReview(
  Ref ref, {
  required String orderId,
  required String reviewerId,
}) {
  return ref
      .read(reviewRepositoryProvider)
      .getOrderReview(orderId, reviewerId);
}

@riverpod
Future<List<ReviewTag>> reviewTags(Ref ref, {required String role}) {
  return ref.read(reviewRepositoryProvider).fetchTags(role);
}

@Riverpod(keepAlive: true)
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
      String? finalComment = comment?.trim();
      final currentComment = finalComment;
      if (currentComment != null && currentComment.isNotEmpty) {
        final filter = ref.read(sensitiveWordsProvider).value;
        final config = ref.read(filterConfigStateProvider).value;
        
        if (filter != null && config != null) {
          final action = applyContentFilter(currentComment, filter, config);
          finalComment = action.processedText;
        }
      }

      await ref
          .read(reviewRepositoryProvider)
          .submitReview(
            orderId: orderId,
            reviewerId: reviewerId,
            targetUserId: targetUserId,
            role: role,
            rating: rating,
            comment: finalComment,
            tagIds: tagIds,
          );
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }
}

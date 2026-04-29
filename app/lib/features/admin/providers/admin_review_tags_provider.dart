import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:smivo/data/repositories/admin_repository.dart';

part 'admin_review_tags_provider.g.dart';

@riverpod
class AdminReviewTags extends _$AdminReviewTags {
  @override
  Future<List<Map<String, dynamic>>> build() async {
    return ref.watch(adminRepositoryProvider).fetchAllReviewTags();
  }

  Future<void> createTag(String name, String type) async {
    final prev = state.valueOrNull;
    try {
      await ref.read(adminRepositoryProvider).createReviewTag(name, type);
      ref.invalidateSelf();
    } catch (e) {
      if (prev != null) state = AsyncData(prev);
      rethrow;
    }
  }

  Future<void> deleteTag(String id) async {
    final prev = state.valueOrNull;
    try {
      if (prev != null) {
        state = AsyncData(prev.where((t) => t['id'] != id).toList());
      }
      await ref.read(adminRepositoryProvider).deleteReviewTag(id);
      ref.invalidateSelf();
    } catch (e) {
      if (prev != null) state = AsyncData(prev);
      rethrow;
    }
  }
}

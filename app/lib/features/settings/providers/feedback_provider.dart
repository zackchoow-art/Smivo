import 'dart:typed_data';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:smivo/data/models/user_feedback.dart';
import 'package:smivo/data/repositories/feedback_repository.dart';
import 'package:smivo/data/repositories/storage_repository.dart';
import 'package:smivo/features/auth/providers/auth_provider.dart';
import 'package:smivo/data/repositories/profile_repository.dart';
import 'package:smivo/core/providers/content_filter_provider.dart';

part 'feedback_provider.g.dart';

@riverpod
Future<DateTime?> userFeedbackBan(Ref ref) async {
  final user = ref.watch(authStateProvider).value;
  if (user == null) return null;
  return ref.watch(profileRepositoryProvider).getActiveBan(user.id, [
    'feedback_ban',
    'account_freeze',
  ]);
}

@riverpod
class MyFeedbacks extends _$MyFeedbacks {
  @override
  Future<List<UserFeedback>> build() async {
    final user = ref.watch(authStateProvider).value;
    if (user == null) return [];

    final repo = ref.watch(feedbackRepositoryProvider);
    return repo.fetchMyFeedbacks(user.id);
  }
}

@riverpod
class SubmitFeedbackAction extends _$SubmitFeedbackAction {
  @override
  AsyncValue<void> build() => const AsyncValue.data(null);
  Future<void> submit({
    required String type,
    required String title,
    required String description,
    String? screenshotUrl,
    Map<String, dynamic>? deviceInfo,
    Uint8List? imageBytes,
    String? imageFileName,
  }) async {
    state = const AsyncValue.loading();
    try {
      final user = ref.read(authStateProvider).value;
      if (user == null) {
        throw StateError('You must be logged in to submit feedback');
      }

      final repo = ref.read(feedbackRepositoryProvider);

      final todayCount = await repo.getTodayFeedbackCount(user.id);
      if (todayCount >= 5) {
        throw StateError('Daily submission limit reached');
      }

      String? finalScreenshotUrl = screenshotUrl;
      if (imageBytes != null && imageFileName != null) {
        final storageRepo = ref.read(storageRepositoryProvider);
        finalScreenshotUrl = await storageRepo.uploadFeedbackImage(
          userId: user.id,
          fileName: '${DateTime.now().millisecondsSinceEpoch}_$imageFileName',
          fileBytes: imageBytes,
        );
      }

      final filter = ref.read(sensitiveWordsProvider).value;
      final config = ref.read(filterConfigStateProvider).value;

      var finalTitle = title.trim();
      var finalDescription = description.trim();

      if (filter != null && config != null) {
        final titleAction = applyContentFilter(finalTitle, filter, config);
        final descAction = applyContentFilter(finalDescription, filter, config);
        finalTitle = titleAction.processedText;
        finalDescription = descAction.processedText;
      }

      await repo.submitFeedback(
        userId: user.id,
        type: type,
        title: finalTitle,
        description: finalDescription,
        screenshotUrl: finalScreenshotUrl,
        deviceInfo: deviceInfo,
      );

      ref.invalidate(myFeedbacksProvider);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }
}

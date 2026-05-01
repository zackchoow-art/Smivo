import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:smivo/data/models/user_feedback.dart';
import 'package:smivo/data/repositories/feedback_repository.dart';
import 'package:smivo/features/auth/providers/auth_provider.dart';

part 'feedback_provider.g.dart';

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
        throw StateError('今日提交已达上限');
      }

      await repo.submitFeedback(
        userId: user.id,
        type: type,
        title: title,
        description: description,
        screenshotUrl: screenshotUrl,
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

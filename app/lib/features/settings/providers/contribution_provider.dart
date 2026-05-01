import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:smivo/data/models/contribution_entry.dart';
import 'package:smivo/data/repositories/feedback_repository.dart';
import 'package:smivo/features/auth/providers/auth_provider.dart';

part 'contribution_provider.g.dart';

@riverpod
class MyContributions extends _$MyContributions {
  @override
  Future<List<ContributionEntry>> build() async {
    final user = ref.watch(authStateProvider).value;
    if (user == null) return [];

    final repo = ref.watch(feedbackRepositoryProvider);
    return repo.fetchMyContributions(user.id);
  }
}

int calculateLevel(int score) {
  if (score >= 500) return 5;
  if (score >= 300) return 4;
  if (score >= 150) return 3;
  if (score >= 50) return 2;
  return 1;
}

int pointsToNextLevel(int score) {
  if (score >= 500) return 0;
  if (score >= 300) return 500 - score;
  if (score >= 150) return 300 - score;
  if (score >= 50) return 150 - score;
  return 50 - score;
}

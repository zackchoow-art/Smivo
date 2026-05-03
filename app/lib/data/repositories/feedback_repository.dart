import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:smivo/core/providers/supabase_provider.dart';
import 'package:smivo/core/exceptions/app_exception.dart';
import 'package:smivo/data/models/user_feedback.dart';
import 'package:smivo/data/models/contribution_entry.dart';

part 'feedback_repository.g.dart';

class FeedbackRepository {
  final SupabaseClient _client;

  FeedbackRepository(this._client);

  Future<void> submitFeedback({
    required String userId,
    required String type,
    required String title,
    required String description,
    String? screenshotUrl,
    Map<String, dynamic>? deviceInfo,
  }) async {
    try {
      await _client.from('user_feedbacks').insert({
        'user_id': userId,
        'type': type,
        'title': title,
        'description': description,
        if (screenshotUrl != null) 'screenshot_url': screenshotUrl,
        if (deviceInfo != null) 'device_info': deviceInfo,
      });
    } on PostgrestException catch (e) {
      if (e.message.contains('row-level security policy')) {
        throw DatabaseException('Action denied. Your account may be restricted.', e);
      }
      throw DatabaseException(e.message, e);
    }
  }

  Future<List<UserFeedback>> fetchMyFeedbacks(String userId) async {
    try {
      final data = await _client
          .from('user_feedbacks')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      return data.map((json) => UserFeedback.fromJson(json)).toList();
    } on PostgrestException catch (e) {
      throw DatabaseException(e.message, e);
    }
  }

  Future<List<ContributionEntry>> fetchMyContributions(String userId) async {
    try {
      final data = await _client
          .from('contribution_ledger')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      return data.map((json) => ContributionEntry.fromJson(json)).toList();
    } on PostgrestException catch (e) {
      throw DatabaseException(e.message, e);
    }
  }

  Future<int> getTodayFeedbackCount(String userId) async {
    try {
      final todayStart = DateTime.now().copyWith(
        hour: 0, minute: 0, second: 0, millisecond: 0, microsecond: 0
      ).toUtc().toIso8601String();

      final count = await _client
          .from('user_feedbacks')
          .count(CountOption.exact)
          .eq('user_id', userId)
          .gte('created_at', todayStart);

      return count;
    } on PostgrestException catch (e) {
      throw DatabaseException(e.message, e);
    }
  }
}

@riverpod
FeedbackRepository feedbackRepository(Ref ref) {
  return FeedbackRepository(ref.watch(supabaseClientProvider));
}

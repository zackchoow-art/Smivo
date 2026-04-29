import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:smivo/core/exceptions/app_exception.dart';
import 'package:smivo/core/providers/supabase_provider.dart';
import 'package:smivo/data/models/user_review.dart';
import 'package:smivo/data/models/review_tag.dart';

part 'review_repository.g.dart';

class ReviewRepository {
  const ReviewRepository(this._client);

  final SupabaseClient _client;

  /// Fetches all review tags for a specific role ('buyer' or 'seller')
  Future<List<ReviewTag>> fetchTags(String role) async {
    try {
      final data = await _client
          .from('review_tags')
          .select()
          .inFilter('type', [role, 'general'])
          .order('created_at', ascending: true);
      return data.map((json) => ReviewTag.fromJson(json)).toList();
    } on PostgrestException catch (e) {
      throw DatabaseException(e.message, e);
    }
  }

  /// Fetches reviews for a specific user and role
  Future<List<UserReview>> fetchUserReviews(
    String targetUserId,
    String role,
  ) async {
    try {
      final data = await _client
          .from('user_reviews')
          .select('''
            *,
            reviewer:user_profiles!reviewer_id(*),
            user_review_tag_links(review_tags(*))
          ''')
          .eq('target_user_id', targetUserId)
          .eq('role', role)
          .order('created_at', ascending: false);
      return data.map((json) => UserReview.fromSupabase(json)).toList();
    } on PostgrestException catch (e) {
      throw DatabaseException(e.message, e);
    }
  }

  /// Fetches the review a user has submitted for a specific order, if any
  Future<UserReview?> getOrderReview(String orderId, String reviewerId) async {
    try {
      final data =
          await _client
              .from('user_reviews')
              .select('''
                *,
                reviewer:user_profiles!reviewer_id(*),
                user_review_tag_links(review_tags(*))
              ''')
              .eq('order_id', orderId)
              .eq('reviewer_id', reviewerId)
              .maybeSingle();
      if (data == null) return null;
      return UserReview.fromSupabase(data);
    } on PostgrestException catch (e) {
      throw DatabaseException(e.message, e);
    }
  }

  /// Submits a new review and associated tags
  Future<void> submitReview({
    required String orderId,
    required String reviewerId,
    required String targetUserId,
    required String role,
    required int rating,
    String? comment,
    required List<String> tagIds,
  }) async {
    try {
      // Create the review
      final reviewData =
          await _client
              .from('user_reviews')
              .insert({
                'order_id': orderId,
                'reviewer_id': reviewerId,
                'target_user_id': targetUserId,
                'role': role,
                'rating': rating,
                'comment': comment,
              })
              .select()
              .single();

      final reviewId = reviewData['id'];

      // Link the tags
      if (tagIds.isNotEmpty) {
        final links =
            tagIds
                .map((tagId) => {'review_id': reviewId, 'tag_id': tagId})
                .toList();

        await _client.from('user_review_tag_links').insert(links);
      }
    } on PostgrestException catch (e) {
      throw DatabaseException(e.message, e);
    }
  }
}

@riverpod
ReviewRepository reviewRepository(Ref ref) =>
    ReviewRepository(ref.watch(supabaseClientProvider));

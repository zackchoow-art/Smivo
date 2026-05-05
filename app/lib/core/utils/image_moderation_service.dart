import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Non-blocking image moderation service.
///
/// Calls the `moderate-image-google` Edge Function after an image is uploaded.
/// This is fire-and-forget — business flow is NEVER blocked or terminated.
///
/// If the image is flagged:
///   - A record is inserted into `backend_moderation_logs` for admin review.
///   - The `listing_images` row (if applicable) is updated with
///     moderation_status = 'rejected' so the UI blur widget can pick it up.
///   - For other image types (evidence, chat, feedback), the log is sufficient
///     for admin review; the app-side blur is applied via [ModerationAwareImage].
class ImageModerationService {
  const ImageModerationService(this._client);

  final SupabaseClient _client;

  /// Submits [imageUrl] for async AI moderation.
  ///
  /// Parameters:
  ///   [imageUrl]    – the public URL of the uploaded image.
  ///   [targetType]  – 'listing_image' | 'evidence' | 'chat_image' | 'feedback'
  ///   [targetId]    – ID of the related record (listing ID, order ID, etc.)
  ///   [userId]      – uploader's user ID.
  ///
  /// NOTE: This method catches ALL exceptions internally. It must never throw
  /// because it is called fire-and-forget from upload methods.
  Future<void> moderateAsync({
    required String imageUrl,
    required String targetType,
    required String targetId,
    required String userId,
  }) async {
    try {
      // Call the Google Vision edge function (non-blocking).
      final response = await _client.functions.invoke(
        'moderate-image-google',
        body: {'image_url': imageUrl},
      );

      if (response.status != 200) {
        // Quota exhausted or config error — log and bail silently.
        debugPrint(
          '[ImageModeration] Edge function returned ${response.status}: skipping.',
        );
        return;
      }

      final data = response.data as Map<String, dynamic>?;
      if (data == null) return;

      final flagged = data['flagged'] as bool? ?? false;
      final reasons = (data['reasons'] as List?)?.cast<String>() ?? [];

      // Always log the result for admin visibility.
      await _client.from('backend_moderation_logs').insert({
        'target_type': targetType,
        'target_id': targetId,
        'user_id': userId,
        'engine': 'google_vision',
        'review_mode': 'ai',
        'result': flagged ? 'fail' : 'pass',
        'action_taken': flagged ? 'image_flagged' : 'none',
        'content_snapshot': imageUrl,
        'image_details': [
          {
            'url': imageUrl,
            'flagged': flagged,
            'reasons': reasons,
            'safe_search': data['safe_search'],
          },
        ],
      });

      if (!flagged) return;

      // For listing images specifically: update moderation_status to 'rejected'
      // so the UI blur widget (which reads listing_images.moderation_status)
      // can react. Other types are handled client-side via ModerationAwareImage.
      if (targetType == 'listing_image') {
        await _client
            .from('listing_images')
            .update({
              'moderation_status': 'rejected',
              'moderation_reasons': reasons.join(', '),
            })
            .eq('image_url', imageUrl);
      }

      debugPrint(
        '[ImageModeration] Flagged ($targetType/$targetId): ${reasons.join(', ')}',
      );
    } catch (e) {
      // NOTE: Swallow all errors — moderation is advisory-only.
      // A moderation failure must never block or break the user workflow.
      debugPrint('[ImageModeration] Non-fatal moderation error: $e');
    }
  }
}

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Non-blocking image moderation service.
///
/// Calls an AI moderation Edge Function after an image is uploaded.
/// This is fire-and-forget — business flow is NEVER blocked or terminated.
///
/// Engine selection: reads `system_configs` at runtime to decide which
/// Edge Function to invoke:
///   - ai_provider = 'google' → moderate-image-google (Google Vision)
///   - ai_provider = 'openai' → moderate-image-openai (OpenAI)
///   - backend_review.enabled = false → skip entirely
///
/// If the image is flagged, a record is inserted into `backend_moderation_logs`
/// by the Edge Function. The client reads this table via [ModerationAwareImage]
/// to blur flagged images without re-fetching.
///
/// NOTE: Only listing images and order evidence photos use this service.
/// Chat images and feedback screenshots are NOT moderated client-side:
///   - Chat images: handled entirely server-side via DB trigger → moderate-content
///   - Feedback/bug screenshots: no AI moderation (internal data, not public UGC)
class ImageModerationService {
  const ImageModerationService(this._client);

  final SupabaseClient _client;

  /// Submits [imageUrl] for async AI moderation.
  ///
  /// Parameters:
  ///   [imageUrl]    – the public URL of the uploaded image.
  ///   [targetType]  – 'listing_image' | 'evidence'
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
      // Read system config to determine whether AI review is enabled
      // and which engine provider to use.
      final configs = await _client
          .from('system_configs')
          .select('config_key, config_value')
          .inFilter('config_key', [
            'backend_review.enabled',
            'ai_provider',
          ]);

      // Parse config rows into a simple key→value map.
      final configMap = <String, String>{};
      for (final row in configs as List) {
        final key = row['config_key'] as String;
        // config_value is stored as jsonb; strip surrounding quotes for strings.
        final raw = row['config_value']?.toString() ?? '';
        configMap[key] = raw.replaceAll(RegExp(r'^"|"$'), '');
      }

      // Respect the global kill-switch for backend review.
      final enabled = configMap['backend_review.enabled'];
      if (enabled == 'false' || enabled == 'False') {
        debugPrint('[ImageModeration] backend_review.enabled=false — skipping.');
        return;
      }

      // Determine which Edge Function to call based on ai_provider config.
      // Default to google_vision for backward compatibility.
      final provider = configMap['ai_provider'] ?? 'google';
      final functionName =
          provider == 'openai' ? 'moderate-image-openai' : 'moderate-image-google';

      // Call the Edge Function (non-blocking).
      final response = await _client.functions.invoke(
        functionName,
        body: {
          'image_url': imageUrl,
          'target_type': targetType,
          'target_id': targetId,
          'user_id': userId,
        },
      );

      if (response.status != 200) {
        // Quota exhausted or config error — log and bail silently.
        debugPrint(
          '[ImageModeration] Edge function $functionName returned ${response.status}: skipping.',
        );
        return;
      }

      final data = response.data as Map<String, dynamic>?;
      if (data == null) return;

      final flagged = data['flagged'] as bool? ?? false;
      if (flagged) {
        debugPrint(
          '[ImageModeration] Flagged ($targetType/$targetId) by $functionName',
        );
      }
    } catch (e) {
      // NOTE: Swallow all errors — moderation is advisory-only.
      // A moderation failure must never block or break the user workflow.
      debugPrint('[ImageModeration] Non-fatal moderation error: $e');
    }
  }
}

import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smivo/core/providers/moderation_provider.dart';

/// A drop-in Image widget that blurs its content if the URL has been
/// flagged by the AI moderation system.
///
/// Usage — replace any Image.network / CachedNetworkImage with this:
///
/// ```dart
/// ModerationAwareImage(
///   imageUrl: url,
///   width: 120,
///   height: 120,
///   fit: BoxFit.cover,
/// )
/// ```
///
/// NOTE: Blur is applied purely on the client side — the original image
/// is not deleted or replaced. The moderation log is the source of truth.
/// The user is never shown an error message; the image is simply blurred.
class ModerationAwareImage extends ConsumerWidget {
  const ModerationAwareImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.placeholder,
  });

  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;

  /// Widget shown while the image is loading.
  final Widget? placeholder;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final flaggedUrls = ref.watch(flaggedImageUrlsProvider);

    // NOTE: Check if this URL is in the local flagged set.
    // The set is populated from backend_moderation_logs at app startup
    // and updated when new flags come in during the session.
    final isFlagged = flaggedUrls.contains(imageUrl);

    final image = Image.network(
      imageUrl,
      width: width,
      height: height,
      fit: fit,
      errorBuilder:
          (context, error, stack) => Container(
            width: width,
            height: height,
            color: Colors.grey[200],
            child: const Icon(Icons.broken_image, color: Colors.grey),
          ),
      loadingBuilder: (context, child, progress) {
        if (progress == null) return child;
        return placeholder ??
            Container(
              width: width,
              height: height,
              color: Colors.grey[100],
              child: const Center(
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            );
      },
    );

    final widget = borderRadius != null
        ? ClipRRect(borderRadius: borderRadius!, child: image)
        : image;

    if (!isFlagged) return widget;

    // Apply blur overlay for flagged images.
    // NOTE: BackdropFilter is used so the blur applies over the already-loaded
    // image. A semi-transparent overlay + icon indicates the content is hidden.
    return SizedBox(
      width: width,
      height: height,
      child: Stack(
        fit: StackFit.expand,
        children: [
          widget,
          ClipRect(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
              child: Container(
                color: Colors.black.withValues(alpha: 0.3),
                child: const Center(
                  child: Icon(
                    Icons.visibility_off,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

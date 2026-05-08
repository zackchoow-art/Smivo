import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smivo/core/providers/moderation_provider.dart';

/// A drop-in image widget that enforces platform content moderation policy.
///
/// Behavior depends on the platform's [imageModerationModeProvider] setting:
///
///   **blur** (default):
///     - Loads the image but applies a heavy blur filter
///     - Overlays a semi-transparent mask with a visibility_off icon
///     - Disables the [onTap] callback so the user cannot open the full-screen viewer
///
///   **auto_reject**:
///     - Does NOT load the image at all (saves bandwidth)
///     - Shows a grey placeholder with "This image has been removed for policy violation"
///     - Disables the [onTap] callback
///
/// For non-flagged images, the widget renders normally and forwards tap events
/// to the [onTap] callback (e.g. to open a full-screen viewer).
///
/// Usage — replace any Image.network call displaying user content:
/// ```dart
/// ModerationAwareImage(
///   imageUrl: url,
///   width: 120,
///   height: 120,
///   fit: BoxFit.cover,
///   onTap: () { /* open fullscreen viewer */ },
/// )
/// ```
///
/// NOTE: The moderation check is purely client-side. The original image is not
/// deleted. The moderation log is the source of truth. On any provider error
/// (network failure, RLS denied) the image renders as if it is not flagged.
class ModerationAwareImage extends ConsumerWidget {
  const ModerationAwareImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.placeholder,
    this.onTap,
  });

  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;

  /// Widget shown while the image is loading (non-flagged path only).
  final Widget? placeholder;

  /// Tap callback forwarded when the image is NOT flagged.
  /// When the image is flagged, this callback is silently suppressed
  /// regardless of the moderation mode.
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final flaggedUrlsAsync = ref.watch(flaggedImageUrlsProvider);
    final modeAsync = ref.watch(imageModerationModeProvider);

    // NOTE: Treat the image as clean while either provider is loading or
    // errored. We never accidentally suppress a non-violating image.
    final isFlagged = flaggedUrlsAsync.when(
      data: (urls) => urls.contains(imageUrl),
      loading: () => false,
      error: (_, __) => false,
    );

    final mode = modeAsync.when(
      data: (m) => m,
      loading: () => 'blur',
      error: (_, __) => 'blur',
    );

    // ── Auto-reject mode: do not load the image at all ─────────────────────
    if (isFlagged && mode == 'auto_reject') {
      return _buildRemovedPlaceholder();
    }

    // ── Build the actual image widget ───────────────────────────────────────
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

    final clipped =
        borderRadius != null
            ? ClipRRect(borderRadius: borderRadius!, child: image)
            : image;

    // ── Not flagged: render normally with optional tap ──────────────────────
    if (!isFlagged) {
      if (onTap != null) {
        return GestureDetector(onTap: onTap, child: clipped);
      }
      return clipped;
    }

    // ── Blur mode: blur the image and show an overlay icon ─────────────────
    // NOTE: BackdropFilter applies blur over the already-rendered image.
    // The tap callback is NOT forwarded — flagged images must not be
    // viewable in the full-screen viewer.
    return SizedBox(
      width: width,
      height: height,
      child: Stack(
        fit: StackFit.expand,
        children: [
          clipped,
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

  /// Placeholder shown in auto_reject mode — no image is loaded.
  Widget _buildRemovedPlaceholder() {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: borderRadius,
      ),
      child: const Center(
        child: Padding(
          padding: EdgeInsets.all(12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.block, color: Colors.grey, size: 28),
              SizedBox(height: 8),
              Text(
                'This image has been removed for policy violation',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 12,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

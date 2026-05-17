import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:dio/dio.dart';
import 'package:gal/gal.dart';
import 'package:path_provider/path_provider.dart';
import 'package:smivo/core/providers/moderation_provider.dart';
import 'package:smivo/core/theme/theme_extensions.dart';
import 'package:smivo/shared/widgets/action_error_dialog.dart';
import 'package:smivo/shared/widgets/action_success_dialog.dart';

// NOTE: Changed from StatefulWidget to ConsumerStatefulWidget in T12 (task B)
// so that flaggedImageUrlsProvider can be watched to block viewing violating images.
class FullscreenImageViewer extends ConsumerStatefulWidget {
  const FullscreenImageViewer({
    super.key,
    required this.imageUrls,
    this.initialIndex = 0,
  });

  final List<String> imageUrls;
  final int initialIndex;

  @override
  ConsumerState<FullscreenImageViewer> createState() =>
      _FullscreenImageViewerState();
}

class _FullscreenImageViewerState extends ConsumerState<FullscreenImageViewer> {
  late PageController _pageController;
  late int _currentIndex;
  bool _isDownloading = false;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _saveImage() async {
    if (_isDownloading || widget.imageUrls.isEmpty) return;

    // NOTE: Block saving flagged images — user cannot download violating content.
    final flaggedUrls = ref.read(flaggedImageUrlsProvider).value ?? {};
    final currentUrl = widget.imageUrls[_currentIndex];
    if (flaggedUrls.containsKey(currentUrl)) {
      if (mounted) {
        showDialog(
          context: context,
          builder:
              (ctx) => const ActionErrorDialog(
                title: 'Cannot Save Image',
                message:
                    'This image cannot be saved: content policy violation.',
              ),
        );
      }
      return;
    }

    setState(() => _isDownloading = true);

    try {
      // Check and request permission
      final hasAccess = await Gal.hasAccess(toAlbum: true);
      if (!hasAccess) {
        final requestGranted = await Gal.requestAccess(toAlbum: true);
        if (!requestGranted) {
          if (mounted) {
            showDialog(
              context: context,
              builder:
                  (ctx) => const ActionErrorDialog(
                    title: 'Permission Required',
                    message: 'Cannot save without photo library access.',
                  ),
            );
          }
          return;
        }
      }

      // Download to temporary file
      final tempDir = await getTemporaryDirectory();
      final fileName =
          'smivo_image_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final savePath = '${tempDir.path}/$fileName';

      await Dio().download(currentUrl, savePath);

      // Save to gallery
      await Gal.putImage(savePath);

      if (mounted) {
        showDialog(
          context: context,
          builder:
              (ctx) => const ActionSuccessDialog(
                title: 'Image Saved',
                message: 'Image saved to gallery successfully!',
                buttonText: 'OK',
              ),
        );
      }
    } catch (e) {
      if (mounted) {
        showDialog(
          context: context,
          builder:
              (ctx) => ActionErrorDialog(
                title: 'Save Failed',
                message: 'Failed to save image: $e',
              ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isDownloading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.smivoColors;
    final typo = context.smivoTypo;
    // NOTE: Watch flaggedImageUrlsProvider so the viewer reacts if the set
    // updates while the screen is open (e.g. just-moderated image).
    final flaggedUrls = ref.watch(flaggedImageUrlsProvider).value ?? {};

    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: colors.surfaceContainerLowest),
        actions: [
          IconButton(
            icon:
                _isDownloading
                    ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: colors.surfaceContainerLowest,
                        strokeWidth: 2,
                      ),
                    )
                    : const Icon(Icons.download),
            onPressed: _saveImage,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Stack(
        children: [
          // PhotoViewGallery for swiping and zooming
          GestureDetector(
            onVerticalDragEnd: (details) {
              if (details.primaryVelocity != null &&
                  details.primaryVelocity! > 200) {
                Navigator.pop(context); // Swipe down to close
              }
            },
            child: PhotoViewGallery.builder(
              scrollPhysics: const BouncingScrollPhysics(),
              builder: (BuildContext context, int index) {
                final url = widget.imageUrls[index];
                final isFlagged = flaggedUrls.containsKey(url);

                // NOTE: If the image is flagged, show a placeholder instead of
                // the actual image. This prevents users from swiping to see
                // violating content in the full-screen gallery.
                if (isFlagged) {
                  final reasons = flaggedUrls[url];
                  final label =
                      (reasons != null && reasons.isNotEmpty)
                          ? reasons.join(', ')
                          : 'policy violation';
                  return PhotoViewGalleryPageOptions.customChild(
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.block,
                            color: colors.outlineVariant,
                            size: 48,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'This image has been restricted for: $label',
                            style: typo.bodyMedium.copyWith(
                              color: colors.outlineVariant,
                              fontSize: 14,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                    minScale: PhotoViewComputedScale.contained,
                    maxScale: PhotoViewComputedScale.contained,
                  );
                }

                return PhotoViewGalleryPageOptions(
                  imageProvider: NetworkImage(url),
                  initialScale: PhotoViewComputedScale.contained,
                  minScale: PhotoViewComputedScale.contained,
                  maxScale: PhotoViewComputedScale.covered * 2,
                  heroAttributes: PhotoViewHeroAttributes(tag: url),
                );
              },
              itemCount: widget.imageUrls.length,
              loadingBuilder:
                  (context, event) =>
                      const Center(child: CircularProgressIndicator()),
              backgroundDecoration: BoxDecoration(
                color: colors.onSurface,
              ),
              pageController: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _currentIndex = index;
                });
              },
            ),
          ),
          // Page Indicator
          if (widget.imageUrls.length > 1)
            Positioned(
              top: MediaQuery.of(context).padding.top + kToolbarHeight + 16,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: colors.onSurface.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    '${_currentIndex + 1} / ${widget.imageUrls.length}',
                    style: typo.bodyMedium.copyWith(
                      color: colors.surfaceContainerLowest,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
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

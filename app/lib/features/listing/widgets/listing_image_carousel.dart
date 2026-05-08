import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smivo/core/theme/breakpoints.dart';
import 'package:smivo/core/theme/theme_extensions.dart';
import 'package:smivo/data/models/listing_image.dart';
import 'package:smivo/shared/widgets/fullscreen_image_viewer.dart';
import 'package:smivo/shared/widgets/moderation_aware_image.dart';

class ListingImageCarousel extends ConsumerStatefulWidget {
  const ListingImageCarousel({
    super.key,
    required this.images,
    this.tagText,
    required this.isSale,
  });

  final List<ListingImage> images;
  final String? tagText;
  final bool isSale;

  @override
  ConsumerState<ListingImageCarousel> createState() =>
      _ListingImageCarouselState();
}

class _ListingImageCarouselState extends ConsumerState<ListingImageCarousel> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final hasImages = widget.images.isNotEmpty;
    final colors = context.smivoColors;
    final typo = context.smivoTypo;
    final radius = context.smivoRadius;

    // NOTE: LayoutBuilder drives responsive height — phone 4:3, tablet 16:9,
    // desktop 2:1 with a hard 500px ceiling via ConstrainedBox per task 2-2.
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final double aspectHeight;
        if (Breakpoints.isDesktop(width)) {
          // Desktop: 2:1 ratio, capped at 500px
          aspectHeight = (width / 2).clamp(0.0, 500.0);
        } else if (Breakpoints.isTablet(width)) {
          // Tablet: 16:9 ratio
          aspectHeight = width * 9 / 16;
        } else {
          // Mobile: 4:3 ratio
          aspectHeight = width * 3 / 4;
        }

        return ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: Breakpoints.isDesktop(width) ? 500 : double.infinity,
          ),
          child: SizedBox(
            height: aspectHeight,
            width: double.infinity,
            child: Stack(
              children: [
                if (hasImages)
                  PageView.builder(
                    itemCount: widget.images.length,
                    onPageChanged: (index) {
                      setState(() => _currentIndex = index);
                    },
                    itemBuilder: (context, index) {
                      final img = widget.images[index];
                      final isRejected = img.moderationStatus == 'rejected';

                      return Stack(
                        fit: StackFit.expand,
                        children: [
                          // NOTE: ModerationAwareImage handles both moderation-log
                          // blur (AI flagged) and the isRejected guard from the DB.
                          // onTap is null for rejected images to prevent navigation.
                          ModerationAwareImage(
                            imageUrl: img.imageUrl,
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: double.infinity,
                            onTap: isRejected ? null : () {
                              final validImages = widget.images
                                  .where((i) => i.moderationStatus != 'rejected')
                                  .map((i) => i.imageUrl)
                                  .toList();
                              final validIndex = validImages.indexOf(img.imageUrl);
                              if (validIndex != -1) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    fullscreenDialog: true,
                                    builder: (_) => FullscreenImageViewer(
                                      imageUrls: validImages,
                                      initialIndex: validIndex,
                                    ),
                                  ),
                                );
                              }
                            },
                          ),
                          if (isRejected)
                            Positioned.fill(
                              child: Container(
                                color: Colors.black.withValues(alpha: 0.4),
                                alignment: Alignment.center,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                ),
                                child: Text(
                                  img.moderationReasons ?? 'Policy Violation',
                                  textAlign: TextAlign.center,
                                  style: typo.titleMedium.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      );
                    },
                  )
                else
                  Container(
                    color: colors.surfaceContainerLow,
                    child: Center(
                      child: Icon(
                        Icons.image_not_supported_outlined,
                        size: 64,
                        color: colors.outlineVariant,
                      ),
                    ),
                  ),

                // Gradient for bottom text readability
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  height: 80,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [
                          colors.onSurface.withValues(alpha: 0.5),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),

                // Status Tag
                if (widget.tagText != null)
                  Positioned(
                    left: 16,
                    bottom: 16,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color:
                            widget.isSale
                                ? colors.onPrimary.withValues(alpha: 0.3)
                                : colors.onSurface.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(radius.chip),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (widget.isSale) ...[
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: colors.priceAccent,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                          ],
                          Text(
                            widget.tagText!,
                            style: typo.labelSmall.copyWith(
                              color: colors.onPrimary,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                // Pagination Dots (only if multiple images)
                if (widget.images.length > 1)
                  Positioned(
                    bottom: 16,
                    left: 0,
                    right: 0,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        widget.images.length,
                        (index) => Container(
                          width: 6,
                          height: 6,
                          margin: const EdgeInsets.symmetric(horizontal: 3),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color:
                                _currentIndex == index
                                    ? colors.primary
                                    : colors.onPrimary.withValues(alpha: 0.5),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

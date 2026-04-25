import 'package:flutter/material.dart';
import 'package:smivo/core/theme/theme_extensions.dart';

class ListingImageCarousel extends StatefulWidget {
  const ListingImageCarousel({
    super.key,
    required this.imageUrls,
    this.tagText,
    required this.isSale,
  });

  final List<String> imageUrls;
  final String? tagText;
  final bool isSale;

  @override
  State<ListingImageCarousel> createState() => _ListingImageCarouselState();
}

class _ListingImageCarouselState extends State<ListingImageCarousel> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final hasImages = widget.imageUrls.isNotEmpty;
    final colors = context.smivoColors;
    final typo = context.smivoTypo;
    final radius = context.smivoRadius;

    return SizedBox(
      height: 350,
      width: double.infinity,
      child: Stack(
        children: [
          if (hasImages)
            PageView.builder(
              itemCount: widget.imageUrls.length,
              onPageChanged: (index) {
                setState(() => _currentIndex = index);
              },
              itemBuilder: (context, index) {
                return Image.network(
                  widget.imageUrls[index],
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
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
                  color: widget.isSale 
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
          if (widget.imageUrls.length > 1)
            Positioned(
              bottom: 16,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  widget.imageUrls.length,
                  (index) => Container(
                    width: 6,
                    height: 6,
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _currentIndex == index
                          ? colors.primary
                          : colors.onPrimary.withValues(alpha: 0.5),
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

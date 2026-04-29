import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:smivo/core/router/app_routes.dart';
import 'package:smivo/core/theme/breakpoints.dart';
import 'package:smivo/core/theme/theme_extensions.dart';
import 'package:smivo/data/models/listing.dart';
import 'package:smivo/features/home/providers/home_provider.dart';
import 'package:smivo/features/home/widgets/transaction_tag.dart';

/// IKEA-themed full-width featured card for the first 3 listings.
///
/// Layout: vertical stack — large product image on top, info section
/// below with title, pickup location, price, and a forward arrow.
/// Condition badge overlays the top-left corner of the image.
///
/// NOTE: This is intentionally separate from [FeaturedListingCard]
/// because the visual structure differs too much to share a single
/// build tree (IKEA = top-image + bottom-info vs Teal = overlay
/// gradient on full-bleed image).
class IkeaFeaturedListingCard extends StatelessWidget {
  const IkeaFeaturedListingCard({super.key, required this.listing});

  final Listing listing;

  String _priceLabel(Listing listing) {
    if (listing.transactionType.toLowerCase() == 'rental') {
      if ((listing.rentalDailyPrice ?? 0) > 0) {
        return '\$${listing.rentalDailyPrice!.toStringAsFixed(0)}/day';
      }
      if ((listing.rentalWeeklyPrice ?? 0) > 0) {
        return '\$${listing.rentalWeeklyPrice!.toStringAsFixed(0)}/week';
      }
      if ((listing.rentalMonthlyPrice ?? 0) > 0) {
        return '\$${listing.rentalMonthlyPrice!.toStringAsFixed(0)}/month';
      }
      return 'Rental';
    }
    return '\$${listing.price.toStringAsFixed(0)}';
  }

  @override
  Widget build(BuildContext context) {
    final imageUrl = listing.displayImageUrl;
    final colors = context.smivoColors;
    final typo = context.smivoTypo;
    final radius = context.smivoRadius;
    final shadows = context.smivoShadows;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = Breakpoints.isDesktop(constraints.maxWidth);

        Widget content = GestureDetector(
          onTap:
              () => context.pushNamed(
                AppRoutes.listingDetail,
                pathParameters: {'id': listing.id},
              ),
          child: Container(
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: colors.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(radius.card),
              boxShadow: shadows.card,
            ),
            clipBehavior: Clip.antiAlias,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Image section with transaction type tag ─────────
                AspectRatio(
                  aspectRatio: 4 / 3,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      // Product image
                      if (imageUrl != null)
                        Image.network(
                          imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder:
                              (_, __, ___) => _buildImageFallback(colors),
                        )
                      else
                        _buildImageFallback(colors),

                      // RENT / SALE tag — top-right corner
                      Positioned(
                        top: 12,
                        right: 12,
                        child: TransactionTag(
                          transactionType: listing.transactionType,
                        ),
                      ),
                    ],
                  ),
                ),

                // ── Info section ───────────────────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        listing.title,
                        style: typo.titleMedium.copyWith(
                          color: colors.onSurface,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      if (listing.pickupLocation != null)
                        Text(
                          listing.pickupLocation!.name,
                          style: typo.bodySmall.copyWith(
                            color: colors.onSurfaceVariant,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      const SizedBox(height: 8),
                      // Price row with arrow
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _priceLabel(listing),
                            style: typo.priceStyle.copyWith(
                              color: colors.onSurface,
                              fontSize: 18,
                            ),
                          ),
                          Icon(
                            Icons.arrow_forward,
                            size: 20,
                            color: colors.onSurfaceVariant,
                            semanticLabel: 'View listing details',
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );

        if (isDesktop) {
          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: content,
            ),
          );
        }

        return content;
      },
    );
  }

  Widget _buildImageFallback(SmivoColors colors) {
    return Container(
      color: colors.surfaceContainerLow,
      child: Center(
        child: Icon(
          Icons.image_not_supported_outlined,
          size: 48,
          color: colors.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
    );
  }
}

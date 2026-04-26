import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:smivo/core/router/app_routes.dart';
import 'package:smivo/core/theme/theme_extensions.dart';
import 'package:smivo/data/models/listing.dart';
import 'package:smivo/features/home/providers/home_provider.dart';
import 'package:smivo/features/home/widgets/transaction_tag.dart';

/// IKEA-themed grid card for listings displayed from item 4 onwards.
///
/// Layout: square-ish image with a RENT/SALE tag overlay (top-right),
/// followed by a compact info section (title + price on one line,
/// description excerpt, and pickup location with pin icon).
class IkeaGridListingCard extends StatelessWidget {
  const IkeaGridListingCard({
    super.key,
    required this.listing,
  });

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

    return GestureDetector(
      onTap: () => context.pushNamed(
        AppRoutes.listingDetail,
        pathParameters: {'id': listing.id},
      ),
      child: Container(
        decoration: BoxDecoration(
          color: colors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(radius.card),
          boxShadow: shadows.card,
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Image section with RENT/SALE tag ────────────────
            AspectRatio(
              aspectRatio: 1,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // Product image
                  if (imageUrl != null)
                    Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _buildImageFallback(
                        colors,
                      ),
                    )
                  else
                    _buildImageFallback(colors),

                  // RENT / SALE tag — top-right corner
                  Positioned(
                    top: 8,
                    right: 8,
                    child: TransactionTag(transactionType: listing.transactionType),
                  ),
                ],
              ),
            ),

            // ── Info section ───────────────────────────────────
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title + price on one line
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          listing.title,
                          style: typo.labelLarge.copyWith(
                            color: colors.onSurface,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        _priceLabel(listing),
                        style: typo.labelLarge.copyWith(
                          color: colors.onSurface,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  // Description excerpt
                  if (listing.description != null &&
                      listing.description!.isNotEmpty)
                    Text(
                      listing.description!,
                      style: typo.bodySmall.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  const SizedBox(height: 4),
                  // Pickup location with pin icon
                  if (listing.pickupLocation != null)
                    Row(
                      children: [
                        Icon(
                          Icons.location_on,
                          size: 14,
                          color: colors.onSurfaceVariant,
                          semanticLabel: 'Pickup location',
                        ),
                        const SizedBox(width: 2),
                        Expanded(
                          child: Text(
                            listing.pickupLocation!.name,
                            style: typo.bodySmall.copyWith(
                              color: colors.onSurfaceVariant,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
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
  }

  Widget _buildImageFallback(SmivoColors colors) {
    return Container(
      color: colors.surfaceContainerLow,
      child: Center(
        child: Icon(
          Icons.image_not_supported_outlined,
          size: 36,
          color: colors.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
    );
  }
}

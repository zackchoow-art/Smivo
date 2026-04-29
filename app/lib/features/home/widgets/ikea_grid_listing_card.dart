import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:smivo/core/router/app_routes.dart';
import 'package:smivo/core/theme/theme_extensions.dart';
import 'package:smivo/data/models/listing.dart';
import 'package:smivo/features/home/providers/home_provider.dart';
import 'package:smivo/features/home/widgets/transaction_tag.dart';

/// IKEA-themed grid card for listings displayed from item 4 onwards.
///
/// Layout: square-ish image inset by 8px from card edges (top/left/right),
/// RENT/SALE tag overlay on image top-right, followed by a compact info
/// section: price (right-aligned), title, description, and a spacer line.
class IkeaGridListingCard extends StatelessWidget {
  const IkeaGridListingCard({super.key, required this.listing});

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
      onTap:
          () => context.pushNamed(
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
            // ── Image section with 8px inset from top/left/right ──
            Padding(
              padding: const EdgeInsets.only(top: 8, left: 8, right: 8),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(radius.image),
                child: AspectRatio(
                  aspectRatio: 1,
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

                      // RENT / SALE tag — top-right corner of image
                      Positioned(
                        top: 6,
                        right: 6,
                        child: TransactionTag(
                          transactionType: listing.transactionType,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // ── Info section ───────────────────────────────────
            // Line 1: price (right-aligned)
            // Line 2: product name
            // Line 3: description
            // Line 4: empty spacer line
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(10, 6, 10, 4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Line 1: price — right-aligned, bold
                    Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        _priceLabel(listing),
                        style: typo.labelLarge.copyWith(
                          color: colors.onSurface,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    const SizedBox(height: 2),
                    // Line 2: product name
                    Text(
                      listing.title,
                      style: typo.labelLarge.copyWith(color: colors.onSurface),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    // Line 3: description
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
                    // Line 4: empty spacer — fills remaining vertical space
                    const Spacer(),
                  ],
                ),
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

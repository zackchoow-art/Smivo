import 'package:flutter/material.dart';
import 'package:smivo/core/theme/theme_extensions.dart';
import 'package:smivo/data/models/listing.dart';
import 'package:smivo/features/home/providers/home_provider.dart';
import 'package:smivo/features/home/widgets/transaction_tag.dart';
import 'package:go_router/go_router.dart';
import 'package:smivo/core/router/app_routes.dart';

/// Teal-theme featured listing card for the first 3 home items.
///
/// Full-bleed product image with a gradient overlay at the bottom
/// showing title, description, and price. The gradient uses the
/// theme's gradient colors for brand consistency.
class FeaturedListingCard extends StatelessWidget {
  const FeaturedListingCard({
    super.key,
    required this.listing,
  });

  final Listing listing;

  String _rentalPriceLabel(Listing listing) {
    if ((listing.rentalDailyPrice ?? 0) > 0) {
      return '\$${listing.rentalDailyPrice!.toStringAsFixed(0)}/day';
    }
    if ((listing.rentalWeeklyPrice ?? 0) > 0) {
      return '\$${listing.rentalWeeklyPrice!.toStringAsFixed(0)}/week';
    }
    if ((listing.rentalMonthlyPrice ?? 0) > 0) {
      return '\$${listing.rentalMonthlyPrice!.toStringAsFixed(0)}/month';
    }
    return 'Rental'; // fallback if no rates set (shouldn't happen)
  }

  @override
  Widget build(BuildContext context) {
    final imageUrl = listing.displayImageUrl;
    final colors = context.smivoColors;
    final typo = context.smivoTypo;
    final radius = context.smivoRadius;

    return GestureDetector(
      onTap: () => context.pushNamed(
        AppRoutes.listingDetail,
        pathParameters: {'id': listing.id},
      ),
      child: Container(
        height: 300,
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: colors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(radius.xl),
          image: imageUrl != null 
              ? DecorationImage(
                  image: NetworkImage(imageUrl),
                  fit: BoxFit.cover,
                )
              : null,
        ),
        child: Stack(
          children: [
            // Fallback for no image
            if (imageUrl == null)
              Center(
                child: Icon(
                  Icons.image_not_supported_outlined,
                  size: 48,
                  color: colors.outlineVariant.withValues(alpha: 0.5),
                ),
              ),
            
            // Transaction Tag
            Positioned(
              top: 12,
              right: 12,
              child: TransactionTag(transactionType: listing.transactionType),
            ),
            
            // Bottom Info Gradient & Text
            // NOTE: Uses the theme's gradient colors (gradientStart/End)
            // instead of a generic dark overlay, so the card bottom
            // blends with the brand palette.
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      colors.gradientStart.withValues(alpha: 0.92),
                      colors.gradientEnd.withValues(alpha: 0.6),
                      Colors.transparent,
                    ],
                    stops: const [0.0, 0.6, 1.0],
                  ),
                  borderRadius: BorderRadius.vertical(
                    bottom: Radius.circular(radius.xl),
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // NOTE: Title uses onPrimary for maximum contrast
                          // against the branded gradient background.
                          Text(
                            listing.title,
                            style: typo.titleMedium.copyWith(
                              color: colors.onPrimary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (listing.description != null)
                            Text(
                              listing.description!,
                              style: typo.bodySmall.copyWith(
                                color: colors.onPrimary
                                    .withValues(alpha: 0.7),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    // NOTE: Price uses the primary color to stand out
                    // against the gradient background.
                    Text(
                      listing.transactionType.toLowerCase() == 'rental' 
                        ? _rentalPriceLabel(listing)
                        : '\$${listing.price.toStringAsFixed(0)}',
                      style: typo.priceStyle.copyWith(color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

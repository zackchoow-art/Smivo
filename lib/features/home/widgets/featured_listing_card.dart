import 'package:flutter/material.dart';
import 'package:smivo/core/theme/app_colors.dart';
import 'package:smivo/core/theme/app_spacing.dart';
import 'package:smivo/core/theme/app_text_styles.dart';
import 'package:smivo/data/models/listing.dart';
import 'package:smivo/features/home/providers/home_provider.dart';
import 'package:smivo/features/home/widgets/transaction_tag.dart';
import 'package:go_router/go_router.dart';
import 'package:smivo/core/router/app_routes.dart';

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

    return GestureDetector(
      onTap: () => context.pushNamed(
        AppRoutes.listingDetail,
        pathParameters: {'id': listing.id},
      ),
      child: Container(
        height: 300,
        margin: const EdgeInsets.only(bottom: AppSpacing.lg),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
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
                  color: AppColors.outlineVariant.withOpacity(0.5),
                ),
              ),
            
            // Transaction Tag
            Positioned(
              top: AppSpacing.md,
              right: AppSpacing.md,
              child: TransactionTag(transactionType: listing.transactionType),
            ),
            
            // Bottom Info Gradient & Text
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Colors.black.withOpacity(0.8),
                      Colors.transparent,
                    ],
                  ),
                  borderRadius: const BorderRadius.vertical(
                    bottom: Radius.circular(AppSpacing.radiusXl),
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            listing.title,
                            style: AppTextStyles.titleMedium.copyWith(color: Colors.white),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (listing.description != null)
                            Text(
                              listing.description!,
                              style: AppTextStyles.bodySmall.copyWith(color: Colors.white70),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Text(
                      listing.transactionType.toLowerCase() == 'rental' 
                        ? _rentalPriceLabel(listing)
                        : '\$${listing.price.toStringAsFixed(0)}',
                      style: AppTextStyles.headlineMedium.copyWith(color: AppColors.priceTagSuccess),
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

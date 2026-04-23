import 'package:flutter/material.dart';
import 'package:smivo/core/theme/app_colors.dart';
import 'package:smivo/core/theme/app_spacing.dart';
import 'package:smivo/core/theme/app_text_styles.dart';
import 'package:smivo/data/models/listing.dart';
import 'package:smivo/features/home/providers/home_provider.dart';
import 'package:smivo/features/home/widgets/transaction_tag.dart';
import 'package:go_router/go_router.dart';
import 'package:smivo/core/router/app_routes.dart';

class CompactListingCard extends StatelessWidget {
  const CompactListingCard({
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
        margin: const EdgeInsets.only(bottom: AppSpacing.lg),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLow,
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                image: imageUrl != null 
                    ? DecorationImage(
                        image: NetworkImage(imageUrl),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: imageUrl == null
                  ? Center(
                      child: Icon(
                        Icons.image_not_supported_outlined,
                        size: 32,
                        color: AppColors.outlineVariant.withOpacity(0.5),
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: AppSpacing.md),
            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TransactionTag(transactionType: listing.transactionType),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    listing.title,
                    style: AppTextStyles.titleMedium,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    listing.transactionType.toLowerCase() == 'rental' 
                      ? _rentalPriceLabel(listing)
                      : '\$${listing.price.toStringAsFixed(0)}',
                    style: AppTextStyles.labelLarge.copyWith(color: AppColors.priceTagPrimary),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

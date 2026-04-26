import 'package:flutter/material.dart';
import 'package:smivo/core/theme/theme_extensions.dart';
import 'package:smivo/data/models/listing.dart';
import 'package:smivo/features/home/providers/home_provider.dart';
import 'package:smivo/features/home/widgets/transaction_tag.dart';
import 'package:go_router/go_router.dart';
import 'package:smivo/core/router/app_routes.dart';

/// Teal-theme compact listing card for items 4+ on the home feed.
///
/// Layout: thumbnail image on the left, product name and price
/// side by side on the right. Uses system theme primary color
/// for the price.
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
    final colors = context.smivoColors;
    final typo = context.smivoTypo;
    final radius = context.smivoRadius;

    final priceText = listing.transactionType.toLowerCase() == 'rental'
        ? _rentalPriceLabel(listing)
        : '\$${listing.price.toStringAsFixed(0)}';

    return GestureDetector(
      onTap: () => context.pushNamed(
        AppRoutes.listingDetail,
        pathParameters: {'id': listing.id},
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Image
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: colors.surfaceContainerLow,
                borderRadius: BorderRadius.circular(radius.image),
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
                        color: colors.outlineVariant.withValues(alpha: 0.5),
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 12),
            // NOTE: Title and price side by side on the right,
            // using system theme primary color for price.
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // NOTE: Tag placed above title per design requirement —
                  // outside the image, left-aligned in the info column.
                  TransactionTag(transactionType: listing.transactionType),
                  const SizedBox(height: 4),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          listing.title,
                          style: typo.titleMedium.copyWith(
                            color: colors.onSurface,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        priceText,
                        style: typo.titleMedium.copyWith(
                          color: colors.primary,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                  if (listing.description != null && listing.description!.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      listing.description!,
                      style: typo.bodySmall.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

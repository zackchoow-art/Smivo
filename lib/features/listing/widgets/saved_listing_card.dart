import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:smivo/core/theme/theme_extensions.dart';
import 'package:go_router/go_router.dart';
import 'package:smivo/core/router/app_routes.dart';
import 'package:smivo/data/models/saved_listing.dart';

/// A Teal-themed list card for displaying a saved listing.
class SavedListingCard extends StatelessWidget {
  const SavedListingCard({super.key, required this.savedListing});
  final SavedListing savedListing;

  @override
  Widget build(BuildContext context) {
    final listing = savedListing.listing;
    final imageUrl = listing?.images.firstOrNull?.imageUrl;
    final title = listing?.title ?? 'Untitled Listing';
    final status = listing?.status ?? 'inactive';
    final price = listing != null ? '\$${listing.price.toStringAsFixed(0)}' : '';
    
    final colors = context.smivoColors;
    final typo = context.smivoTypo;
    final radius = context.smivoRadius;

    final dateStr = DateFormat('MMM d, yyyy').format(savedListing.createdAt);

    return InkWell(
      onTap: () => context.pushNamed(
        AppRoutes.listingDetail, 
        pathParameters: {'id': savedListing.listingId},
      ),
      borderRadius: BorderRadius.circular(radius.card),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: colors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(radius.card),
          boxShadow: [
            BoxShadow(
              color: colors.shadow, 
              blurRadius: 10, 
              offset: const Offset(0, 4)
            )
          ],
        ),
        child: Row(
          children: [
            _buildImage(imageUrl, colors, radius),
            const SizedBox(width: 12),
            Expanded(child: _buildDetails(title, price, status, dateStr, colors, typo)),
            const SizedBox(width: 8),
            Icon(Icons.chevron_right, color: colors.outlineVariant),
          ],
        ),
      ),
    );
  }

  Widget _buildImage(String? imageUrl, SmivoColors colors, SmivoRadius radius) {
    if (imageUrl != null && imageUrl.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(radius.sm),
        child: Image.network(imageUrl, width: 60, height: 60, fit: BoxFit.cover),
      );
    }
    return Container(
      width: 60, 
      height: 60,
      decoration: BoxDecoration(
        color: colors.surfaceContainerLow, 
        borderRadius: BorderRadius.circular(radius.sm),
      ),
      child: Icon(Icons.image_not_supported, color: colors.outlineVariant),
    );
  }

  Widget _buildDetails(String title, String price, String status, String dateStr, SmivoColors colors, SmivoTypography typo) {
    final isAvailable = status == 'active';
    final statusText = isAvailable ? 'Available' : 'Delisted';
    final statusColor = isAvailable ? colors.success : colors.outlineVariant;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: typo.titleMedium.copyWith(height: 1.2)),
        const SizedBox(height: 4),
        Row(
          children: [
            Text(price, style: typo.labelLarge.copyWith(color: colors.primary)),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: statusColor,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                statusText,
                style: typo.labelSmall.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 10,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text('Saved on $dateStr',
          style: typo.labelSmall.copyWith(color: colors.onSurface.withValues(alpha: 0.6))),
      ],
    );
  }
}

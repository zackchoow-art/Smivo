import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:smivo/core/theme/theme_extensions.dart';
import 'package:go_router/go_router.dart';
import 'package:smivo/core/router/app_routes.dart';
import 'package:smivo/data/models/saved_listing.dart';

/// A square grid card for saved listings used in the IKEA theme.
class IkeaSavedListingCard extends StatelessWidget {
  const IkeaSavedListingCard({super.key, required this.savedListing});

  final SavedListing savedListing;

  @override
  Widget build(BuildContext context) {
    final colors = context.smivoColors;
    final typo = context.smivoTypo;
    final radius = context.smivoRadius;
    final shadows = context.smivoShadows;

    final listing = savedListing.listing;
    final imageUrl =
        listing?.images.isNotEmpty == true
            ? listing!.images.first.imageUrl
            : null;
    final title = listing?.title ?? 'Untitled Listing';
    final price =
        listing != null ? '\$${listing.price.toStringAsFixed(0)}' : '';

    final dateStr =
        'Saved ${DateFormat('M/d HH:mm').format(savedListing.createdAt)}';

    return Container(
      decoration: BoxDecoration(
        color: colors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(radius.card),
        boxShadow: shadows.card,
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap:
            () => context.pushNamed(
              AppRoutes.listingDetail,
              pathParameters: {'id': savedListing.listingId},
            ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Image Area
            Padding(
              padding: const EdgeInsets.only(top: 12, left: 12, right: 12),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(radius.image),
                child: Stack(
                  children: [
                    AspectRatio(
                      aspectRatio: 1.3,
                      child:
                          imageUrl != null
                              ? Image.network(imageUrl, fit: BoxFit.cover)
                              : Container(
                                color: colors.surfaceContainerHigh,
                                child: Icon(
                                  Icons.image,
                                  color: colors.onSurfaceVariant,
                                ),
                              ),
                    ),
                    // Status Chip
                    Positioned(
                      top: 6,
                      right: 6,
                      child: _buildStatusChip(context),
                    ),
                  ],
                ),
              ),
            ),
            // Text area
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 6, 10, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: typo.labelLarge.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        price,
                        style: typo.labelLarge.copyWith(
                          color: colors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    dateStr,
                    style: typo.labelSmall.copyWith(
                      color: colors.onSurface.withValues(alpha: 0.6),
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(BuildContext context) {
    final colors = context.smivoColors;
    final typo = context.smivoTypo;
    final radius = context.smivoRadius;

    final status = savedListing.listing?.status ?? 'inactive';
    final isAvailable = status == 'active';

    final bgColor = isAvailable ? colors.success : colors.outlineVariant;
    final textColor = Colors.white;
    final label = isAvailable ? 'Available' : 'Delisted';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(radius.full),
      ),
      child: Text(
        label,
        style: typo.labelSmall.copyWith(
          color: textColor,
          fontWeight: FontWeight.bold,
          fontSize: 9,
        ),
      ),
    );
  }
}

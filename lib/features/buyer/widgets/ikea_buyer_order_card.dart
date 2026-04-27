import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:smivo/core/theme/theme_extensions.dart';

/// A square grid card for buyer orders used in IKEA theme.
class IkeaBuyerOrderCard extends StatelessWidget {
  const IkeaBuyerOrderCard({
    super.key,
    required this.order,
    required this.sectionTitle,
    required this.hasUnread,
    required this.onTap,
  });

  final dynamic order;
  final String sectionTitle;
  final bool hasUnread;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.smivoColors;
    final typo = context.smivoTypo;
    final radius = context.smivoRadius;
    final shadows = context.smivoShadows;

    final listing = order.listing;
    final imageUrl = listing?.images.isNotEmpty == true ? listing!.images.first.imageUrl : null;
    final title = listing?.title ?? 'Order';
    final price = '\$${order.totalPrice.toStringAsFixed(0)}';
    
    final infoText = sectionTitle == 'Awaiting Delivery'
        ? (order.pickupLocation?.name ?? 'Unknown location')
        : (order.seller?.displayName ?? 'Seller');
        
    final dateStr = DateFormat('M/d HH:mm').format(order.createdAt);

    return Container(
      decoration: BoxDecoration(
        color: colors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(radius.card),
        boxShadow: shadows.card,
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Image Area — 12px gap from top/left/right card edges.
            Padding(
              padding: const EdgeInsets.only(top: 12, left: 12, right: 12),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(radius.image),
                child: Stack(
                  children: [
                    AspectRatio(
                      // NOTE: 1.3 ratio keeps image compact, leaving more room
                      // for the text section below without overflow.
                      aspectRatio: 1.3,
                      child: imageUrl != null
                          ? Image.network(imageUrl, fit: BoxFit.cover)
                          : Container(
                              color: colors.surfaceContainerHigh,
                              child: Icon(Icons.image, color: colors.onSurfaceVariant),
                            ),
                    ),
                    // Status Chip
                    Positioned(
                      top: 6,
                      right: 6,
                      child: _buildStatusChip(context),
                    ),
                    // Unread Dot
                    if (hasUnread)
                      Positioned(
                        top: 6,
                        left: 6,
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: colors.error,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 1.5),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            // NOTE: Compact text area — padding and spacing reduced to ~60%
            // of original to prevent oversized cards in the grid.
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
                          style: typo.labelLarge.copyWith(fontWeight: FontWeight.bold),
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
                  const SizedBox(height: 2),
                  Text(
                    infoText,
                    style: typo.bodySmall.copyWith(color: colors.onSurfaceVariant),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 1),
                  Text(
                    dateStr,
                    style: typo.labelSmall.copyWith(
                      color: colors.onSurface.withValues(alpha: 0.4),
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

    final (bgColor, textColor, label) = _resolveChip(colors);

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

  (Color, Color, String) _resolveChip(dynamic colors) {
    final status = order.status as String;
    final rentalStatus = order.rentalStatus as String?;

    return switch (status) {
      'pending' => (colors.statusPending, Colors.white, 'Pending'),
      'confirmed' => _confirmedChip(colors, rentalStatus),
      'completed' => (colors.success, Colors.white, 'Done'),
      'cancelled' => (colors.statusCancelled, Colors.white, 'Missed'),
      _ => (colors.outlineVariant, Colors.white, status.toUpperCase()),
    };
  }

  (Color, Color, String) _confirmedChip(dynamic colors, String? rentalStatus) {
    final deliveredByBoth = (order.deliveryConfirmedByBuyer as bool) &&
        (order.deliveryConfirmedBySeller as bool);

    if (!deliveredByBoth) {
      return (colors.statusConfirmed, Colors.white, 'Pickup');
    }

    return switch (rentalStatus) {
      'active' => (colors.success, Colors.white, 'Active'),
      'return_requested' => (colors.warning, Colors.white, 'Returning'),
      'returned' => (colors.primary, Colors.white, 'Returned'),
      'deposit_refunded' => (colors.success, Colors.white, 'Refunded'),
      _ => (colors.statusConfirmed, Colors.white, 'Active'),
    };
  }
}

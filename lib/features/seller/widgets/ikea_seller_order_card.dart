import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:smivo/core/theme/theme_extensions.dart';

enum IkeaSellerCardType {
  activeListing,
  awaitingDelivery,
  activeTransaction,
  history,
}

/// A square grid card for seller center used in IKEA theme.
///
/// Supports 4 card types matching the 4 sections of SellerCenterScreen.
class IkeaSellerOrderCard extends StatelessWidget {
  const IkeaSellerOrderCard({
    super.key,
    required this.cardType,
    this.order,
    this.listing,
    this.historyItem,
    this.statusLabel,
    required this.hasUnread,
    required this.onTap,
    this.onSecondaryTap,
    // NOTE: statTaps[0]=views, [1]=saves, [2]=inquiries — for activeListing only.
    this.statTaps,
  });

  final IkeaSellerCardType cardType;
  final dynamic order;
  final dynamic listing;
  final dynamic historyItem;
  final String? statusLabel;
  final bool hasUnread;
  final VoidCallback onTap;
  final VoidCallback? onSecondaryTap;

  /// Per-tab navigation callbacks for the activeListing stat icons.
  /// Index 0 = views tab, 1 = saves tab, 2 = inquiries tab.
  final List<VoidCallback>? statTaps;

  @override
  Widget build(BuildContext context) {
    final colors = context.smivoColors;
    final radius = context.smivoRadius;
    final shadows = context.smivoShadows;

    return Container(
      decoration: BoxDecoration(
        color: colors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(radius.card),
        boxShadow: shadows.card,
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: _buildContent(context),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    return switch (cardType) {
      IkeaSellerCardType.activeListing =>
        _buildActiveListingContent(context),
      IkeaSellerCardType.awaitingDelivery =>
        _buildAwaitingDeliveryContent(context),
      IkeaSellerCardType.activeTransaction =>
        _buildActiveTransactionContent(context),
      IkeaSellerCardType.history => _buildHistoryContent(context),
    };
  }

  Widget _buildActiveListingContent(BuildContext context) {
    final colors = context.smivoColors;
    final typo = context.smivoTypo;
    final imageUrl =
        listing.images.isNotEmpty ? listing.images.first.imageUrl : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AspectRatio(
          aspectRatio: 1,
          child: imageUrl != null
              ? Image.network(imageUrl, fit: BoxFit.cover)
              : Container(
                  color: colors.surfaceContainerHigh,
                  child: const Icon(Icons.image),
                ),
        ),
        Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      listing.title,
                      style: typo.labelLarge
                          .copyWith(fontWeight: FontWeight.bold),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '\$${listing.price.toStringAsFixed(0)}',
                    style: typo.labelLarge.copyWith(
                      color: colors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 2),
              Text(
                listing.transactionType,
                style:
                    typo.bodySmall.copyWith(color: colors.onSurfaceVariant),
              ),
              const SizedBox(height: 8),
              // NOTE: Each stat icon navigates to its own TransactionManagement tab.
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildStatIcon(
                    context,
                    Icons.visibility_outlined,
                    '${listing.viewCount}',
                    statTaps != null && statTaps!.isNotEmpty
                        ? statTaps![0]
                        : null,
                  ),
                  _buildStatIcon(
                    context,
                    Icons.bookmark_outline,
                    '${listing.saveCount}',
                    statTaps != null && statTaps!.length > 1
                        ? statTaps![1]
                        : null,
                  ),
                  _buildStatIcon(
                    context,
                    Icons.local_offer_outlined,
                    '${listing.inquiryCount}',
                    statTaps != null && statTaps!.length > 2
                        ? statTaps![2]
                        : null,
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAwaitingDeliveryContent(BuildContext context) {
    final colors = context.smivoColors;
    final typo = context.smivoTypo;
    final radius = context.smivoRadius;
    final listingData = order.listing;
    final imageUrl = listingData?.images.isNotEmpty == true
        ? listingData!.images.first.imageUrl
        : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Stack(
          children: [
            AspectRatio(
              aspectRatio: 1,
              child: imageUrl != null
                  ? Image.network(imageUrl, fit: BoxFit.cover)
                  : Container(
                      color: colors.surfaceContainerHigh,
                      child: const Icon(Icons.image),
                    ),
            ),
            if (hasUnread)
              Positioned(
                top: 8,
                left: 8,
                child: _buildUnreadDot(context),
              ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      listingData?.title ?? 'Order',
                      style: typo.labelLarge
                          .copyWith(fontWeight: FontWeight.bold),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '\$${order.totalPrice.toStringAsFixed(0)}',
                    style: typo.labelLarge.copyWith(
                      color: colors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                order.pickupLocation?.name ?? 'Unknown location',
                style:
                    typo.bodySmall.copyWith(color: colors.onSurfaceVariant),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: colors.primary,
                  borderRadius: BorderRadius.circular(radius.full),
                ),
                child: Text(
                  'Awaiting Delivery',
                  style: typo.labelSmall.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 9,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActiveTransactionContent(BuildContext context) {
    final colors = context.smivoColors;
    final typo = context.smivoTypo;
    final radius = context.smivoRadius;
    final buyer = order.buyer;
    final listingTitle = order.listing?.title ?? 'Transaction';
    final dateStr =
        DateFormat('M/d HH:mm').format(order.updatedAt.toLocal());

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // NOTE: Shows buyer avatar instead of product image to identify
        // the counterparty at a glance in the active transactions grid.
        Stack(
          children: [
            AspectRatio(
              aspectRatio: 1,
              child: buyer?.avatarUrl != null &&
                      buyer!.avatarUrl!.isNotEmpty
                  ? Image.network(buyer!.avatarUrl!, fit: BoxFit.cover)
                  : Container(
                      color: colors.surfaceContainerHigh,
                      child: Icon(
                        Icons.person,
                        color: colors.onSurface.withValues(alpha: 0.3),
                        size: 48,
                      ),
                    ),
            ),
            if (hasUnread)
              Positioned(
                top: 8,
                left: 8,
                child: _buildUnreadDot(context),
              ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                listingTitle,
                style: typo.labelLarge
                    .copyWith(fontWeight: FontWeight.bold),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                '\$${order.totalPrice.toStringAsFixed(0)} · '
                '${buyer?.displayName ?? 'Buyer'}',
                style:
                    typo.bodySmall.copyWith(color: colors.onSurfaceVariant),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: colors.primary,
                      borderRadius: BorderRadius.circular(radius.full),
                    ),
                    child: Text(
                      statusLabel ?? '',
                      style: typo.labelSmall.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 9,
                      ),
                    ),
                  ),
                  Text(
                    dateStr,
                    style: typo.labelSmall.copyWith(
                      color: colors.onSurface.withValues(alpha: 0.4),
                      fontSize: 9,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHistoryContent(BuildContext context) {
    final colors = context.smivoColors;
    final typo = context.smivoTypo;
    final radius = context.smivoRadius;
    final dateStr = DateFormat('M/d/yy').format(
      historyItem.updatedAt ?? historyItem.createdAt ?? DateTime.now(),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // NOTE: Use a wider aspect ratio for history to fit more text below.
        AspectRatio(
          aspectRatio: 1.5,
          child: historyItem.imageUrl != null
              ? Image.network(historyItem.imageUrl!, fit: BoxFit.cover)
              : Container(
                  color: colors.surfaceContainerHigh,
                  child: const Icon(Icons.image),
                ),
        ),
        Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                historyItem.title,
                style: typo.labelLarge
                    .copyWith(fontWeight: FontWeight.bold),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                historyItem.subtitle,
                style:
                    typo.bodySmall.copyWith(color: colors.onSurfaceVariant),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: historyItem.isCompleted
                          ? colors.success
                          : colors.statusCancelled,
                      borderRadius: BorderRadius.circular(radius.full),
                    ),
                    child: Text(
                      historyItem.isCompleted ? 'Done' : 'Cancelled',
                      style: typo.labelSmall.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 9,
                      ),
                    ),
                  ),
                  Text(
                    dateStr,
                    style: typo.labelSmall.copyWith(
                      color: colors.onSurface.withValues(alpha: 0.4),
                      fontSize: 9,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatIcon(
    BuildContext context,
    IconData icon,
    String value,
    VoidCallback? tapCallback,
  ) {
    final colors = context.smivoColors;
    final typo = context.smivoTypo;

    return GestureDetector(
      onTap: tapCallback,
      behavior: HitTestBehavior.opaque,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: colors.onSurfaceVariant),
          const SizedBox(width: 4),
          Text(
            value,
            style: typo.labelSmall.copyWith(color: colors.onSurfaceVariant),
          ),
        ],
      ),
    );
  }

  Widget _buildUnreadDot(BuildContext context) {
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        color: context.smivoColors.error,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 1.5),
      ),
    );
  }
}

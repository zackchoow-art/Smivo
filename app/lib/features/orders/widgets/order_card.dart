import 'package:flutter/material.dart';
import 'package:smivo/core/theme/theme_extensions.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:smivo/core/router/app_routes.dart';
import 'package:smivo/features/auth/providers/auth_provider.dart';
import 'package:smivo/data/models/order.dart';
import 'package:smivo/features/orders/widgets/transaction_snapshot_modal.dart';
import 'package:smivo/data/models/user_profile.dart';
import 'flip_card.dart';

/// Returns the other party's profile from an order's perspective.
/// If [currentUserId] is the buyer, returns the seller. Otherwise buyer.
UserProfile? orderCounterparty(Order order, String? currentUserId) {
  if (currentUserId == null) return null;
  return (order.buyerId == currentUserId) ? order.seller : order.buyer;
}

class OrderCard extends ConsumerWidget {
  final Order order;

  const OrderCard({super.key, required this.order});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authUser = ref.watch(authStateProvider).valueOrNull;
    final currentUserId = authUser?.id;

    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      // Set fixed height to ensure flip works smoothly without size jumping
      height: 380,
      child: FlipCard(
        front: _FrontSide(order: order, currentUserId: currentUserId),
        back: _BackSide(order: order, currentUserId: currentUserId),
      ),
    );
  }
}

class _FrontSide extends StatelessWidget {
  final Order order;
  final String? currentUserId;

  const _FrontSide({required this.order, this.currentUserId});

  @override
  Widget build(BuildContext context) {
    final imageUrl = order.listing?.images.firstOrNull?.imageUrl;
    final title = order.listing?.title ?? 'Untitled Listing';
    final status = order.status;
    final colors = context.smivoColors;
    final typo = context.smivoTypo;
    final radius = context.smivoRadius;

    return Container(
      decoration: BoxDecoration(
        color: colors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(radius.card),
        border: Border.all(color: colors.borderLight, width: 1),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Image Section
          Expanded(
            child: Stack(
              fit: StackFit.expand,
              children: [
                if (imageUrl != null && imageUrl.isNotEmpty)
                  Image.network(imageUrl, fit: BoxFit.cover)
                else
                  Container(color: colors.surfaceContainerLow),

                // Status Badge
                Positioned(
                  top: 12,
                  right: 12,
                  child: _StatusBadge(status: status),
                ),
              ],
            ),
          ),

          // Details Section
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: typo.titleMedium.copyWith(
                              color: colors.onSurface,
                              fontWeight: FontWeight.w700,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            order.orderType.toUpperCase(),
                            style: typo.bodySmall.copyWith(
                              color: colors.onSurface.withValues(alpha: 0.7),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      order.orderType == 'rental'
                          ? '\$${order.totalPrice.toInt()}/mo'
                          : '\$${order.totalPrice.toInt()}',
                      style: typo.titleMedium.copyWith(
                        color: colors.primary,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Divider(height: 1, color: colors.dividerColor),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _StatusIcon(status: status),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _getStatusText(status),
                        style: typo.bodyMedium.copyWith(
                          color: colors.onSurface,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'pending':
        return 'Action Needed';
      case 'confirmed':
        return 'In Progress';
      case 'completed':
        return 'Completed';
      case 'cancelled':
        return 'Cancelled';
      default:
        return status.toUpperCase();
    }
  }
}

class _BackSide extends StatelessWidget {
  final Order order;
  final String? currentUserId;

  const _BackSide({required this.order, this.currentUserId});

  @override
  Widget build(BuildContext context) {
    final title = order.listing?.title ?? 'Untitled Listing';
    final counterparty = orderCounterparty(order, currentUserId);
    final status = order.status;
    final colors = context.smivoColors;
    final typo = context.smivoTypo;
    final radius = context.smivoRadius;

    return Container(
      decoration: BoxDecoration(
        color: colors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(radius.card),
        border: Border.all(color: colors.borderLight, width: 1),
        boxShadow: [
          BoxShadow(
            color: colors.shadow,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: typo.titleMedium.copyWith(
                    color: colors.primary,
                    fontWeight: FontWeight.w700,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              _StatusBadge(status: status),
            ],
          ),
          const SizedBox(height: 24),

          // Counterparty row
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: colors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(radius.sm),
            ),
            child: Row(
              children: [
                Text(
                  'COUNTERPARTY',
                  style: typo.labelSmall.copyWith(
                    color: colors.onSurface.withValues(alpha: 0.6),
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.2,
                  ),
                ),
                const Spacer(),
                if (counterparty?.avatarUrl != null &&
                    counterparty!.avatarUrl!.isNotEmpty)
                  CircleAvatar(
                    radius: 12,
                    backgroundImage: NetworkImage(counterparty.avatarUrl!),
                  ),
                const SizedBox(width: 8),
                Text(
                  counterparty?.displayName ?? 'User',
                  style: typo.bodyMedium.copyWith(
                    color: colors.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          _buildInfoRow(
            context,
            'AMOUNT',
            order.orderType == 'rental'
                ? '\$${order.totalPrice.toInt()}/mo'
                : '\$${order.totalPrice.toInt()}',
          ),
          _buildInfoRow(
            context,
            'DATE',
            order.createdAt.toLocal().toString().split(' ')[0],
          ),
          if (order.orderType == 'rental' && order.rentalStartDate != null)
            _buildInfoRow(
              context,
              'RENTAL\nPERIOD',
              '${order.rentalStartDate.toString().split(' ')[0]} - ${order.rentalEndDate?.toString().split(' ')[0] ?? 'N/A'}',
            ),
          _buildInfoRow(context, 'STATUS', _getStatusText(status)),

          // Pickup Location row
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 100,
                  child: Text(
                    'PICKUP',
                    style: typo.labelSmall.copyWith(
                      color: colors.onSurface.withValues(alpha: 0.6),
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    order.pickupLocation?.name ?? order.school,
                    style: typo.bodyMedium.copyWith(
                      color: colors.onSurface,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.right,
                  ),
                ),
              ],
            ),
          ),

          const Spacer(),

          // Completed Orders: Show snapshot as a small link
          if (status == 'completed')
            Center(
              child: GestureDetector(
                onTap:
                    () => TransactionSnapshotModal.show(
                      context,
                      title: 'Order Snapshot',
                    ),
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: Text(
                    'View Order Snapshot',
                    style: typo.labelSmall.copyWith(
                      color: colors.primary.withValues(alpha: 0.7),
                      fontWeight: FontWeight.w500,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ),
            ),

          // Pending/Confirmed Orders: Show action button
          if (status == 'pending' || status == 'confirmed')
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  context.pushNamed(
                    AppRoutes.orderDetail,
                    pathParameters: {'id': order.id},
                  );
                },
                icon: Icon(
                  Icons.info_outline,
                  color: colors.onPrimary,
                  size: 18,
                ),
                label: Text(
                  'View Details',
                  style: typo.labelLarge.copyWith(color: colors.onPrimary),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: colors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(radius.sm),
                  ),
                ),
              ),
            ),

          const SizedBox(height: 16),
          Center(
            child: Text(
              'tap anywhere to flip back',
              style: typo.labelSmall.copyWith(
                color: colors.onSurface.withValues(alpha: 0.4),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'pending':
        return 'Action Needed';
      case 'confirmed':
        return 'In Progress';
      case 'completed':
        return 'Completed';
      case 'cancelled':
        return 'Cancelled';
      default:
        return status.toUpperCase();
    }
  }

  Widget _buildInfoRow(BuildContext context, String label, String value) {
    final colors = context.smivoColors;
    final typo = context.smivoTypo;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: typo.labelSmall.copyWith(
                color: colors.onSurface.withValues(alpha: 0.6),
                fontWeight: FontWeight.w600,
                letterSpacing: 1.2,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: typo.bodyMedium.copyWith(
                color: colors.onSurface,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final colors = context.smivoColors;
    final typo = context.smivoTypo;

    Color bgColor;
    String label;

    // NOTE: Status badge colors are intentionally kept as fixed semantic values
    // since they represent universal status semantics (green=confirmed, etc.)
    switch (status) {
      case 'confirmed':
        bgColor = colors.statusConfirmed;
        label = 'CONFIRMED';
        break;
      case 'completed':
        bgColor = colors.statusCompleted;
        label = 'COMPLETED';
        break;
      case 'pending':
        bgColor = colors.statusPending;
        label = 'PENDING';
        break;
      case 'cancelled':
        bgColor = colors.statusCancelled;
        label = 'CANCELLED';
        break;
      default:
        bgColor = colors.surfaceContainerHigh;
        label = status.toUpperCase();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: typo.labelSmall.copyWith(
          color: colors.onSurface,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.5,
          fontSize: 10,
        ),
      ),
    );
  }
}

class _StatusIcon extends StatelessWidget {
  final String status;

  const _StatusIcon({required this.status});

  @override
  Widget build(BuildContext context) {
    final colors = context.smivoColors;

    IconData iconData;
    Color color;

    switch (status) {
      case 'completed':
        iconData = Icons.check_circle_outline;
        color = colors.statusConfirmed;
        break;
      case 'pending':
      case 'confirmed':
        iconData = Icons.local_shipping_outlined;
        color = colors.statusPending;
        break;
      case 'cancelled':
        iconData = Icons.cancel_outlined;
        color = colors.statusCancelled;
        break;
      default:
        iconData = Icons.hourglass_empty;
        color = colors.onSurfaceVariant;
    }

    return Icon(iconData, size: 20, color: color);
  }
}

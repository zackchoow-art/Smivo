import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:smivo/core/theme/app_colors.dart';
import 'package:smivo/core/theme/app_text_styles.dart';
import 'package:smivo/core/router/app_routes.dart';
import 'package:smivo/features/auth/providers/auth_provider.dart';
import 'package:smivo/data/models/order.dart';
import 'package:smivo/features/orders/widgets/transaction_snapshot_modal.dart';
import 'package:smivo/features/orders/screens/orders_screen.dart'; // For orderCounterparty helper
import 'flip_card.dart';

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

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderLight, width: 1),
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
                  Image.network(
                    imageUrl,
                    fit: BoxFit.cover,
                  )
                else
                  Container(color: Colors.grey[200]),

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
                            style: AppTextStyles.titleMedium.copyWith(
                              color: const Color(0xFF2B2A51),
                              fontWeight: FontWeight.w700,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            order.orderType.toUpperCase(),
                            style: AppTextStyles.bodySmall.copyWith(
                              color: const Color(0xFF2B2A51).withOpacity(0.7),
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
                      style: AppTextStyles.titleMedium.copyWith(
                        color: const Color(0xFF013DFD),
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Divider(height: 1),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _StatusIcon(status: status),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _getStatusText(status),
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: const Color(0xFF2B2A51),
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

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderLight, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
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
                  style: AppTextStyles.titleMedium.copyWith(
                    color: const Color(0xFF013DFD),
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
              color: const Color(0xFFF2EFFF),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Text(
                  'COUNTERPARTY',
                  style: AppTextStyles.labelSmall.copyWith(
                    color: const Color(0xFF2B2A51).withOpacity(0.6),
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.2,
                  ),
                ),
                const Spacer(),
                if (counterparty?.avatarUrl != null && counterparty!.avatarUrl!.isNotEmpty)
                  CircleAvatar(
                    radius: 12,
                    backgroundImage: NetworkImage(counterparty.avatarUrl!),
                  ),
                const SizedBox(width: 8),
                Text(
                  counterparty?.displayName ?? 'User',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: const Color(0xFF2B2A51),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          _buildInfoRow('AMOUNT', order.orderType == 'rental' ? '\$${order.totalPrice.toInt()}/mo' : '\$${order.totalPrice.toInt()}'),
          _buildInfoRow('DATE', order.createdAt.toLocal().toString().split(' ')[0]),
          if (order.orderType == 'rental' && order.rentalStartDate != null)
            _buildInfoRow('RENTAL\nPERIOD', '${order.rentalStartDate.toString().split(' ')[0]} - ${order.rentalEndDate?.toString().split(' ')[0] ?? 'N/A'}'),
          _buildInfoRow('STATUS', _getStatusText(status)),

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
                    style: AppTextStyles.labelSmall.copyWith(
                      color: const Color(0xFF2B2A51).withOpacity(0.6),
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    order.pickupLocation?.name ?? order.school,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: const Color(0xFF2B2A51),
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
                onTap: () => TransactionSnapshotModal.show(
                  context, 
                  title: 'Order Snapshot',
                ),
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: Text(
                    'View Order Snapshot',
                    style: AppTextStyles.labelSmall.copyWith(
                      color: const Color(0xFF013DFD).withOpacity(0.7),
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
                icon: const Icon(Icons.info_outline, color: Colors.white, size: 18),
                label: Text(
                  'View Details',
                  style: AppTextStyles.labelLarge.copyWith(color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ),
          
          const SizedBox(height: 16),
          Center(
            child: Text(
              'tap anywhere to flip back',
              style: AppTextStyles.labelSmall.copyWith(
                color: const Color(0xFF2B2A51).withOpacity(0.4),
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

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: AppTextStyles.labelSmall.copyWith(
                color: const Color(0xFF2B2A51).withOpacity(0.6),
                fontWeight: FontWeight.w600,
                letterSpacing: 1.2,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: AppTextStyles.bodyMedium.copyWith(
                color: const Color(0xFF2B2A51),
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
    Color bgColor;
    Color textColor = const Color(0xFF2B2A51);
    String label;

    switch (status) {
      case 'confirmed':
        bgColor = const Color(0xFF00FFCC);
        label = 'CONFIRMED';
        break;
      case 'completed':
        bgColor = const Color(0xFFDCD2FE);
        label = 'COMPLETED';
        break;
      case 'pending':
        bgColor = const Color(0xFFFFBBAA);
        label = 'PENDING';
        break;
      case 'cancelled':
        bgColor = const Color(0xFFFF6666);
        label = 'CANCELLED';
        break;
      default:
        bgColor = const Color(0xFFBBDDFF);
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
        style: AppTextStyles.labelSmall.copyWith(
          color: textColor,
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
    IconData iconData;
    Color color = const Color(0xFF006067);

    switch (status) {
      case 'completed':
        iconData = Icons.check_circle_outline;
        break;
      case 'pending':
      case 'confirmed':
        iconData = Icons.local_shipping_outlined;
        color = const Color(0xFFB35900);
        break;
      case 'cancelled':
        iconData = Icons.cancel_outlined;
        color = const Color(0xFFFF6666);
        break;
      default:
        iconData = Icons.hourglass_empty;
    }

    return Icon(iconData, size: 20, color: color);
  }
}

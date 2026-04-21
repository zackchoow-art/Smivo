import 'package:flutter/material.dart';
import 'package:smivo/core/theme/app_colors.dart';
import 'package:smivo/core/theme/app_text_styles.dart';
import 'package:smivo/features/orders/providers/orders_provider.dart';
import 'package:smivo/features/orders/widgets/transaction_snapshot_modal.dart';
import 'flip_card.dart';

class OrderCard extends StatelessWidget {
  final Order order;

  const OrderCard({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      // Set fixed height to ensure flip works smoothly without size jumping
      height: 380,
      child: FlipCard(
        front: _FrontSide(order: order),
        back: _BackSide(order: order),
      ),
    );
  }
}

class _FrontSide extends StatelessWidget {
  final Order order;

  const _FrontSide({required this.order});

  @override
  Widget build(BuildContext context) {
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
                if (order.imageUrl != null && order.imageUrl!.isNotEmpty)
                  Image.network(
                    order.imageUrl!,
                    fit: BoxFit.cover,
                  )
                else
                  Container(color: Colors.grey[200]),

                // Status Badge
                Positioned(
                  top: 12,
                  right: 12,
                  child: _StatusBadge(statusType: order.statusType),
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
                            order.title,
                            style: AppTextStyles.titleMedium.copyWith(
                              color: const Color(0xFF2B2A51),
                              fontWeight: FontWeight.w700,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          if (order.subtitle != null)
                            Text(
                              order.subtitle!,
                              style: AppTextStyles.bodySmall.copyWith(
                                color: const Color(0xFF2B2A51).withOpacity(0.7),
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      order.isRental
                          ? '\$${order.amount.toInt()}/mo'
                          : '\$${order.amount.toInt()}',
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
                    _StatusIcon(statusType: order.statusType),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        order.statusText,
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
}

class _BackSide extends StatelessWidget {
  final Order order;

  const _BackSide({required this.order});

  @override
  Widget build(BuildContext context) {
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
                  order.title,
                  style: AppTextStyles.titleMedium.copyWith(
                    color: const Color(0xFF013DFD),
                    fontWeight: FontWeight.w700,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              _StatusBadge(statusType: order.statusType),
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
                if (order.counterpartyAvatarUrl.isNotEmpty)
                  CircleAvatar(
                    radius: 12,
                    backgroundImage: NetworkImage(order.counterpartyAvatarUrl),
                  ),
                const SizedBox(width: 8),
                Text(
                  order.counterpartyName,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: const Color(0xFF2B2A51),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          _buildInfoRow('AMOUNT', order.isRental ? '\$${order.amount.toInt()}/mo' : '\$${order.amount.toInt()}'),
          _buildInfoRow('DATE', order.dateText),
          if (order.rentalPeriod != null)
            _buildInfoRow('RENTAL\nPERIOD', order.rentalPeriod!),
          _buildInfoRow('STATUS', order.backStatusText ?? order.statusText),

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
                    'Smith College, Quad',
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
          if (order.statusType == OrderStatusType.completed)
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

          // Pending Orders: Show Photo Upload for evidence
          if (order.statusType == OrderStatusType.pendingDropOff || 
              order.statusType == OrderStatusType.pendingPickUp)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Camera opened. Evidence photo will be saved to this order.'),
                      backgroundColor: Color(0xFF013DFD),
                    ),
                  );
                },
                icon: const Icon(Icons.camera_alt_outlined, color: Colors.white, size: 18),
                label: Text(
                  'Upload Evidence',
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
  final OrderStatusType statusType;

  const _StatusBadge({required this.statusType});

  @override
  Widget build(BuildContext context) {
    Color bgColor;
    Color textColor = const Color(0xFF2B2A51);
    String label;

    switch (statusType) {
      case OrderStatusType.rentedOut:
        bgColor = const Color(0xFF00FFCC);
        label = 'RENTED OUT';
        break;
      case OrderStatusType.completed:
        bgColor = const Color(0xFFDCD2FE);
        label = 'COMPLETED';
        break;
      case OrderStatusType.available:
        bgColor = const Color(0xFFCCFFCC);
        label = 'AVAILABLE';
        break;
      case OrderStatusType.pendingDropOff:
        bgColor = const Color(0xFFFFBBAA);
        label = 'PENDING DROP-OFF';
        break;
      case OrderStatusType.pendingPickUp:
        bgColor = const Color(0xFFFFBBAA);
        label = 'PENDING PICK-UP';
        break;
      case OrderStatusType.cancelled:
        bgColor = const Color(0xFFFF6666);
        label = 'CANCELLED';
        break;
      case OrderStatusType.processing:
        bgColor = const Color(0xFFBBDDFF);
        label = 'PROCESSING';
        break;
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
  final OrderStatusType statusType;

  const _StatusIcon({required this.statusType});

  @override
  Widget build(BuildContext context) {
    IconData iconData;
    Color color = const Color(0xFF006067);

    switch (statusType) {
      case OrderStatusType.completed:
        iconData = Icons.check_circle_outline;
        break;
      case OrderStatusType.pendingDropOff:
      case OrderStatusType.pendingPickUp:
        iconData = Icons.local_shipping_outlined;
        color = const Color(0xFFB35900);
        break;
      case OrderStatusType.available:
      case OrderStatusType.rentedOut:
        iconData = Icons.sync;
        color = const Color(0xFF013DFD);
        break;
      case OrderStatusType.cancelled:
        iconData = Icons.cancel_outlined;
        color = const Color(0xFFFF6666);
        break;
      case OrderStatusType.processing:
        iconData = Icons.hourglass_empty;
        break;
    }

    return Icon(iconData, size: 20, color: color);
  }
}

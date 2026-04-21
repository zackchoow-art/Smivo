import 'package:flutter/material.dart';
import 'package:smivo/core/theme/app_colors.dart';
import 'package:smivo/core/theme/app_spacing.dart';
import 'package:smivo/core/theme/app_text_styles.dart';
import 'package:smivo/features/orders/providers/orders_provider.dart';
import 'package:smivo/features/orders/widgets/transaction_snapshot_modal.dart';
import 'package:smivo/features/chat/widgets/chat_popup.dart';

class ListOrderCard extends StatelessWidget {
  const ListOrderCard({super.key, required this.order});

  final Order order;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Image
          if (order.imageUrl != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
              child: Image.network(
                order.imageUrl!,
                width: 60,
                height: 60,
                fit: BoxFit.cover,
              ),
            )
          else
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLow,
                borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
              ),
              child: const Icon(Icons.image_not_supported, color: Colors.grey),
            ),
            
          const SizedBox(width: AppSpacing.md),
          
          // Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  order.title,
                  style: AppTextStyles.titleMedium.copyWith(height: 1.2),
                  // Removed maxLines to allow wrapping as requested
                ),
                const SizedBox(height: 4),
                Text(
                  '\$${order.amount.toStringAsFixed(0)} • ${order.statusText}',
                  style: AppTextStyles.labelSmall.copyWith(
                    color: AppColors.onSurface.withOpacity(0.6),
                  ),
                ),
                // Snapshot Link for completed orders
                if (order.statusType == OrderStatusType.completed)
                  GestureDetector(
                    onTap: () => TransactionSnapshotModal.show(
                      context, 
                      title: 'Order Snapshot',
                    ),
                    child: Padding(
                      padding: const EdgeInsets.only(top: 8.0),
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
              ],
            ),
          ),
          
          const SizedBox(width: AppSpacing.sm),
          
          // Action Icons
          Row(
            children: [
              if (order.statusType == OrderStatusType.pendingDropOff || 
                  order.statusType == OrderStatusType.pendingPickUp)
                IconButton(
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  icon: const Icon(Icons.camera_alt_outlined, color: AppColors.primary, size: 20),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Evidence photo tool opened')),
                    );
                  },
                )
              else if (order.statusType == OrderStatusType.completed)
                IconButton(
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  icon: const Icon(Icons.receipt_long_outlined, color: AppColors.primary, size: 20),
                  onPressed: () => TransactionSnapshotModal.show(
                    context, 
                    title: 'Order Snapshot',
                  ),
                ),
              const SizedBox(width: 12),
              IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                icon: const Icon(Icons.chat_bubble_outline, color: AppColors.primary, size: 20),
                onPressed: () => showChatPopup(context),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

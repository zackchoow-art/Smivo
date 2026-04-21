import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:smivo/core/theme/app_colors.dart';
import 'package:smivo/core/theme/app_spacing.dart';
import 'package:smivo/core/theme/app_text_styles.dart';
import 'package:smivo/core/router/app_routes.dart';
import 'package:smivo/data/models/order.dart';
import 'package:smivo/features/orders/widgets/transaction_snapshot_modal.dart';
import 'package:smivo/data/repositories/chat_repository.dart';
import 'package:smivo/features/auth/providers/auth_provider.dart';
import 'package:smivo/features/chat/widgets/chat_popup.dart';

class ListOrderCard extends ConsumerWidget {
  const ListOrderCard({super.key, required this.order});

  final Order order;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final imageUrl = order.listing?.images.firstOrNull?.imageUrl;
    final title = order.listing?.title ?? 'Untitled Listing';
    final status = order.status;

    return InkWell(
      onTap: () {
        context.pushNamed(
          AppRoutes.orderDetail,
          pathParameters: {'id': order.id},
        );
      },
      borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
      child: Container(
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
            if (imageUrl != null && imageUrl.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                child: Image.network(
                  imageUrl,
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
                    title,
                    style: AppTextStyles.titleMedium.copyWith(height: 1.2),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '\$${order.totalPrice.toStringAsFixed(0)} • ${_getStatusText(status)}',
                    style: AppTextStyles.labelSmall.copyWith(
                      color: AppColors.onSurface.withOpacity(0.6),
                    ),
                  ),
                  // Snapshot Link for completed orders
                  if (status == 'completed')
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
                if (status == 'pending' || status == 'confirmed')
                  IconButton(
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    icon: const Icon(Icons.info_outline, color: AppColors.primary, size: 20),
                    onPressed: () {
                      context.pushNamed(
                        AppRoutes.orderDetail,
                        pathParameters: {'id': order.id},
                      );
                    },
                  )
                else if (status == 'completed')
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
                  onPressed: () async {
                    final user = ref.read(authStateProvider).valueOrNull;
                    if (user == null) return;

                    final isBuyer = order.buyerId == user.id;
                    final otherProfile = isBuyer ? order.seller : order.buyer;

                    try {
                      final chatRoom = await ref
                          .read(chatRepositoryProvider)
                          .getOrCreateChatRoom(
                            listingId: order.listingId,
                            buyerId: order.buyerId,
                            sellerId: order.sellerId,
                          );

                      if (!context.mounted) return;
                      showChatPopup(
                        context,
                        chatRoomId: chatRoom.id,
                        otherUserName: otherProfile?.displayName ?? 'User',
                        otherUserAvatar: otherProfile?.avatarUrl,
                        listingTitle: order.listing?.title ?? 'Order',
                        listingPrice: order.totalPrice,
                        listingImageUrl: order.listing?.images.firstOrNull?.imageUrl,
                      );
                    } catch (e) {
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error: $e')),
                      );
                    }
                  },
                ),
              ],
            ),
          ],
        ),
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

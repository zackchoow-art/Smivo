import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:smivo/core/theme/app_colors.dart';
import 'package:smivo/core/theme/app_spacing.dart';
import 'package:smivo/core/theme/app_text_styles.dart';
import 'package:smivo/data/models/order.dart';
import 'package:smivo/features/auth/providers/auth_provider.dart';
import 'package:smivo/features/orders/providers/orders_provider.dart';

class OrderDetailScreen extends ConsumerWidget {
  const OrderDetailScreen({
    super.key,
    required this.orderId,
  });

  final String orderId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orderAsync = ref.watch(orderDetailProvider(orderId));
    final actionsState = ref.watch(orderActionsProvider);
    final currentUserId = ref.watch(authStateProvider).valueOrNull?.id;

    // Show error snackbar when action fails
    ref.listen(orderActionsProvider, (previous, next) {
      if (next.hasError && !next.isLoading) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Action failed: ${next.error}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Order Details'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: orderAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: $err')),
        data: (order) => _buildBody(
          context,
          ref,
          order,
          currentUserId,
          actionsState.isLoading,
        ),
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    WidgetRef ref,
    Order order,
    String? currentUserId,
    bool isActing,
  ) {
    final isBuyer = order.buyerId == currentUserId;
    final isSeller = order.sellerId == currentUserId;
    final counterparty = isBuyer ? order.seller : order.buyer;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Listing card
          _buildListingCard(order),
          const SizedBox(height: AppSpacing.lg),

          // Order info
          _buildInfoSection(order, counterparty?.displayName),
          const SizedBox(height: AppSpacing.lg),

          // Rental period (rental only)
          if (order.orderType == 'rental' && 
              order.rentalStartDate != null) ...[
            _buildRentalSection(order),
            const SizedBox(height: AppSpacing.lg),
          ],

          // Delivery confirmation status
          if (order.status == 'confirmed' || order.status == 'completed')
            _buildDeliveryStatus(order),

          const SizedBox(height: AppSpacing.xl),

          // Action buttons
          _buildActions(context, ref, order, isBuyer, isSeller, isActing),
        ],
      ),
    );
  }

  Widget _buildListingCard(Order order) {
    final imageUrl = order.listing?.images.firstOrNull?.imageUrl;
    final title = order.listing?.title ?? 'Untitled';

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
      ),
      child: Row(
        children: [
          if (imageUrl != null && imageUrl.isNotEmpty)
            ClipRRect(
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              child: Image.network(
                imageUrl,
                width: 80,
                height: 80,
                fit: BoxFit.cover,
              ),
            )
          else
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              ),
              child: const Icon(Icons.image_not_supported),
            ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.titleMedium,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  '\$${order.totalPrice.toStringAsFixed(2)}',
                  style: AppTextStyles.titleMedium.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection(Order order, String? counterpartyName) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Order Info', style: AppTextStyles.titleMedium),
        const SizedBox(height: AppSpacing.sm),
        _infoRow('Status', _statusText(order.status)),
        _infoRow('Type', order.orderType.toUpperCase()),
        _infoRow('Date', order.createdAt.toLocal().toString().split(' ')[0]),
        _infoRow('Counterparty', counterpartyName ?? 'Unknown'),
      ],
    );
  }

  Widget _buildRentalSection(Order order) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Rental Period', style: AppTextStyles.titleMedium),
        const SizedBox(height: AppSpacing.sm),
        _infoRow('Start', order.rentalStartDate!.toLocal().toString().split(' ')[0]),
        if (order.rentalEndDate != null)
          _infoRow('End', order.rentalEndDate!.toLocal().toString().split(' ')[0]),
        if (order.returnConfirmedAt != null)
          _infoRow('Returned', order.returnConfirmedAt!.toLocal().toString().split(' ')[0]),
      ],
    );
  }

  Widget _buildDeliveryStatus(Order order) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Delivery Confirmation', style: AppTextStyles.titleMedium),
        const SizedBox(height: AppSpacing.sm),
        _infoRow(
          'Buyer',
          order.deliveryConfirmedByBuyer ? '✓ Confirmed' : 'Waiting',
        ),
        _infoRow(
          'Seller',
          order.deliveryConfirmedBySeller ? '✓ Confirmed' : 'Waiting',
        ),
      ],
    );
  }

  Widget _buildActions(
    BuildContext context,
    WidgetRef ref,
    Order order,
    bool isBuyer,
    bool isSeller,
    bool isActing,
  ) {
    final isParticipant = isBuyer || isSeller;
    if (!isParticipant) return const SizedBox.shrink();

    switch (order.status) {
      case 'pending':
        return Column(
          children: [
            // Seller can accept; either party can cancel
            if (isSeller)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: isActing
                      ? null
                      : () async {
                          await ref
                              .read(orderActionsProvider.notifier)
                              .acceptOrder(order.id);
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: Text(
                    isActing ? 'Processing...' : 'Accept Order',
                    style:
                        AppTextStyles.titleMedium.copyWith(color: Colors.white),
                  ),
                ),
              ),
            const SizedBox(height: AppSpacing.sm),
            _buildCancelButton(context, ref, order, isActing),
          ],
        );

      case 'confirmed':
        // For SALE orders: only buyer sees a button (Confirm Pickup)
        if (order.orderType == 'sale') {
          if (isBuyer) {
            return Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: isActing
                        ? null
                        : () async {
                            await ref
                                .read(orderActionsProvider.notifier)
                                .confirmDelivery(order);
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: Text(
                      isActing ? 'Processing...' : 'Confirm Pickup',
                      style: AppTextStyles.titleMedium.copyWith(
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                _buildCancelButton(context, ref, order, isActing),
              ],
            );
          } else {
            // Seller sees status, no confirmation button, but CAN cancel
            return Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                  ),
                  child: Text(
                    'Waiting for buyer to confirm pickup',
                    style: AppTextStyles.bodyMedium,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                _buildCancelButton(context, ref, order, isActing),
              ],
            );
          }
        }

        // For RENTAL orders: keep existing dual-confirmation UI
        final myConfirmed = isBuyer
            ? order.deliveryConfirmedByBuyer
            : order.deliveryConfirmedBySeller;

        if (myConfirmed) {
          return Column(
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                ),
                child: Text(
                  'You have confirmed delivery. Waiting for the other party.',
                  style: AppTextStyles.bodyMedium,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              _buildCancelButton(context, ref, order, isActing),
            ],
          );
        }

        return Column(
          children: [
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isActing
                    ? null
                    : () async {
                        await ref
                            .read(orderActionsProvider.notifier)
                            .confirmDelivery(order);
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: Text(
                  isActing ? 'Processing...' : 'Confirm Delivery',
                  style:
                      AppTextStyles.titleMedium.copyWith(color: Colors.white),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            _buildCancelButton(context, ref, order, isActing),
          ],
        );

      case 'completed':
        return Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLow,
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          ),
          child: const Text('✓ Order completed successfully'),
        );

      case 'cancelled':
        return Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLow,
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          ),
          child: const Text('✕ Order was cancelled'),
        );

      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildCancelButton(
    BuildContext context,
    WidgetRef ref,
    Order order,
    bool isActing,
  ) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: isActing
            ? null
            : () async {
                final confirmed = await _showConfirmDialog(
                  context,
                  'Cancel Order',
                  'Are you sure you want to cancel this order?',
                );
                if (confirmed == true) {
                  await ref
                      .read(orderActionsProvider.notifier)
                      .cancelOrder(order.id);
                }
              },
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
        child: Text(
          'Cancel Order',
          style: AppTextStyles.titleMedium.copyWith(color: AppColors.error),
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.outlineVariant,
              ),
            ),
          ),
          Expanded(
            child: Text(value, style: AppTextStyles.bodyMedium),
          ),
        ],
      ),
    );
  }

  String _statusText(String status) {
    switch (status) {
      case 'pending':
        return 'Pending';
      case 'confirmed':
        return 'In Progress';
      case 'completed':
        return 'Completed';
      case 'cancelled':
        return 'Cancelled';
      default:
        return status;
    }
  }

  Future<bool?> _showConfirmDialog(
    BuildContext context,
    String title,
    String message,
  ) {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Yes'),
          ),
        ],
      ),
    );
  }
}

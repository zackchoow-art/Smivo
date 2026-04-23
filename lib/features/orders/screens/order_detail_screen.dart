import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import 'package:smivo/core/theme/app_colors.dart';
import 'package:smivo/core/theme/app_spacing.dart';
import 'package:smivo/core/theme/app_text_styles.dart';
import 'package:smivo/data/models/order.dart';
import 'package:smivo/features/auth/providers/auth_provider.dart';
import 'package:smivo/features/orders/providers/order_chat_provider.dart';
import 'package:smivo/features/orders/providers/orders_provider.dart';
import 'package:smivo/features/orders/widgets/chat_history_section.dart';
import 'package:smivo/features/orders/widgets/evidence_photo_section.dart';

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
          _buildListingCard(order),
          const SizedBox(height: AppSpacing.lg),

          _buildTimeline(order),
          const SizedBox(height: AppSpacing.lg),

          _buildFinancialSummary(order),
          const SizedBox(height: AppSpacing.lg),

          _buildInfoSection(order, counterparty?.displayName),
          const SizedBox(height: AppSpacing.lg),

          if (order.orderType == 'rental' && order.rentalStartDate != null) ...[
            _buildRentalSection(order),
            const SizedBox(height: AppSpacing.lg),
          ],

          if (order.status == 'confirmed' || order.status == 'completed')
            _buildDeliveryStatus(order),

          if (order.status == 'confirmed' || order.status == 'completed') ...[
            EvidencePhotoSection(
              orderId: order.id,
              canUpload: order.status == 'confirmed' && (isBuyer || isSeller),
            ),
            const SizedBox(height: AppSpacing.lg),
          ],

          // Chat History (collapsible)
          Builder(
            builder: (context) {
              // Find the chat room for this listing + buyer/seller pair
              final chatRoomAsync = ref.watch(
                orderChatRoomIdProvider(
                  listingId: order.listingId,
                  buyerId: order.buyerId,
                  sellerId: order.sellerId,
                ),
              );

              return chatRoomAsync.when(
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
                data: (chatRoomId) {
                  if (chatRoomId == null) return const SizedBox.shrink();
                  return Column(
                    children: [
                      ChatHistorySection(
                        chatRoomId: chatRoomId,
                        currentUserId: currentUserId ?? '',
                      ),
                      const SizedBox(height: AppSpacing.lg),
                    ],
                  );
                },
              );
            },
          ),

          _buildActions(context, ref, order, isBuyer, isSeller, isActing),

          // Rental lifecycle actions
          if (order.orderType == 'rental' && order.rentalStatus != null) ...[
            const SizedBox(height: AppSpacing.md),
            _buildRentalLifecycleActions(
                context, ref, order, isBuyer, isSeller, isActing),
          ],
        ],
      ),
    );
  }

  Widget _buildTimeline(Order order) {
    final steps = <_TimelineStep>[
      _TimelineStep(
        label: 'Order Placed',
        date: order.createdAt,
        isCompleted: true,
      ),
      _TimelineStep(
        label: 'Accepted',
        date: order.status != 'pending' && order.status != 'cancelled'
            ? order.updatedAt
            : null,
        isCompleted:
            order.status == 'confirmed' || order.status == 'completed',
      ),
      if (order.orderType == 'sale')
        _TimelineStep(
          label: 'Picked Up',
          date: order.status == 'completed' ? order.updatedAt : null,
          isCompleted: order.status == 'completed',
        ),
      if (order.orderType == 'rental') ...[
        _TimelineStep(
          label: 'Delivered',
          date: order.deliveryConfirmedByBuyer &&
                  order.deliveryConfirmedBySeller
              ? order.updatedAt
              : null,
          isCompleted: order.deliveryConfirmedByBuyer &&
              order.deliveryConfirmedBySeller,
        ),
        _TimelineStep(
          label: 'Returned',
          date: order.returnConfirmedAt,
          isCompleted: order.returnConfirmedAt != null,
        ),
      ],
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('ORDER TIMELINE',
            style: AppTextStyles.labelSmall.copyWith(
              color: AppColors.onSurface.withValues(alpha: 0.5),
              letterSpacing: 0.5,
            )),
        const SizedBox(height: AppSpacing.md),
        ...steps.asMap().entries.map((entry) {
          final index = entry.key;
          final step = entry.value;
          final isLast = index == steps.length - 1;

          return _buildTimelineRow(step, isLast);
        }),
      ],
    );
  }

  Widget _buildTimelineRow(_TimelineStep step, bool isLast) {
    final dateStr = step.date != null
        ? DateFormat('MMM d, yyyy · h:mm a').format(step.date!.toLocal())
        : '—';

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Dot + Line
          SizedBox(
            width: 32,
            child: Column(
              children: [
                Container(
                  width: 14,
                  height: 14,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: step.isCompleted
                        ? AppColors.primary
                        : AppColors.surfaceContainerHigh,
                    border: Border.all(
                      color: step.isCompleted
                          ? AppColors.primary
                          : AppColors.outlineVariant,
                      width: 2,
                    ),
                  ),
                  child: step.isCompleted
                      ? const Icon(Icons.check, size: 8, color: Colors.white)
                      : null,
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      color: step.isCompleted
                          ? AppColors.primary
                          : AppColors.surfaceContainerHigh,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // Content
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(step.label,
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontWeight: FontWeight.w600,
                        color: step.isCompleted
                            ? AppColors.onSurface
                            : AppColors.outlineVariant,
                      )),
                  if (step.date != null)
                    Text(dateStr,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.outlineVariant,
                        )),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFinancialSummary(Order order) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('FINANCIAL SUMMARY',
              style: AppTextStyles.labelSmall.copyWith(
                color: AppColors.onSurface.withValues(alpha: 0.5),
                letterSpacing: 0.5,
              )),
          const SizedBox(height: AppSpacing.md),
          _summaryRow('Type', order.orderType.toUpperCase()),
          if (order.orderType == 'rental' && order.listing != null) ...[
            if ((order.listing!.rentalDailyPrice ?? 0) > 0)
              _summaryRow('Daily Rate',
                  '\$${order.listing!.rentalDailyPrice!.toStringAsFixed(2)}'),
            if ((order.listing!.rentalWeeklyPrice ?? 0) > 0)
              _summaryRow('Weekly Rate',
                  '\$${order.listing!.rentalWeeklyPrice!.toStringAsFixed(2)}'),
            if ((order.listing!.rentalMonthlyPrice ?? 0) > 0)
              _summaryRow('Monthly Rate',
                  '\$${order.listing!.rentalMonthlyPrice!.toStringAsFixed(2)}'),
          ],
          if (order.depositAmount > 0)
            _summaryRow(
                'Deposit', '\$${order.depositAmount.toStringAsFixed(2)}'),
          const Divider(),
          _summaryRow(
            'Total',
            '\$${order.totalPrice.toStringAsFixed(2)}',
            isBold: true,
          ),
        ],
      ),
    );
  }

  Widget _summaryRow(String label, String value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTextStyles.bodyMedium),
          Text(value,
              style: AppTextStyles.bodyMedium.copyWith(
                fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
                color: isBold ? AppColors.primary : null,
              )),
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
        // NOTE: Show deposit only for rental orders with non-zero deposit
        if (order.orderType == 'rental' && order.depositAmount > 0)
          _infoRow('Deposit', '\$${order.depositAmount.toStringAsFixed(2)}'),
        if (order.pickupLocation != null)
          _infoRow('Pickup', order.pickupLocation!.name),
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

  Widget _buildRentalLifecycleActions(
    BuildContext context,
    WidgetRef ref,
    Order order,
    bool isBuyer,
    bool isSeller,
    bool isActing,
  ) {
    switch (order.rentalStatus) {
      case 'active':
        if (isBuyer) {
          return SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: isActing
                  ? null
                  : () => ref
                      .read(orderActionsProvider.notifier)
                      .requestReturn(order.id),
              icon: const Icon(Icons.assignment_return),
              label: Text(isActing ? 'Processing...' : 'Request Return'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          );
        }
        return Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: Colors.green.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          ),
          child: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.green),
              const SizedBox(width: 8),
              Text('Rental Active — Item with buyer',
                  style: AppTextStyles.bodyMedium),
            ],
          ),
        );

      case 'return_requested':
        if (isSeller) {
          return SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: isActing
                  ? null
                  : () => ref
                      .read(orderActionsProvider.notifier)
                      .confirmReturn(order.id),
              icon: const Icon(Icons.check),
              label: Text(isActing ? 'Processing...' : 'Confirm Return'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          );
        }
        return Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: Colors.orange.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          ),
          child: Row(
            children: [
              const Icon(Icons.hourglass_top, color: Colors.orange),
              const SizedBox(width: 8),
              Expanded(
                child: Text('Waiting for seller to confirm return',
                    style: AppTextStyles.bodyMedium),
              ),
            ],
          ),
        );

      case 'returned':
        if (isSeller && order.depositAmount > 0) {
          return SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: isActing
                  ? null
                  : () => ref
                      .read(orderActionsProvider.notifier)
                      .refundDeposit(order.id),
              icon: const Icon(Icons.payments),
              label: Text(isActing
                  ? 'Processing...'
                  : 'Confirm Deposit Refund (\$${order.depositAmount.toStringAsFixed(0)})'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          );
        }
        return Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: Colors.blue.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          ),
          child: Row(
            children: [
              const Icon(Icons.assignment_turned_in, color: Colors.blue),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  order.depositAmount > 0
                      ? 'Item returned — Awaiting deposit refund'
                      : 'Item returned — Transaction complete',
                  style: AppTextStyles.bodyMedium,
                ),
              ),
            ],
          ),
        );

      case 'deposit_refunded':
        return Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: Colors.green.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          ),
          child: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.green),
              const SizedBox(width: 8),
              Text('Deposit refunded — Transaction complete',
                  style: AppTextStyles.bodyMedium),
            ],
          ),
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
    // Hide cancel button if either party has confirmed delivery
    final canCancel = order.status == 'pending' ||
        (order.status == 'confirmed' &&
            !order.deliveryConfirmedByBuyer &&
            !order.deliveryConfirmedBySeller);

    if (!canCancel) return const SizedBox.shrink();

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
          foregroundColor: AppColors.error,
          side: const BorderSide(color: AppColors.error),
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
        child: Text(
          isActing ? 'Processing...' : 'Cancel Order',
          style: AppTextStyles.titleMedium,
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

class _TimelineStep {
  const _TimelineStep({
    required this.label,
    required this.isCompleted,
    this.date,
  });
  final String label;
  final DateTime? date;
  final bool isCompleted;
}

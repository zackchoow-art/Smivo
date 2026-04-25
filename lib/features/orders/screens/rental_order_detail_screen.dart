import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smivo/core/theme/theme_extensions.dart';
import 'package:smivo/data/models/order.dart';
import 'package:smivo/features/orders/providers/order_chat_provider.dart';
import 'package:smivo/features/orders/providers/orders_provider.dart';
import 'package:smivo/features/orders/widgets/chat_history_section.dart';
import 'package:smivo/features/orders/widgets/evidence_photo_section.dart';
import 'package:smivo/features/orders/widgets/order_financial_summary.dart';
import 'package:smivo/features/orders/widgets/order_header_card.dart';
import 'package:smivo/features/orders/widgets/order_info_section.dart';
import 'package:smivo/features/orders/widgets/order_timeline.dart';
import 'package:smivo/features/orders/widgets/rental_date_section.dart';
import 'package:smivo/features/orders/widgets/rental_extension_card.dart';
import 'package:smivo/features/orders/widgets/rental_reminder_settings.dart';

class RentalOrderDetailScreen extends ConsumerWidget {
  const RentalOrderDetailScreen({
    super.key,
    required this.order,
    required this.orderId,
    required this.currentUserId,
  });

  final Order order;
  final String orderId;
  final String? currentUserId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isBuyer = order.buyerId == currentUserId;
    final isSeller = order.sellerId == currentUserId;
    final actionsState = ref.watch(orderActionsProvider);
    final isActing = actionsState.isLoading;

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(orderDetailProvider(order.id));
        await ref.read(orderDetailProvider(order.id).future);
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          OrderHeaderCard(order: order),
          const SizedBox(height: 16),
          OrderTimeline(steps: _buildRentalSteps(order)),
          const SizedBox(height: 16),
          OrderFinancialSummary(order: order),
          const SizedBox(height: 16),
          OrderInfoSection(
            order: order,
            counterpartyName: isBuyer ? order.seller?.displayName : order.buyer?.displayName,
            buyer: order.buyer,
            seller: order.seller,
          ),
          const SizedBox(height: 16),
          if (order.rentalStartDate != null) ...[
            RentalDateSection(order: order),
            const SizedBox(height: 16),
          ],
          if (order.status == 'confirmed' || order.status == 'completed') ...[
            _buildDeliveryStatus(context, order),
            const SizedBox(height: 16),
            EvidencePhotoSection(
              label: 'DELIVERY EVIDENCE',
              orderId: order.id,
              canUpload: _canUploadDeliveryEvidence(order, isBuyer, isSeller),
              evidenceType: 'delivery',
            ),
            const SizedBox(height: 16),
          ],
          if (order.rentalStatus == 'active' || 
              order.rentalStatus == 'return_requested' || 
              order.rentalStatus == 'returned' || 
              order.rentalStatus == 'deposit_refunded') ...[
            EvidencePhotoSection(
              label: 'RETURN EVIDENCE',
              orderId: order.id,
              canUpload: _canUploadReturnEvidence(order, isBuyer, isSeller),
              evidenceType: 'return',
            ),
            const SizedBox(height: 16),
          ],
          if (order.rentalStatus != null) ...[
            // Rental extension section — show when rental is active or later to show history
            RentalExtensionCard(
              order: order,
              isBuyer: isBuyer,
              isSeller: isSeller,
            ),
            const SizedBox(height: 16),
          ],
          // Rental reminder settings — only for active rentals, buyer only
          if (order.rentalStatus == 'active' && isBuyer) ...[
            RentalReminderSettings(
              order: order,
              isBuyer: isBuyer,
            ),
            const SizedBox(height: 16),
          ],
          _buildChatSection(ref, order),
          _buildActions(context, ref, order, isBuyer, isSeller, isActing),
          if (order.rentalStatus != null) ...[
            const SizedBox(height: 12),
            _buildRentalLifecycleActions(context, ref, order, isBuyer, isSeller, isActing),
          ],
        ],
      ),
      ),
    );
  }

  List<TimelineStep> _buildRentalSteps(Order order) {
    // NOTE: 'missed' treated same as 'cancelled' for terminal display
    final isTerminated = order.status == 'cancelled' ||
        order.status == 'missed';
    final delivered = order.deliveryConfirmedByBuyer &&
        order.deliveryConfirmedBySeller;

    final steps = <TimelineStep>[
      TimelineStep(
        label: 'Order Placed',
        date: order.createdAt,
        isCompleted: true,
        subtitle: 'by ${order.buyer?.displayName ?? 'Buyer'}',
      ),
      TimelineStep(
        label: 'Accepted',
        date: !isTerminated && order.status != 'pending'
            ? order.updatedAt
            : null,
        isCompleted:
            order.status == 'confirmed' || order.status == 'completed',
        subtitle:
            order.status != 'pending' && !isTerminated
                ? '${order.buyer?.displayName ?? 'Buyer'}\'s offer'
                : null,
      ),
      TimelineStep(
        label: 'Delivered',
        date: delivered ? order.updatedAt : null,
        isCompleted: delivered,
        subtitle: order.pickupLocation?.name,
      ),
    ];

    // NOTE: Rental lifecycle steps added only when relevant status is reached
    if (order.rentalStatus == 'active' ||
        order.rentalStatus == 'return_requested' ||
        order.rentalStatus == 'returned' ||
        order.rentalStatus == 'deposit_refunded' ||
        order.status == 'completed') {
      steps.add(TimelineStep(
        label: 'Returned',
        date: order.returnConfirmedAt,
        isCompleted: order.returnConfirmedAt != null,
      ));
    }

    if (order.depositRefundedAt != null) {
      steps.add(TimelineStep(
        label: 'Deposit Refunded',
        date: order.depositRefundedAt,
        isCompleted: true,
      ));
    }

    if (order.status == 'completed') {
      steps.add(TimelineStep(
        label: 'Completed',
        date: order.updatedAt,
        isCompleted: true,
      ));
    }
    if (order.status == 'cancelled') {
      steps.add(TimelineStep(
        label: 'Cancelled',
        date: order.updatedAt,
        isCompleted: true,
        isCancelled: true,
      ));
    }
    if (order.status == 'missed') {
      steps.add(TimelineStep(
        label: 'Offer Missed',
        date: order.updatedAt,
        isCompleted: true,
        isCancelled: true,
        subtitle: 'Another offer was accepted',
      ));
    }

    return steps;
  }

  Widget _buildDeliveryStatus(BuildContext context, Order order) {
    final typo = context.smivoTypo;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Delivery Confirmation', style: typo.titleMedium),
        const SizedBox(height: 8),
        _infoRow(context, 'Buyer', order.deliveryConfirmedByBuyer ? '✓ Confirmed' : 'Waiting'),
        _infoRow(context, 'Seller', order.deliveryConfirmedBySeller ? '✓ Confirmed' : 'Waiting'),
      ],
    );
  }

  Widget _infoRow(BuildContext context, String label, String value) {
    final colors = context.smivoColors;
    final typo = context.smivoTypo;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: typo.bodyMedium.copyWith(color: colors.outlineVariant),
            ),
          ),
          Expanded(child: Text(value, style: typo.bodyMedium)),
        ],
      ),
    );
  }

  Widget _buildChatSection(WidgetRef ref, Order order) {
    final chatRoomAsync = ref.watch(orderChatRoomIdProvider(
      listingId: order.listingId,
      buyerId: order.buyerId,
      sellerId: order.sellerId,
    ));

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
            const SizedBox(height: 16),
          ],
        );
      },
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
    final colors = context.smivoColors;
    final typo = context.smivoTypo;
    final radius = context.smivoRadius;

    switch (order.status) {
      case 'pending':
        return Column(
          children: [
            _buildCancelButton(context, ref, order, isActing),
          ],
        );
      case 'confirmed':
        final myConfirmed = isBuyer ? order.deliveryConfirmedByBuyer : order.deliveryConfirmedBySeller;
        if (myConfirmed) {
          return Column(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: colors.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(radius.md),
                ),
                child: Text(
                  'You have confirmed delivery. Waiting for the other party.',
                  style: typo.bodyMedium,
                ),
              ),
              const SizedBox(height: 8),
              _buildCancelButton(context, ref, order, isActing),
            ],
          );
        }
        return Column(
          children: [
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 360),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: isActing
                        ? null
                        : () async => await ref
                            .read(orderActionsProvider.notifier)
                            .confirmDelivery(order),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: Text(
                      isActing ? 'Processing...' : 'Confirm Delivery',
                      style: typo.titleMedium.copyWith(color: colors.onPrimary),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            _buildCancelButton(context, ref, order, isActing),
          ],
        );
      case 'completed':
        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: colors.surfaceContainerLow,
            borderRadius: BorderRadius.circular(radius.md),
          ),
          child: const Text('✓ Order completed successfully'),
        );
      case 'cancelled':
        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: colors.surfaceContainerLow,
            borderRadius: BorderRadius.circular(radius.md),
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
    final colors = context.smivoColors;
    final typo = context.smivoTypo;
    final radius = context.smivoRadius;

    switch (order.rentalStatus) {
      case 'active':
        if (isBuyer) {
          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 360),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: isActing
                      ? null
                      : () => ref.read(orderActionsProvider.notifier).requestReturn(order.id),
                  icon: const Icon(Icons.assignment_return),
                  label: Text(isActing ? 'Processing...' : 'Request Return'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colors.warning,
                    foregroundColor: colors.onPrimary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
            ),
          );
        }
        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: colors.success.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(radius.md),
          ),
          child: Row(
            children: [
              Icon(Icons.check_circle, color: colors.success),
              const SizedBox(width: 8),
              Text('Rental Active — Item with buyer', style: typo.bodyMedium),
            ],
          ),
        );
      case 'return_requested':
        if (isSeller) {
          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 360),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: isActing
                      ? null
                      : () => ref.read(orderActionsProvider.notifier).confirmReturn(
                            order.id,
                            depositAmount: order.depositAmount,
                          ),
                  icon: const Icon(Icons.check),
                  label: Text(isActing ? 'Processing...' : 'Confirm Return'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colors.primary,
                    foregroundColor: colors.onPrimary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
            ),
          );
        }
        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: colors.warning.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(radius.md),
          ),
          child: Row(
            children: [
              Icon(Icons.hourglass_top, color: colors.warning),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Waiting for seller to confirm return',
                  style: typo.bodyMedium,
                ),
              ),
            ],
          ),
        );
      case 'returned':
        if (isSeller && order.depositAmount > 0) {
          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 360),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: isActing
                      ? null
                      : () => ref.read(orderActionsProvider.notifier).refundDeposit(order.id),
                  icon: const Icon(Icons.payments),
                  label: Text(
                    isActing
                        ? 'Processing...'
                        : 'Confirm Deposit Refund (\$${order.depositAmount.toStringAsFixed(0)})',
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colors.success,
                    foregroundColor: colors.onPrimary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
            ),
          );
        }
        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: colors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(radius.md),
          ),
          child: Row(
            children: [
              Icon(Icons.assignment_turned_in, color: colors.primary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  order.depositAmount > 0
                      ? 'Item returned — Awaiting deposit refund'
                      : 'Item returned — Transaction complete',
                  style: typo.bodyMedium,
                ),
              ),
            ],
          ),
        );
      case 'deposit_refunded':
        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: colors.success.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(radius.md),
          ),
          child: Row(
            children: [
              Icon(Icons.check_circle, color: colors.success),
              const SizedBox(width: 8),
              Text(
                'Deposit refunded — Transaction complete',
                style: typo.bodyMedium,
              ),
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
    final colors = context.smivoColors;
    final typo = context.smivoTypo;
    final canCancel = order.status == 'pending' ||
        (order.status == 'confirmed' &&
            !order.deliveryConfirmedByBuyer &&
            !order.deliveryConfirmedBySeller);
    if (!canCancel) return const SizedBox.shrink();

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 360),
        child: SizedBox(
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
              foregroundColor: colors.error,
              side: BorderSide(color: colors.error),
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: Text(isActing ? 'Processing...' : 'Cancel Order', style: typo.titleMedium),
          ),
        ),
      ),
    );
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

  bool _canUploadDeliveryEvidence(Order order, bool isBuyer, bool isSeller) {
    if (!isBuyer && !isSeller) return false;
    return order.status == 'confirmed' &&
        !(order.deliveryConfirmedByBuyer) &&
        !(order.deliveryConfirmedBySeller);
  }

  bool _canUploadReturnEvidence(Order order, bool isBuyer, bool isSeller) {
    if (!isBuyer && !isSeller) return false;
    final rs = order.rentalStatus;
    return rs == 'active' || rs == 'return_requested';
  }
}

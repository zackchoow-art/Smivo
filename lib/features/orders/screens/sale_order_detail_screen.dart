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
import 'package:smivo/shared/widgets/collapsible_section.dart';
import 'package:smivo/shared/widgets/content_width_constraint.dart';
import 'package:smivo/features/shared/widgets/order_review_form.dart';
import 'package:smivo/features/shared/widgets/submitted_review_card.dart';
import 'package:smivo/features/shared/providers/order_review_provider.dart';

class SaleOrderDetailScreen extends ConsumerWidget {
  const SaleOrderDetailScreen({
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
        child: ContentWidthConstraint(
          maxWidth: 768,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              OrderHeaderCard(order: order),
              const SizedBox(height: 16),
              // Section 1: Order Timeline — collapsible, default open
              CollapsibleSection(
                title: 'Order Timeline',
                initiallyExpanded: true,
                child: OrderTimeline(steps: _buildSaleSteps(order)),
              ),
              const SizedBox(height: 16),
              // Section 2: Item Pricing — collapsible, default closed
              CollapsibleSection(
                title: 'Item Pricing',
                initiallyExpanded: false,
                child: OrderFinancialSummary(order: order),
              ),
              const SizedBox(height: 16),
              // Section 3: Order Info — collapsible, default open
              OrderInfoSection(
                order: order,
                counterpartyName:
                    isBuyer
                        ? order.seller?.displayName
                        : order.buyer?.displayName,
                buyer: order.buyer,
                seller: order.seller,
                currentUserId: currentUserId,
              ),
              const SizedBox(height: 16),
              // Section 5: Delivery & Return — collapsible, default open
              if (order.status == 'pending' ||
                  order.status == 'confirmed' ||
                  order.status == 'completed') ...[
                CollapsibleSection(
                  title: 'Delivery & Return',
                  initiallyExpanded: true,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (order.status != 'pending') ...[
                        _buildDeliveryStatus(context, order),
                        const SizedBox(height: 16),
                        EvidencePhotoSection(
                          orderId: order.id,
                          canUpload: _canUploadEvidence(
                            order,
                            isBuyer,
                            isSeller,
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                      _buildPrimaryActions(
                        context,
                        ref,
                        order,
                        isBuyer,
                        isSeller,
                        isActing,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],
              // Section 6: Chat History — collapsible, default closed
              _buildChatSection(ref, order),
              _buildReviewSection(context, ref, order, isBuyer, currentUserId),
              _buildStatusBanner(context, order),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBanner(BuildContext context, Order order) {
    final colors = context.smivoColors;
    final typo = context.smivoTypo;
    final radius = context.smivoRadius;

    if (order.status == 'completed') {
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
              'Order completed successfully',
              style: typo.bodyMedium.copyWith(fontWeight: FontWeight.w500),
            ),
          ],
        ),
      );
    }

    if (order.status == 'cancelled') {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: colors.error.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(radius.md),
        ),
        child: Row(
          children: [
            Icon(Icons.cancel, color: colors.error),
            const SizedBox(width: 8),
            Text(
              'Order was cancelled',
              style: typo.bodyMedium.copyWith(color: colors.error),
            ),
          ],
        ),
      );
    }

    if (order.status == 'missed') {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: colors.outlineVariant.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(radius.md),
        ),
        child: Row(
          children: [
            Icon(Icons.info_outline, color: colors.outlineVariant),
            const SizedBox(width: 8),
            Text(
              'Offer missed — Another buyer was chosen',
              style: typo.bodyMedium,
            ),
          ],
        ),
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildPrimaryActions(
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

    if (order.status == 'pending') {
      return _buildCancelButton(context, ref, order, isActing);
    }

    if (order.status == 'confirmed') {
      if (isBuyer) {
        return Column(
          children: [
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 360),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed:
                        isActing
                            ? null
                            : () async => await ref
                                .read(orderActionsProvider.notifier)
                                .confirmDelivery(order),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: Text(
                      isActing ? 'Processing...' : 'Confirm Pickup',
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
      } else {
        return Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: colors.surfaceContainerLow,
                borderRadius: BorderRadius.circular(radius.md),
              ),
              child: Text(
                'Waiting for buyer to confirm pickup',
                style: typo.bodyMedium,
              ),
            ),
            const SizedBox(height: 8),
            _buildCancelButton(context, ref, order, isActing),
          ],
        );
      }
    }

    if (order.status == 'completed') {
      return const SizedBox.shrink();
    }

    return const SizedBox.shrink();
  }

  List<TimelineStep> _buildSaleSteps(Order order) {
    // NOTE: 'missed' is treated like 'cancelled' for timeline display purposes
    final isTerminated =
        order.status == 'cancelled' || order.status == 'missed';

    return [
      TimelineStep(
        label: 'Order Placed',
        date: order.createdAt,
        isCompleted: true,
        subtitle: 'by ${order.buyer?.displayName ?? 'Buyer'}',
      ),
      TimelineStep(
        label: 'Accepted',
        date:
            !isTerminated && order.status != 'pending' ? order.updatedAt : null,
        isCompleted: order.status == 'confirmed' || order.status == 'completed',
        subtitle:
            order.status != 'pending' && !isTerminated
                ? '${order.buyer?.displayName ?? 'Buyer'}\'s offer'
                : null,
      ),
      TimelineStep(
        label: 'Picked Up',
        date: order.status == 'completed' ? order.updatedAt : null,
        isCompleted: order.status == 'completed',
        subtitle: order.pickupLocation?.name,
      ),
      // NOTE: Append terminal steps for cancelled / missed states
      if (order.status == 'cancelled')
        TimelineStep(
          label: 'Cancelled',
          date: order.updatedAt,
          isCompleted: true,
          isCancelled: true,
        ),
      if (order.status == 'missed')
        TimelineStep(
          label: 'Offer Missed',
          date: order.updatedAt,
          isCompleted: true,
          isCancelled: true,
          subtitle: 'Another offer was accepted',
        ),
    ];
  }

  Widget _buildDeliveryStatus(BuildContext context, Order order) {
    final typo = context.smivoTypo;
    final colors = context.smivoColors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'DELIVERY CONFIRMATION',
          style: typo.labelSmall.copyWith(
            color: colors.onSurface.withValues(alpha: 0.5),
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 8),
        _infoRow(
          context,
          'Buyer',
          order.deliveryConfirmedByBuyer ? '✓ Confirmed' : 'Waiting',
        ),
        _infoRow(
          context,
          'Seller',
          order.deliveryConfirmedBySeller ? '✓ Confirmed' : 'Waiting',
        ),
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
            const SizedBox(height: 16),
          ],
        );
      },
    );
  }

  Widget _buildReviewSection(
    BuildContext context,
    WidgetRef ref,
    Order order,
    bool isBuyer,
    String? currentUserId,
  ) {
    if (order.status == 'missed') return const SizedBox.shrink();

    final colors = context.smivoColors;
    final typo = context.smivoTypo;

    if (order.status != 'completed' && order.status != 'cancelled') {
      return Padding(
        padding: const EdgeInsets.only(top: 8.0, bottom: 24.0),
        child: Text(
          'You can submit a review after the order is completed or cancelled.',
          style: typo.labelSmall.copyWith(color: colors.onSurfaceVariant),
          textAlign: TextAlign.center,
        ),
      );
    }

    final targetUserId = isBuyer ? order.sellerId : order.buyerId;
    final roleToRate = isBuyer ? 'seller' : 'buyer';
    
    final orderReviewAsync = ref.watch(
      orderReviewProvider(
        orderId: order.id,
        reviewerId: currentUserId ?? '',
      ),
    );

    return orderReviewAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, __) => const SizedBox.shrink(),
      data: (review) {
        if (review != null) {
          return Padding(
            padding: const EdgeInsets.only(top: 8.0, bottom: 24.0),
            child: SubmittedReviewCard(review: review),
          );
        }
        
        return Padding(
          padding: const EdgeInsets.only(top: 8.0, bottom: 24.0),
          child: CollapsibleSection(
            title: 'Leave a Review',
            initiallyExpanded: true,
            child: OrderReviewSection(
              order: order,
              currentUserId: currentUserId ?? '',
              targetUserId: targetUserId,
              role: roleToRate,
            ),
          ),
        );
      },
    );
  }

  Widget _buildCancelButton(
    BuildContext context,
    WidgetRef ref,
    Order order,
    bool isActing,
  ) {
    final colors = context.smivoColors;
    final typo = context.smivoTypo;
    final canCancel =
        order.status == 'pending' ||
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
            onPressed:
                isActing
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
            child: Text(
              isActing ? 'Processing...' : 'Cancel Order',
              style: typo.titleMedium,
            ),
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
      builder:
          (ctx) => AlertDialog(
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

  bool _canUploadEvidence(Order order, bool isBuyer, bool isSeller) {
    if (!isBuyer && !isSeller) return false;
    return order.status == 'confirmed' &&
        !(order.deliveryConfirmedByBuyer) &&
        !(order.deliveryConfirmedBySeller);
  }
}

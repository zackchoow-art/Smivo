import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smivo/core/theme/theme_extensions.dart';
import 'package:smivo/data/models/order.dart';
import 'package:smivo/features/orders/providers/order_chat_provider.dart';
import 'package:smivo/features/orders/providers/order_evidence_provider.dart';
import 'package:smivo/features/orders/providers/orders_provider.dart';
import 'package:smivo/features/orders/providers/rental_extension_provider.dart';
import 'package:smivo/features/orders/widgets/chat_history_section.dart';
import 'package:smivo/features/orders/widgets/evidence_photo_section.dart';
import 'package:smivo/features/orders/widgets/order_financial_summary.dart';
import 'package:smivo/features/orders/widgets/order_header_card.dart';
import 'package:smivo/features/orders/widgets/order_info_section.dart';
import 'package:smivo/features/orders/widgets/order_timeline.dart';
import 'package:smivo/features/orders/widgets/rental_date_section.dart';
import 'package:smivo/features/orders/widgets/rental_extension_card.dart';
import 'package:smivo/features/orders/widgets/rental_reminder_settings.dart';
import 'package:smivo/shared/widgets/collapsible_section.dart';
import 'package:smivo/shared/widgets/content_width_constraint.dart';
import 'package:smivo/features/shared/widgets/order_review_form.dart';
import 'package:smivo/features/shared/widgets/submitted_review_card.dart';
import 'package:smivo/features/shared/providers/order_review_provider.dart';
import 'package:smivo/features/seller/providers/seller_center_provider.dart';

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
        // NOTE: Also refresh extension data so status badges are up-to-date
        ref.invalidate(orderExtensionsProvider(order.id));
        await ref.read(orderDetailProvider(order.id).future);
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.fromLTRB(
          12,
          12,
          12,
          // NOTE: Extra bottom clearance so the last widget (Chat History)
          // is never obscured by bottom nav or system UI.
          MediaQuery.of(context).padding.bottom + 80,
        ),
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
                child: OrderTimeline(steps: _buildRentalSteps(order, isSeller)),
              ),
              const SizedBox(height: 16),

              // Section 2: Item Pricing — collapsible, default closed
              CollapsibleSection(
                title: 'Item Pricing',
                initiallyExpanded: false,
                child: OrderFinancialSummary(order: order),
              ),
              const SizedBox(height: 16),

              // Section 3: Order Info — collapsible, default open, counterparty only
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

              // Section 4: Rental Period — collapsible, default open
              if (order.rentalStartDate != null) ...[
                CollapsibleSection(
                  title: 'Rental Period',
                  initiallyExpanded: true,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      RentalDateSection(order: order),
                      // Rental reminder settings — only for active rentals, buyer only
                      if (order.rentalStatus == 'active' && isBuyer) ...[
                        const SizedBox(height: 16),
                        RentalReminderSettings(order: order, isBuyer: isBuyer),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],

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
                          label: 'Delivery Evidence',
                          orderId: order.id,
                          canUpload: _canUploadDeliveryEvidence(
                            order,
                            isBuyer,
                            isSeller,
                          ),
                          evidenceType: 'delivery',
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

              // Section 6: Rental Period Changes — collapsible, default open
              if (order.rentalStatus != null) ...[
                CollapsibleSection(
                  title: 'Rental Period Changes',
                  initiallyExpanded: true,
                  child: RentalExtensionCard(
                    order: order,
                    isBuyer: isBuyer,
                    isSeller: isSeller,
                    showTitle: false,
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Section 7: Return Evidence — collapsible, default open
              if (order.rentalStatus == 'active' ||
                  order.rentalStatus == 'return_requested' ||
                  order.rentalStatus == 'returned' ||
                  order.rentalStatus == 'deposit_refunded') ...[
                CollapsibleSection(
                  title: 'Return Evidence',
                  initiallyExpanded: true,
                  // NOTE: Lifecycle action button and status banner both live here
                  // so they share the same container width, keeping them aligned.
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      EvidencePhotoSection(
                        label: 'Return Evidence',
                        orderId: order.id,
                        canUpload: _canUploadReturnEvidence(
                          order,
                          isBuyer,
                          isSeller,
                        ),
                        evidenceType: 'return',
                      ),
                      const SizedBox(height: 12),
                      _buildRentalLifecycleActions(
                        context,
                        ref,
                        order,
                        isBuyer,
                        isSeller,
                        isActing,
                      ),
                      // NOTE: Status banner placed here so it shares the same
                      // parent width as the lifecycle action above it.
                      _buildStatusBanner(context, ref, order, isSeller),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],
              // NOTE: Show status banner in the main column only for orders where
              // the Return Evidence section is not visible (e.g. cancelled/missed
              // before any delivery was confirmed).
              if (order.rentalStatus != 'active' &&
                  order.rentalStatus != 'return_requested' &&
                  order.rentalStatus != 'returned' &&
                  order.rentalStatus != 'deposit_refunded')
                _buildStatusBanner(context, ref, order, isSeller),
              // Section 8: Chat History — collapsible, default closed
              _buildChatSection(ref, order),
              _buildReviewSection(context, ref, order, isBuyer, currentUserId),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBanner(
    BuildContext context,
    WidgetRef ref,
    Order order,
    bool isSeller,
  ) {
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
      // NOTE: Determine who cancelled for attribution.
      String cancelText;
      if (order.cancelledBy == null) {
        cancelText = 'Order was cancelled';
      } else if (order.cancelledBy == order.buyerId) {
        final name = order.buyer?.displayName ?? 'Buyer';
        cancelText = 'Cancelled by $name';
      } else {
        final name = order.seller?.displayName ?? 'Seller';
        cancelText = 'Cancelled by $name';
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
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
                  cancelText,
                  style: typo.bodyMedium.copyWith(color: colors.error),
                ),
              ],
            ),
          ),
        ],
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
      return _buildCancelButton(context, ref, order, isActing, isBuyer);
    }

    if (order.status == 'confirmed') {
      final myConfirmed =
          isBuyer
              ? order.deliveryConfirmedByBuyer
              : order.deliveryConfirmedBySeller;
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
            // NOTE: Only show cancel button if NEITHER party has confirmed
            if (!order.deliveryConfirmedByBuyer &&
                !order.deliveryConfirmedBySeller)
              _buildCancelButton(context, ref, order, isActing, isBuyer),
          ],
        );
      }

      final evidenceAsync = ref.watch(orderEvidenceProvider(order.id));
      final deliveryPhotosCount =
          evidenceAsync.value
              ?.where((p) => p.evidenceType == 'delivery')
              .length ??
          0;
      final canConfirm = deliveryPhotosCount >= 1;

      return Column(
        children: [
          if (!canConfirm)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text(
                'Please upload at least one photo as evidence to continue.',
                style: typo.bodyMedium.copyWith(
                  color: colors.error,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 360),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed:
                      (isActing || !canConfirm)
                          ? null
                          : () async => await ref
                              .read(orderActionsProvider.notifier)
                              .confirmDelivery(order),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: Text(
                    isActing
                        ? 'Processing...'
                        : (isBuyer ? 'Confirm Pickup' : 'Confirm Delivery'),
                    style: typo.titleMedium.copyWith(color: colors.onPrimary),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          if (!order.deliveryConfirmedByBuyer &&
              !order.deliveryConfirmedBySeller)
            _buildCancelButton(context, ref, order, isActing, isBuyer),
        ],
      );
    }

    if (order.status == 'completed') {
      return const SizedBox.shrink();
    }

    return const SizedBox.shrink();
  }

  List<TimelineStep> _buildRentalSteps(Order order, bool isSeller) {
    // NOTE: 'missed' treated same as 'cancelled' for terminal display
    final isTerminated =
        order.status == 'cancelled' || order.status == 'missed';
    final delivered =
        order.deliveryConfirmedByBuyer && order.deliveryConfirmedBySeller;

    final steps = <TimelineStep>[
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
        label: 'Delivered',
        date: delivered ? order.updatedAt : null,
        isCompleted: delivered,
        subtitle: (order.pickupLocationName != null || order.pickupLocation != null)
            ? '${order.pickupLocationName ?? order.pickupLocation?.name ?? 'Unknown'}, ${order.school}'
            : null,
      ),
    ];

    // NOTE: Rental lifecycle steps added only when relevant status is reached
    if (order.rentalStatus == 'active' ||
        order.rentalStatus == 'return_requested' ||
        order.rentalStatus == 'returned' ||
        order.rentalStatus == 'deposit_refunded' ||
        order.status == 'completed') {
      steps.add(
        TimelineStep(
          label: 'Returned',
          date: order.returnConfirmedAt,
          isCompleted: order.returnConfirmedAt != null,
        ),
      );
    }

    if (order.depositRefundedAt != null) {
      steps.add(
        TimelineStep(
          label: 'Deposit Refunded',
          date: order.depositRefundedAt,
          isCompleted: true,
        ),
      );
    }

    if (order.status == 'completed') {
      steps.add(
        TimelineStep(
          label: 'Completed',
          date: order.updatedAt,
          isCompleted: true,
        ),
      );
    }
    if (order.status == 'cancelled') {
      steps.add(
        TimelineStep(
          label: 'Cancelled',
          date: order.updatedAt,
          isCompleted: true,
          isCancelled: true,
          trailing: (isSeller && order.listingId.isNotEmpty)
              ? _RelistButton(
                  listingId: order.listingId,
                  initialStatus: order.listing?.status ?? 'active',
                )
              : null,
        ),
      );
    }
    if (order.status == 'missed') {
      steps.add(
        TimelineStep(
          label: 'Offer Missed',
          date: order.updatedAt,
          isCompleted: true,
          isCancelled: true,
          subtitle: 'Another offer was accepted',
        ),
      );
    }

    return steps;
  }

  Widget _buildDeliveryStatus(BuildContext context, Order order) {
    final typo = context.smivoTypo;
    final colors = context.smivoColors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Delivery Confirmation',
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
          return SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed:
                  isActing
                      ? null
                      : () => ref
                          .read(orderActionsProvider.notifier)
                          .requestReturn(order.id),
              icon: const Icon(Icons.assignment_return),
              label: Text(isActing ? 'Processing...' : 'Request Return'),
              style: ElevatedButton.styleFrom(
                backgroundColor: colors.warning,
                foregroundColor: colors.onPrimary,
                padding: const EdgeInsets.symmetric(vertical: 16),
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
                  onPressed:
                      isActing
                          ? null
                          : () => ref
                              .read(orderActionsProvider.notifier)
                              .confirmReturn(
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
                  onPressed:
                      isActing
                          ? null
                          : () => ref
                              .read(orderActionsProvider.notifier)
                              .refundDeposit(order.id),
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
    bool isBuyer,
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
                      final latestOrder = await ref.refresh(
                        orderDetailProvider(order.id).future,
                      );
                      if (latestOrder.deliveryConfirmedByBuyer ||
                          latestOrder.deliveryConfirmedBySeller) {
                        final otherName =
                            isBuyer
                                ? latestOrder.seller?.displayName
                                : latestOrder.buyer?.displayName;
                        if (context.mounted) {
                          _showErrorDialog(
                            context,
                            'Cannot Cancel',
                            '${otherName ?? 'The other party'} has already confirmed. You cannot cancel this order.',
                          );
                        }
                        return;
                      }
                      if (!context.mounted) return;

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

  void _showErrorDialog(BuildContext context, String title, String message) {
    final colors = context.smivoColors;
    final typo = context.smivoTypo;
    final radius = context.smivoRadius;

    showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            backgroundColor: colors.surface,
            surfaceTintColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(radius.lg),
            ),
            contentPadding: const EdgeInsets.all(24),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: colors.error.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.close, color: colors.error, size: 48),
                ),
                const SizedBox(height: 16),
                Text(
                  title,
                  style: typo.headlineSmall.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  message,
                  style: typo.bodyMedium.copyWith(
                    color: colors.onSurface.withValues(alpha: 0.7),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(ctx).pop(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colors.primary,
                      foregroundColor: colors.onPrimary,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: Text('OK', style: typo.titleMedium),
                  ),
                ),
              ],
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

  bool _canUploadDeliveryEvidence(Order order, bool isBuyer, bool isSeller) {
    if (order.status != 'confirmed') return false;
    if (isBuyer) return !order.deliveryConfirmedByBuyer;
    if (isSeller) return !order.deliveryConfirmedBySeller;
    return false;
  }

  bool _canUploadReturnEvidence(Order order, bool isBuyer, bool isSeller) {
    if (!isBuyer && !isSeller) return false;
    final rs = order.rentalStatus;
    return rs == 'active' || rs == 'return_requested';
  }
}

/// Relist button shown in the seller's cancelled rental order detail view.
class _RelistButton extends ConsumerStatefulWidget {
  const _RelistButton({required this.listingId, required this.initialStatus});

  final String listingId;
  final String initialStatus;

  @override
  ConsumerState<_RelistButton> createState() => _RelistButtonState();
}

class _RelistButtonState extends ConsumerState<_RelistButton> {
  bool _relisted = false;
  bool _isRelisting = false;

  @override
  Widget build(BuildContext context) {
    final colors = context.smivoColors;
    final typo = context.smivoTypo;
    final isLoading = ref.watch(relistActionsProvider).isLoading;
    final isAlreadyActive = widget.initialStatus == 'active';
    final isDone = _relisted || isAlreadyActive;

    if (isDone) {
      return Text(
        'Relisted',
        style: typo.labelLarge.copyWith(color: colors.outlineVariant),
      );
    }

    final isDisabled = isLoading || _isRelisting;

    return TextButton.icon(
      style: TextButton.styleFrom(
        foregroundColor: isDisabled ? colors.outlineVariant : colors.primary,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      onPressed: isDisabled
          ? null
          : () async {
              setState(() => _isRelisting = true);
              try {
                await ref
                    .read(relistActionsProvider.notifier)
                    .relist(widget.listingId);
                // NOTE: Mark as relisted locally so the button stays
                // disabled even before the provider invalidation
                // propagates through the widget tree.
                if (mounted) {
                  setState(() {
                    _relisted = true;
                    _isRelisting = false;
                  });
                }
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Item relisted — it\'s live on the marketplace again.',
                      ),
                    ),
                  );
                }
              } catch (_) {
                if (mounted) setState(() => _isRelisting = false);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Failed to relist. Please try again.'),
                    ),
                  );
                }
              }
            },
      icon: _isRelisting
          ? SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : Icon(Icons.refresh, size: 18),
      label: Text(
        _isRelisting ? 'Relisting...' : 'Relist',
        style: typo.labelLarge.copyWith(fontWeight: FontWeight.bold),
      ),
    );
  }
}

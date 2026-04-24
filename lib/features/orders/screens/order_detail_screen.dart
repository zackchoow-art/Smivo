import 'package:flutter/material.dart';
import 'package:smivo/core/theme/theme_extensions.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import 'package:smivo/data/models/order.dart';
import 'package:smivo/features/auth/providers/auth_provider.dart';
import 'package:smivo/features/orders/providers/order_chat_provider.dart';
import 'package:smivo/features/orders/providers/orders_provider.dart';
import 'package:smivo/features/orders/widgets/chat_history_section.dart';
import 'package:smivo/features/orders/widgets/evidence_photo_section.dart';

class OrderDetailScreen extends ConsumerWidget {
  const OrderDetailScreen({super.key, required this.orderId});
  final String orderId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orderAsync = ref.watch(orderDetailProvider(orderId));
    final actionsState = ref.watch(orderActionsProvider);
    final currentUserId = ref.watch(authStateProvider).valueOrNull?.id;
    final colors = context.smivoColors;

    ref.listen(orderActionsProvider, (previous, next) {
      if (next.hasError && !next.isLoading) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Action failed: ${next.error}'), backgroundColor: colors.error));
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Order Details'),
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.pop()),
      ),
      body: orderAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: $err')),
        data: (order) => _buildBody(context, ref, order, currentUserId, actionsState.isLoading),
      ),
    );
  }

  Widget _buildBody(BuildContext context, WidgetRef ref, Order order, String? currentUserId, bool isActing) {
    final isBuyer = order.buyerId == currentUserId;
    final isSeller = order.sellerId == currentUserId;
    final counterparty = isBuyer ? order.seller : order.buyer;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(12),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        _buildListingCard(context, order),
        const SizedBox(height: 16),
        _buildTimeline(context, order),
        const SizedBox(height: 16),
        _buildFinancialSummary(context, order),
        const SizedBox(height: 16),
        _buildInfoSection(context, order, counterparty?.displayName),
        const SizedBox(height: 16),
        if (order.orderType == 'rental' && order.rentalStartDate != null) ...[
          _buildRentalSection(context, order), const SizedBox(height: 16),
        ],
        if (order.status == 'confirmed' || order.status == 'completed') _buildDeliveryStatus(context, order),
        if (order.status == 'confirmed' || order.status == 'completed') ...[
          EvidencePhotoSection(
            orderId: order.id,
            canUpload: _canUploadEvidence(order, isBuyer, isSeller),
          ),
          const SizedBox(height: 16),
        ],
        Builder(builder: (context) {
          final chatRoomAsync = ref.watch(orderChatRoomIdProvider(listingId: order.listingId, buyerId: order.buyerId, sellerId: order.sellerId));
          return chatRoomAsync.when(
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
            data: (chatRoomId) {
              if (chatRoomId == null) return const SizedBox.shrink();
              return Column(children: [ChatHistorySection(chatRoomId: chatRoomId, currentUserId: currentUserId ?? ''), const SizedBox(height: 16)]);
            },
          );
        }),
        _buildActions(context, ref, order, isBuyer, isSeller, isActing),
        if (order.orderType == 'rental' && order.rentalStatus != null) ...[
          const SizedBox(height: 12),
          _buildRentalLifecycleActions(context, ref, order, isBuyer, isSeller, isActing),
        ],
      ]),
    );
  }

  Widget _buildTimeline(BuildContext context, Order order) {
    final colors = context.smivoColors;
    final typo = context.smivoTypo;
    final steps = <_TimelineStep>[
      _TimelineStep(label: 'Order Placed', date: order.createdAt, isCompleted: true),
      _TimelineStep(label: 'Accepted',
        date: order.status != 'pending' && order.status != 'cancelled' ? order.updatedAt : null,
        isCompleted: order.status == 'confirmed' || order.status == 'completed'),
      if (order.orderType == 'sale')
        _TimelineStep(label: 'Picked Up', date: order.status == 'completed' ? order.updatedAt : null, isCompleted: order.status == 'completed'),
      if (order.orderType == 'rental') ...[
        _TimelineStep(label: 'Delivered',
          date: order.deliveryConfirmedByBuyer && order.deliveryConfirmedBySeller ? order.updatedAt : null,
          isCompleted: order.deliveryConfirmedByBuyer && order.deliveryConfirmedBySeller),
        _TimelineStep(label: 'Returned', date: order.returnConfirmedAt, isCompleted: order.returnConfirmedAt != null),
      ],
    ];
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('ORDER TIMELINE', style: typo.labelSmall.copyWith(color: colors.onSurface.withValues(alpha: 0.5), letterSpacing: 0.5)),
      const SizedBox(height: 12),
      ...steps.asMap().entries.map((entry) => _buildTimelineRow(context, entry.value, entry.key == steps.length - 1)),
    ]);
  }

  Widget _buildTimelineRow(BuildContext context, _TimelineStep step, bool isLast) {
    final colors = context.smivoColors;
    final typo = context.smivoTypo;
    final dateStr = step.date != null ? DateFormat('MMM d, yyyy · h:mm a').format(step.date!.toLocal()) : '—';
    return IntrinsicHeight(child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      SizedBox(width: 32, child: Column(children: [
        Container(width: 14, height: 14, decoration: BoxDecoration(shape: BoxShape.circle,
          color: step.isCompleted ? colors.primary : colors.surfaceContainerHigh,
          border: Border.all(color: step.isCompleted ? colors.primary : colors.outlineVariant, width: 2)),
          child: step.isCompleted ? const Icon(Icons.check, size: 8, color: Colors.white) : null),
        if (!isLast) Expanded(child: Container(width: 2, color: step.isCompleted ? colors.primary : colors.surfaceContainerHigh)),
      ])),
      const SizedBox(width: 8),
      Expanded(child: Padding(padding: const EdgeInsets.only(bottom: 20), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(step.label, style: typo.bodyMedium.copyWith(fontWeight: FontWeight.w600, color: step.isCompleted ? colors.onSurface : colors.outlineVariant)),
        if (step.date != null) Text(dateStr, style: typo.bodySmall.copyWith(color: colors.outlineVariant)),
      ]))),
    ]));
  }

  Widget _buildFinancialSummary(BuildContext context, Order order) {
    final colors = context.smivoColors;
    final typo = context.smivoTypo;
    final radius = context.smivoRadius;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: colors.surfaceContainerLow, borderRadius: BorderRadius.circular(radius.lg)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('FINANCIAL SUMMARY', style: typo.labelSmall.copyWith(color: colors.onSurface.withValues(alpha: 0.5), letterSpacing: 0.5)),
        const SizedBox(height: 12),
        _summaryRow(context, 'Type', order.orderType.toUpperCase()),
        if (order.orderType == 'rental' && order.listing != null) ...[
          if ((order.listing!.rentalDailyPrice ?? 0) > 0)
            _summaryRow(context, 'Daily Rate', '\$${order.listing!.rentalDailyPrice!.toStringAsFixed(2)}'),
          if ((order.listing!.rentalWeeklyPrice ?? 0) > 0)
            _summaryRow(context, 'Weekly Rate', '\$${order.listing!.rentalWeeklyPrice!.toStringAsFixed(2)}'),
          if ((order.listing!.rentalMonthlyPrice ?? 0) > 0)
            _summaryRow(context, 'Monthly Rate', '\$${order.listing!.rentalMonthlyPrice!.toStringAsFixed(2)}'),
        ],
        if (order.depositAmount > 0) _summaryRow(context, 'Deposit', '\$${order.depositAmount.toStringAsFixed(2)}'),
        const Divider(),
        _summaryRow(context, 'Total', '\$${order.totalPrice.toStringAsFixed(2)}', isBold: true),
      ]),
    );
  }

  Widget _summaryRow(BuildContext context, String label, String value, {bool isBold = false}) {
    final colors = context.smivoColors;
    final typo = context.smivoTypo;
    return Padding(padding: const EdgeInsets.symmetric(vertical: 4), child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(label, style: typo.bodyMedium),
        Text(value, style: typo.bodyMedium.copyWith(fontWeight: isBold ? FontWeight.bold : FontWeight.normal, color: isBold ? colors.primary : null)),
    ]));
  }

  Widget _buildListingCard(BuildContext context, Order order) {
    final colors = context.smivoColors;
    final typo = context.smivoTypo;
    final radius = context.smivoRadius;
    final imageUrl = order.listing?.images.firstOrNull?.imageUrl;
    final title = order.listing?.title ?? 'Untitled';
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: colors.surfaceContainerLow, borderRadius: BorderRadius.circular(radius.lg)),
      child: Row(children: [
        if (imageUrl != null && imageUrl.isNotEmpty)
          ClipRRect(borderRadius: BorderRadius.circular(radius.md), child: Image.network(imageUrl, width: 80, height: 80, fit: BoxFit.cover))
        else Container(width: 80, height: 80, decoration: BoxDecoration(color: colors.surfaceContainerHigh, borderRadius: BorderRadius.circular(radius.md)),
          child: const Icon(Icons.image_not_supported)),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: typo.titleMedium, maxLines: 2, overflow: TextOverflow.ellipsis),
          const SizedBox(height: 4),
          Text('\$${order.totalPrice.toStringAsFixed(2)}', style: typo.titleMedium.copyWith(color: colors.primary, fontWeight: FontWeight.bold)),
        ])),
      ]),
    );
  }

  Widget _buildInfoSection(BuildContext context, Order order, String? counterpartyName) {
    final typo = context.smivoTypo;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('Order Info', style: typo.titleMedium),
      const SizedBox(height: 8),
      _infoRow(context, 'Status', _statusText(order.status)),
      _infoRow(context, 'Type', order.orderType.toUpperCase()),
      _infoRow(context, 'Date', order.createdAt.toLocal().toString().split(' ')[0]),
      _infoRow(context, 'Counterparty', counterpartyName ?? 'Unknown'),
      // NOTE: Show deposit only for rental orders with non-zero deposit
      if (order.orderType == 'rental' && order.depositAmount > 0)
        _infoRow(context, 'Deposit', '\$${order.depositAmount.toStringAsFixed(2)}'),
      if (order.pickupLocation != null) _infoRow(context, 'Pickup', order.pickupLocation!.name),
    ]);
  }

  Widget _buildRentalSection(BuildContext context, Order order) {
    final typo = context.smivoTypo;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('Rental Period', style: typo.titleMedium),
      const SizedBox(height: 8),
      _infoRow(context, 'Start', order.rentalStartDate!.toLocal().toString().split(' ')[0]),
      if (order.rentalEndDate != null) _infoRow(context, 'End', order.rentalEndDate!.toLocal().toString().split(' ')[0]),
      if (order.returnConfirmedAt != null) _infoRow(context, 'Returned', order.returnConfirmedAt!.toLocal().toString().split(' ')[0]),
    ]);
  }

  Widget _buildDeliveryStatus(BuildContext context, Order order) {
    final typo = context.smivoTypo;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('Delivery Confirmation', style: typo.titleMedium),
      const SizedBox(height: 8),
      _infoRow(context, 'Buyer', order.deliveryConfirmedByBuyer ? '✓ Confirmed' : 'Waiting'),
      _infoRow(context, 'Seller', order.deliveryConfirmedBySeller ? '✓ Confirmed' : 'Waiting'),
    ]);
  }

  Widget _buildActions(BuildContext context, WidgetRef ref, Order order, bool isBuyer, bool isSeller, bool isActing) {
    final isParticipant = isBuyer || isSeller;
    if (!isParticipant) return const SizedBox.shrink();
    final colors = context.smivoColors;
    final typo = context.smivoTypo;
    final radius = context.smivoRadius;

    switch (order.status) {
      case 'pending':
        return Column(children: [
          if (isSeller) SizedBox(width: double.infinity, child: ElevatedButton(
            onPressed: isActing ? null : () async => await ref.read(orderActionsProvider.notifier).acceptOrder(order.id),
            style: ElevatedButton.styleFrom(backgroundColor: colors.primary, padding: const EdgeInsets.symmetric(vertical: 16)),
            child: Text(isActing ? 'Processing...' : 'Accept Order', style: typo.titleMedium.copyWith(color: colors.onPrimary)),
          )),
          const SizedBox(height: 8),
          _buildCancelButton(context, ref, order, isActing),
        ]);
      case 'confirmed':
        if (order.orderType == 'sale') {
          if (isBuyer) {
            return Column(children: [
              SizedBox(width: double.infinity, child: ElevatedButton(
                onPressed: isActing ? null : () async => await ref.read(orderActionsProvider.notifier).confirmDelivery(order),
                style: ElevatedButton.styleFrom(backgroundColor: colors.primary, padding: const EdgeInsets.symmetric(vertical: 16)),
                child: Text(isActing ? 'Processing...' : 'Confirm Pickup', style: typo.titleMedium.copyWith(color: colors.onPrimary)),
              )),
              const SizedBox(height: 8),
              _buildCancelButton(context, ref, order, isActing),
            ]);
          } else {
            return Column(children: [
              Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: colors.surfaceContainerLow, borderRadius: BorderRadius.circular(radius.md)),
                child: Text('Waiting for buyer to confirm pickup', style: typo.bodyMedium)),
              const SizedBox(height: 8),
              _buildCancelButton(context, ref, order, isActing),
            ]);
          }
        }
        final myConfirmed = isBuyer ? order.deliveryConfirmedByBuyer : order.deliveryConfirmedBySeller;
        if (myConfirmed) {
          return Column(children: [
            Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: colors.surfaceContainerLow, borderRadius: BorderRadius.circular(radius.md)),
              child: Text('You have confirmed delivery. Waiting for the other party.', style: typo.bodyMedium)),
            const SizedBox(height: 8),
            _buildCancelButton(context, ref, order, isActing),
          ]);
        }
        return Column(children: [
          SizedBox(width: double.infinity, child: ElevatedButton(
            onPressed: isActing ? null : () async => await ref.read(orderActionsProvider.notifier).confirmDelivery(order),
            style: ElevatedButton.styleFrom(backgroundColor: colors.primary, padding: const EdgeInsets.symmetric(vertical: 16)),
            child: Text(isActing ? 'Processing...' : 'Confirm Delivery', style: typo.titleMedium.copyWith(color: colors.onPrimary)),
          )),
          const SizedBox(height: 8),
          _buildCancelButton(context, ref, order, isActing),
        ]);
      case 'completed':
        return Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: colors.surfaceContainerLow, borderRadius: BorderRadius.circular(radius.md)),
          child: const Text('✓ Order completed successfully'));
      case 'cancelled':
        return Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: colors.surfaceContainerLow, borderRadius: BorderRadius.circular(radius.md)),
          child: const Text('✕ Order was cancelled'));
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildRentalLifecycleActions(BuildContext context, WidgetRef ref, Order order, bool isBuyer, bool isSeller, bool isActing) {
    final colors = context.smivoColors;
    final typo = context.smivoTypo;
    final radius = context.smivoRadius;
    switch (order.rentalStatus) {
      case 'active':
        if (isBuyer) {
          return SizedBox(width: double.infinity, child: ElevatedButton.icon(
            onPressed: isActing ? null : () => ref.read(orderActionsProvider.notifier).requestReturn(order.id),
            icon: const Icon(Icons.assignment_return),
            label: Text(isActing ? 'Processing...' : 'Request Return'),
            style: ElevatedButton.styleFrom(backgroundColor: colors.warning, foregroundColor: colors.onPrimary, padding: const EdgeInsets.symmetric(vertical: 16)),
          ));
        }
        return Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: colors.success.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(radius.md)),
          child: Row(children: [Icon(Icons.check_circle, color: colors.success), const SizedBox(width: 8), Text('Rental Active — Item with buyer', style: typo.bodyMedium)]));
      case 'return_requested':
        if (isSeller) {
          return SizedBox(width: double.infinity, child: ElevatedButton.icon(
            onPressed: isActing ? null : () => ref.read(orderActionsProvider.notifier).confirmReturn(order.id),
            icon: const Icon(Icons.check), label: Text(isActing ? 'Processing...' : 'Confirm Return'),
            style: ElevatedButton.styleFrom(backgroundColor: colors.primary, foregroundColor: colors.onPrimary, padding: const EdgeInsets.symmetric(vertical: 16)),
          ));
        }
        return Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: colors.warning.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(radius.md)),
          child: Row(children: [Icon(Icons.hourglass_top, color: colors.warning), const SizedBox(width: 8),
            Expanded(child: Text('Waiting for seller to confirm return', style: typo.bodyMedium))]));
      case 'returned':
        if (isSeller && order.depositAmount > 0) {
          return SizedBox(width: double.infinity, child: ElevatedButton.icon(
            onPressed: isActing ? null : () => ref.read(orderActionsProvider.notifier).refundDeposit(order.id),
            icon: const Icon(Icons.payments),
            label: Text(isActing ? 'Processing...' : 'Confirm Deposit Refund (\$${order.depositAmount.toStringAsFixed(0)})'),
            style: ElevatedButton.styleFrom(backgroundColor: colors.success, foregroundColor: colors.onPrimary, padding: const EdgeInsets.symmetric(vertical: 16)),
          ));
        }
        return Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: colors.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(radius.md)),
          child: Row(children: [Icon(Icons.assignment_turned_in, color: colors.primary), const SizedBox(width: 8),
            Expanded(child: Text(order.depositAmount > 0 ? 'Item returned — Awaiting deposit refund' : 'Item returned — Transaction complete', style: typo.bodyMedium))]));
      case 'deposit_refunded':
        return Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: colors.success.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(radius.md)),
          child: Row(children: [Icon(Icons.check_circle, color: colors.success), const SizedBox(width: 8), Text('Deposit refunded — Transaction complete', style: typo.bodyMedium)]));
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildCancelButton(BuildContext context, WidgetRef ref, Order order, bool isActing) {
    final colors = context.smivoColors;
    final typo = context.smivoTypo;
    final canCancel = order.status == 'pending' || (order.status == 'confirmed' && !order.deliveryConfirmedByBuyer && !order.deliveryConfirmedBySeller);
    if (!canCancel) return const SizedBox.shrink();
    return SizedBox(width: double.infinity, child: OutlinedButton(
      onPressed: isActing ? null : () async {
        final confirmed = await _showConfirmDialog(context, 'Cancel Order', 'Are you sure you want to cancel this order?');
        if (confirmed == true) await ref.read(orderActionsProvider.notifier).cancelOrder(order.id);
      },
      style: OutlinedButton.styleFrom(foregroundColor: colors.error, side: BorderSide(color: colors.error), padding: const EdgeInsets.symmetric(vertical: 16)),
      child: Text(isActing ? 'Processing...' : 'Cancel Order', style: typo.titleMedium),
    ));
  }

  Widget _infoRow(BuildContext context, String label, String value) {
    final colors = context.smivoColors;
    final typo = context.smivoTypo;
    return Padding(padding: const EdgeInsets.symmetric(vertical: 4), child: Row(children: [
      SizedBox(width: 120, child: Text(label, style: typo.bodyMedium.copyWith(color: colors.outlineVariant))),
      Expanded(child: Text(value, style: typo.bodyMedium)),
    ]));
  }

  String _statusText(String status) {
    switch (status) {
      case 'pending': return 'Pending';
      case 'confirmed': return 'In Progress';
      case 'completed': return 'Completed';
      case 'cancelled': return 'Cancelled';
      default: return status;
    }
  }

  Future<bool?> _showConfirmDialog(BuildContext context, String title, String message) {
    return showDialog<bool>(context: context, builder: (ctx) => AlertDialog(
      title: Text(title), content: Text(message),
      actions: [
        TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('No')),
        TextButton(onPressed: () => Navigator.of(ctx).pop(true), child: const Text('Yes')),
      ],
    ));
  }

  bool _canUploadEvidence(Order order, bool isBuyer, bool isSeller) {
    if (!isBuyer && !isSeller) return false;

    if (order.orderType == 'sale') {
      // Sale: allow upload only before delivery is confirmed
      return order.status == 'confirmed' &&
          !(order.deliveryConfirmedByBuyer) &&
          !(order.deliveryConfirmedBySeller);
    } else {
      // Rental: allow upload during active/return phases
      final rs = order.rentalStatus;
      return rs == 'active' || rs == 'return_requested';
    }
  }
}

class _TimelineStep {
  const _TimelineStep({required this.label, required this.isCompleted, this.date});
  final String label;
  final DateTime? date;
  final bool isCompleted;
}

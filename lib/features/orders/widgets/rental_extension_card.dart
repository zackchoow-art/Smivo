import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:smivo/core/theme/theme_extensions.dart';
import 'package:smivo/data/models/order.dart';
import 'package:smivo/data/models/rental_extension.dart';
import 'package:smivo/features/orders/providers/rental_extension_provider.dart';

class RentalExtensionCard extends ConsumerStatefulWidget {
  const RentalExtensionCard({
    super.key,
    required this.order,
    required this.isBuyer,
    required this.isSeller,
  });

  final Order order;
  final bool isBuyer;
  final bool isSeller;

  @override
  ConsumerState<RentalExtensionCard> createState() => _RentalExtensionCardState();
}

class _RentalExtensionCardState extends ConsumerState<RentalExtensionCard> {
  bool _isAdjusting = false;
  int _quantityOffset = 0;
  bool _isSubmitting = false;

  ({String rateType, int quantity, double unitPrice}) _inferRentalRate(Order order) {
    if (order.rentalStartDate == null || order.rentalEndDate == null) {
      return (rateType: 'daily', quantity: 1, unitPrice: order.listing?.rentalDailyPrice ?? 0);
    }
    final days = order.rentalEndDate!.difference(order.rentalStartDate!).inDays;
    final listing = order.listing;
    
    // Check monthly first
    if (days >= 30 && days % 30 == 0 && (listing?.rentalMonthlyPrice ?? 0) > 0) {
      return (rateType: 'monthly', quantity: days ~/ 30, unitPrice: listing!.rentalMonthlyPrice!);
    }
    // Then weekly
    if (days >= 7 && days % 7 == 0 && (listing?.rentalWeeklyPrice ?? 0) > 0) {
      return (rateType: 'weekly', quantity: days ~/ 7, unitPrice: listing!.rentalWeeklyPrice!);
    }
    // Default to daily
    return (rateType: 'daily', quantity: days, unitPrice: listing?.rentalDailyPrice ?? 0);
  }

  void _resetAdjustment() {
    setState(() {
      _isAdjusting = false;
      _quantityOffset = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final extensionsAsync = ref.watch(orderExtensionsProvider(widget.order.id));
    final colors = context.smivoColors;
    final typo = context.smivoTypo;
    final radius = context.smivoRadius;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(radius.lg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'RENTAL PERIOD CHANGES',
            style: typo.labelSmall.copyWith(
              color: colors.onSurface.withValues(alpha: 0.5),
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 12),
          extensionsAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, _) => Text('Error: $err', style: typo.bodySmall.copyWith(color: colors.error)),
            data: (extensions) {
              if (extensions.isEmpty && !widget.isBuyer) {
                return Text(
                  'No change requests yet.',
                  style: typo.bodySmall.copyWith(color: colors.outlineVariant),
                );
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ...extensions.map((ext) => _buildExtensionItem(context, ref, ext)),
                  if (widget.isBuyer && widget.order.rentalStatus == 'active') ...[
                    if (!_isAdjusting)
                      OutlinedButton(
                        onPressed: () => setState(() => _isAdjusting = true),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: const Text('Adjust Rental Period'),
                      )
                    else
                      _buildAdjustmentUI(context),
                  ],
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAdjustmentUI(BuildContext context) {
    final colors = context.smivoColors;
    final typo = context.smivoTypo;
    final radius = context.smivoRadius;

    final rateInfo = _inferRentalRate(widget.order);
    final originalEndDate = widget.order.rentalEndDate!;
    final currentQuantity = rateInfo.quantity;
    final newQuantity = currentQuantity + _quantityOffset;
    
    final canDecrease = newQuantity > 1; // Can't shorten to 0 or less
    final canIncrease = newQuantity < 365;

    int daysPerUnit = 1;
    if (rateInfo.rateType == 'monthly') daysPerUnit = 30;
    if (rateInfo.rateType == 'weekly') daysPerUnit = 7;

    final daysDiff = _quantityOffset * daysPerUnit;
    final newEndDate = originalEndDate.add(Duration(days: daysDiff));
    final priceDiff = _quantityOffset * rateInfo.unitPrice;
    final newTotal = widget.order.totalPrice + priceDiff;
    final requestType = _quantityOffset > 0 ? 'extend' : 'shorten';

    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(radius.md),
        border: Border.all(color: colors.outlineVariant.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Adjust Rental Period', style: typo.titleMedium),
              IconButton(
                icon: const Icon(Icons.close, size: 20),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                onPressed: _resetAdjustment,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Rate:', style: typo.bodyMedium.copyWith(color: colors.outlineVariant)),
              Text(rateInfo.rateType.toUpperCase(), style: typo.bodyMedium.copyWith(fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Quantity:', style: typo.bodyMedium.copyWith(color: colors.outlineVariant)),
              Row(
                children: [
                  IconButton(
                    onPressed: canDecrease ? () => setState(() => _quantityOffset--) : null,
                    icon: const Icon(Icons.remove_circle_outline),
                    color: colors.primary,
                  ),
                  SizedBox(
                    width: 40,
                    child: Text(
                      newQuantity.toString(),
                      textAlign: TextAlign.center,
                      style: typo.titleMedium,
                    ),
                  ),
                  IconButton(
                    onPressed: canIncrease ? () => setState(() => _quantityOffset++) : null,
                    icon: const Icon(Icons.add_circle_outline),
                    color: colors.primary,
                  ),
                ],
              ),
            ],
          ),
          if (_quantityOffset != 0) ...[
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Divider(),
            ),
            Text(
              _quantityOffset > 0 
                ? 'Extension (+$_quantityOffset ${rateInfo.rateType})'
                : 'Early Return ($_quantityOffset ${rateInfo.rateType})',
              style: typo.bodyMedium.copyWith(
                color: _quantityOffset > 0 ? colors.primary : colors.error,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('New end date:', style: typo.bodyMedium.copyWith(color: colors.outlineVariant)),
                Text(DateFormat.yMMMd().format(newEndDate), style: typo.bodyMedium),
              ],
            ),
            const SizedBox(height: 2),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Days change:', style: typo.bodyMedium.copyWith(color: colors.outlineVariant)),
                Text('${daysDiff > 0 ? '+' : ''}$daysDiff', style: typo.bodyMedium),
              ],
            ),
            const SizedBox(height: 2),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Price change:', style: typo.bodyMedium.copyWith(color: colors.outlineVariant)),
                Text('${priceDiff >= 0 ? '+' : '-'}\$${priceDiff.abs().toStringAsFixed(2)}', style: typo.bodyMedium),
              ],
            ),
            const SizedBox(height: 2),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('New rental total:', style: typo.bodyMedium.copyWith(color: colors.outlineVariant)),
                Text('\$${newTotal.toStringAsFixed(2)}', style: typo.bodyMedium.copyWith(fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _isSubmitting ? null : () => _submitRequest(
                requestType: requestType,
                originalEndDate: originalEndDate,
                newEndDate: newEndDate,
                priceDiff: priceDiff,
                newTotal: newTotal,
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: colors.primary,
                foregroundColor: colors.onPrimary,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: _isSubmitting 
                ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : const Text('Submit Request'),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _submitRequest({
    required String requestType,
    required DateTime originalEndDate,
    required DateTime newEndDate,
    required double priceDiff,
    required double newTotal,
  }) async {
    setState(() => _isSubmitting = true);
    try {
      await ref.read(rentalExtensionActionsProvider.notifier).requestExtension(
        orderId: widget.order.id,
        requestedBy: widget.order.buyerId,
        requestType: requestType,
        originalEndDate: originalEndDate,
        newEndDate: newEndDate,
        priceDiff: priceDiff,
        newTotal: newTotal,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 8),
                Text('Request submitted successfully'),
              ],
            ),
            backgroundColor: Colors.green,
          ),
        );
        _resetAdjustment();
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  Widget _buildExtensionItem(BuildContext context, WidgetRef ref, RentalExtension ext) {
    final colors = context.smivoColors;
    final typo = context.smivoTypo;
    final radius = context.smivoRadius;
    final isPending = ext.status == 'pending';
    
    final originalEndDate = ext.originalEndDate;
    final daysDiff = ext.newEndDate.difference(originalEndDate).inDays;
    final grandTotal = ext.newTotal + widget.order.depositAmount;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(radius.md),
        border: Border.all(color: colors.outlineVariant.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    ext.requestType == 'extend' ? Icons.event_available : Icons.event_busy,
                    size: 16,
                    color: colors.primary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    ext.requestType == 'extend' ? 'Extension Request' : 'Early Return Request',
                    style: typo.titleMedium,
                  ),
                ],
              ),
              _buildStatusBadge(context, ext.status),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Submitted: ${DateFormat.yMMMd().add_jm().format(ext.createdAt)}',
            style: typo.bodySmall.copyWith(color: colors.outlineVariant),
          ),
          const SizedBox(height: 8),
          Text(
            '${DateFormat.yMMMd().format(originalEndDate)} → ${DateFormat.yMMMd().format(ext.newEndDate)}',
            style: typo.bodyMedium.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            'Days change: ${daysDiff > 0 ? '+' : ''}$daysDiff days',
            style: typo.bodyMedium,
          ),
          Text(
            'Price change: ${ext.priceDiff >= 0 ? '+' : '-'}\$${ext.priceDiff.abs().toStringAsFixed(2)}',
            style: typo.bodyMedium,
          ),
          Text(
            'New rental total: \$${ext.newTotal.toStringAsFixed(2)}',
            style: typo.bodyMedium,
          ),
          Text(
            'Grand total (w/ deposit): \$${grandTotal.toStringAsFixed(2)}',
            style: typo.bodyMedium.copyWith(fontWeight: FontWeight.bold),
          ),
          if (ext.status == 'rejected' && ext.rejectionNote != null) ...[
            const SizedBox(height: 8),
            Text(
              'Note: ${ext.rejectionNote}',
              style: typo.bodySmall.copyWith(color: colors.error),
            ),
          ],
          if (widget.isSeller && isPending) ...[
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => _handleReject(ref, ext),
                  child: Text('Reject', style: TextStyle(color: colors.error)),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () => _handleApprove(ref, ext),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colors.primary,
                    foregroundColor: colors.onPrimary,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  ),
                  child: const Text('Approve'),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatusBadge(BuildContext context, String status) {
    final colors = context.smivoColors;
    final typo = context.smivoTypo;
    final radius = context.smivoRadius;

    Color badgeColor;
    Color textColor;
    switch (status) {
      case 'pending':
        badgeColor = colors.warning.withValues(alpha: 0.1);
        textColor = colors.warning;
        break;
      case 'approved':
        badgeColor = colors.success.withValues(alpha: 0.1);
        textColor = colors.success;
        break;
      case 'rejected':
        badgeColor = colors.error.withValues(alpha: 0.1);
        textColor = colors.error;
        break;
      default:
        badgeColor = colors.outlineVariant.withValues(alpha: 0.1);
        textColor = colors.outlineVariant;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: badgeColor,
        borderRadius: BorderRadius.circular(radius.full),
      ),
      child: Text(
        status.toUpperCase(),
        style: typo.labelSmall.copyWith(color: textColor, fontWeight: FontWeight.bold),
      ),
    );
  }

  Future<void> _handleApprove(WidgetRef ref, RentalExtension ext) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Approve Change'),
        content: const Text('This will update the order dates and total price. Continue?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Approve')),
        ],
      ),
    );

    if (confirmed == true) {
      await ref.read(rentalExtensionActionsProvider.notifier).approveExtension(ext.id, widget.order.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 8),
                Text('Extension approved'),
              ],
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  Future<void> _handleReject(WidgetRef ref, RentalExtension ext) async {
    final noteController = TextEditingController();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Reject Change'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Optional: Add a reason for rejection'),
            const SizedBox(height: 8),
            TextField(
              controller: noteController,
              decoration: const InputDecoration(
                hintText: 'e.g. Item is reserved by another student',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Reject')),
        ],
      ),
    );

    if (confirmed == true) {
      await ref.read(rentalExtensionActionsProvider.notifier).rejectExtension(
        ext.id, 
        widget.order.id, 
        note: noteController.text.isEmpty ? null : noteController.text,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                Icon(Icons.error_outline, color: Colors.white),
                SizedBox(width: 8),
                Text('Extension rejected'),
              ],
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:smivo/core/theme/theme_extensions.dart';
import 'package:smivo/data/models/order.dart';
import 'package:smivo/data/models/rental_extension.dart';
import 'package:smivo/features/orders/providers/rental_extension_provider.dart';

class RentalExtensionCard extends ConsumerWidget {
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
  Widget build(BuildContext context, WidgetRef ref) {
    final extensionsAsync = ref.watch(orderExtensionsProvider(order.id));
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
              if (extensions.isEmpty && !isBuyer) {
                return Text(
                  'No change requests yet.',
                  style: typo.bodySmall.copyWith(color: colors.outlineVariant),
                );
              }

              return Column(
                children: [
                  ...extensions.map((ext) => _buildExtensionItem(context, ref, ext)),
                  if (isBuyer && order.rentalStatus == 'active') ...[
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => _showRequestDialog(context, ref, 'extend'),
                            icon: const Icon(Icons.add_circle_outline, size: 18),
                            label: const Text('Extend'),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => _showRequestDialog(context, ref, 'shorten'),
                            icon: const Icon(Icons.remove_circle_outline, size: 18),
                            label: const Text('Shorten'),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildExtensionItem(BuildContext context, WidgetRef ref, RentalExtension ext) {
    final colors = context.smivoColors;
    final typo = context.smivoTypo;
    final radius = context.smivoRadius;
    final isPending = ext.status == 'pending';

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
                    ext.requestType == 'extend' ? 'Extension Request' : 'Shorten Request',
                    style: typo.titleMedium,
                  ),
                ],
              ),
              _buildStatusBadge(context, ext.status),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'New end date: ${DateFormat.yMMMd().format(ext.newEndDate)}',
            style: typo.bodyMedium,
          ),
          Text(
            'Price change: ${ext.priceDiff >= 0 ? '+' : ''}\$${ext.priceDiff.toStringAsFixed(2)} → New Total: \$${ext.newTotal.toStringAsFixed(2)}',
            style: typo.bodySmall.copyWith(color: colors.outlineVariant),
          ),
          if (ext.status == 'rejected' && ext.rejectionNote != null) ...[
            const SizedBox(height: 4),
            Text(
              'Note: ${ext.rejectionNote}',
              style: typo.bodySmall.copyWith(color: colors.error),
            ),
          ],
          if (isSeller && isPending) ...[
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => _handleReject(context, ref, ext),
                  child: Text('Reject', style: TextStyle(color: colors.error)),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () => _handleApprove(context, ref, ext),
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

  Future<void> _showRequestDialog(BuildContext context, WidgetRef ref, String type) async {
    final originalEndDate = order.rentalEndDate;
    if (originalEndDate == null) return;

    final initialDate = type == 'extend' 
        ? originalEndDate.add(const Duration(days: 1))
        : originalEndDate.subtract(const Duration(days: 1));

    final firstDate = type == 'extend' 
        ? originalEndDate.add(const Duration(days: 1))
        : DateTime.now().add(const Duration(days: 1)); // Can't shorten to a date in the past

    final lastDate = type == 'extend'
        ? originalEndDate.add(const Duration(days: 365))
        : originalEndDate.subtract(const Duration(days: 1));

    final pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate.isAfter(lastDate) ? lastDate : (initialDate.isBefore(firstDate) ? firstDate : initialDate),
      firstDate: firstDate,
      lastDate: lastDate,
      helpText: type == 'extend' ? 'SELECT NEW END DATE' : 'SELECT EARLIER RETURN DATE',
    );

    if (pickedDate == null || !context.mounted) return;

    // Calculate price diff
    final dailyRate = order.listing?.rentalDailyPrice ?? 0;
    final diffDays = pickedDate.difference(originalEndDate).inDays;
    final priceDiff = diffDays * dailyRate;
    final newTotal = order.totalPrice + priceDiff;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(type == 'extend' ? 'Confirm Extension' : 'Confirm Early Return'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Current end: ${DateFormat.yMMMd().format(originalEndDate)}'),
            Text('New end: ${DateFormat.yMMMd().format(pickedDate)}'),
            const Divider(height: 24),
            Text('Days diff: ${diffDays >= 0 ? '+' : ''}$diffDays days'),
            Text('Price diff: ${priceDiff >= 0 ? '+' : ''}\$${priceDiff.toStringAsFixed(2)}'),
            Text(
              'New Total: \$${newTotal.toStringAsFixed(2)}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Confirm')),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      await ref.read(rentalExtensionActionsProvider.notifier).requestExtension(
        orderId: order.id,
        requestedBy: order.buyerId,
        requestType: type,
        originalEndDate: originalEndDate,
        newEndDate: pickedDate,
        priceDiff: priceDiff.toDouble(),
        newTotal: newTotal,
      );
    }
  }

  Future<void> _handleApprove(BuildContext context, WidgetRef ref, RentalExtension ext) async {
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
      await ref.read(rentalExtensionActionsProvider.notifier).approveExtension(ext.id, order.id);
    }
  }

  Future<void> _handleReject(BuildContext context, WidgetRef ref, RentalExtension ext) async {
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
        order.id, 
        note: noteController.text.isEmpty ? null : noteController.text,
      );
    }
  }
}

import 'package:flutter/material.dart';
import 'package:smivo/core/theme/theme_extensions.dart';

class TransactionSnapshotModal extends StatelessWidget {
  const TransactionSnapshotModal({
    super.key,
    required this.title,
    this.orderId = 'ORD-2024-8842',
    this.buyerName = 'Alice Smith',
    this.sellerName = 'Bob Johnson',
    this.transactionTime = '2024-04-20 14:30',
    this.amount = 45.0,
    this.rentalPeriod = '3 Days (04/22 - 04/25)',
    this.pickupLocation = 'Student Union, North Entrance',
  });

  final String title;
  final String orderId;
  final String buyerName;
  final String sellerName;
  final String transactionTime;
  final double amount;
  final String? rentalPeriod;
  final String pickupLocation;

  static Future<void> show(
    BuildContext context, {
    required String title,
    String? orderId,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => TransactionSnapshotModal(title: title),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.smivoColors;
    final typo = context.smivoTypo;
    final radius = context.smivoRadius;

    return Container(
      decoration: BoxDecoration(
        color: colors.surfaceContainerLowest,
        borderRadius: BorderRadius.vertical(top: Radius.circular(radius.xl)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: colors.outlineVariant,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Transaction Snapshot',
                          style: typo.labelSmall.copyWith(
                            color: colors.primary,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.0,
                          ),
                        ),
                        Text(
                          orderId,
                          style: typo.headlineSmall.copyWith(
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                // Details Grid
                _SnapshotRow(label: 'BUYER', value: buyerName),
                Divider(height: 32, color: colors.dividerColor),
                _SnapshotRow(label: 'SELLER', value: sellerName),
                Divider(height: 32, color: colors.dividerColor),
                _SnapshotRow(label: 'TRANSACTION TIME', value: transactionTime),
                Divider(height: 32, color: colors.dividerColor),
                _SnapshotRow(
                  label: 'AMOUNT',
                  value: '\$${amount.toStringAsFixed(2)}',
                ),
                if (rentalPeriod != null) ...[
                  Divider(height: 32, color: colors.dividerColor),
                  _SnapshotRow(label: 'RENTAL PERIOD', value: rentalPeriod!),
                ],
                Divider(height: 32, color: colors.dividerColor),
                _SnapshotRow(label: 'PICKUP LOCATION', value: pickupLocation),

                const SizedBox(height: 40),

                // Seal / Certification
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: colors.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(radius.md),
                    border: Border.all(
                      color: colors.primary.withValues(alpha: 0.1),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.verified_user_outlined, color: colors.primary),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'This record is permanent and cannot be modified. It serves as official proof of transaction within Smivo.',
                          style: typo.labelSmall.copyWith(
                            color: colors.onSurface.withValues(alpha: 0.7),
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SnapshotRow extends StatelessWidget {
  const _SnapshotRow({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final colors = context.smivoColors;
    final typo = context.smivoTypo;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 120,
          child: Text(
            label,
            style: typo.labelSmall.copyWith(
              color: colors.onSurface.withValues(alpha: 0.5),
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: typo.bodyLarge.copyWith(
              color: colors.onSurface,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }
}

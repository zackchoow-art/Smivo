import 'package:flutter/material.dart';
import 'package:smivo/core/theme/app_text_styles.dart';
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
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
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
              color: Colors.grey[300],
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
                          style: AppTextStyles.labelSmall.copyWith(
                            color: const Color(0xFF013DFD),
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.0,
                          ),
                        ),
                        Text(
                          orderId,
                          style: AppTextStyles.headlineSmall.copyWith(fontWeight: FontWeight.w900),
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
                const Divider(height: 32),
                _SnapshotRow(label: 'SELLER', value: sellerName),
                const Divider(height: 32),
                _SnapshotRow(label: 'TRANSACTION TIME', value: transactionTime),
                const Divider(height: 32),
                _SnapshotRow(label: 'AMOUNT', value: '\$${amount.toStringAsFixed(2)}'),
                if (rentalPeriod != null) ...[
                  const Divider(height: 32),
                  _SnapshotRow(label: 'RENTAL PERIOD', value: rentalPeriod!),
                ],
                const Divider(height: 32),
                _SnapshotRow(label: 'PICKUP LOCATION', value: pickupLocation),
                
                const SizedBox(height: 40),
                
                // Seal / Certification
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF2EFFF),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFF013DFD).withValues(alpha: 0.1)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.verified_user_outlined, color: Color(0xFF013DFD)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'This record is permanent and cannot be modified. It serves as official proof of transaction within Smivo.',
                          style: AppTextStyles.labelSmall.copyWith(
                            color: const Color(0xFF2B2A51).withValues(alpha: 0.7),
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
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 120,
          child: Text(
            label,
            style: AppTextStyles.labelSmall.copyWith(
              color: const Color(0xFF2B2A51).withValues(alpha: 0.5),
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: AppTextStyles.bodyLarge.copyWith(
              color: const Color(0xFF2B2A51),
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }
}

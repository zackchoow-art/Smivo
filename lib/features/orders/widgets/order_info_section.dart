import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:smivo/core/theme/theme_extensions.dart';
import 'package:smivo/data/models/order.dart';

class OrderInfoSection extends StatelessWidget {
  const OrderInfoSection({
    super.key,
    required this.order,
    required this.counterpartyName,
  });

  final Order order;
  final String? counterpartyName;

  @override
  Widget build(BuildContext context) {
    final typo = context.smivoTypo;
    final isRental = order.orderType == 'rental';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Order Info', style: typo.titleMedium),
        const SizedBox(height: 8),
        // 1. Listed date
        _infoRow(context, 'Listed', _formatDate(order.createdAt)),
        // 2. Transaction type
        _infoRow(context, 'Type', isRental ? 'Rent' : 'Sale'),
        // 3. Status
        _infoRow(context, 'Status', _statusText(order.status)),
        // 4. Pickup location
        if (order.pickupLocation != null)
          _infoRow(context, 'Pickup', order.pickupLocation!.name),
        // 5. Price / Rental Total
        _infoRow(
          context,
          isRental ? 'Rental Total' : 'Price',
          '\$${order.totalPrice.toStringAsFixed(2)}',
        ),
        // NOTE: For rentals with deposit, show deposit and a Grand Total row
        if (isRental && order.depositAmount > 0) ...[ 
          _infoRow(
            context,
            'Deposit',
            '\$${order.depositAmount.toStringAsFixed(2)}',
          ),
          const Divider(),
          _infoRow(
            context,
            'Grand Total',
            '\$${(order.totalPrice + order.depositAmount).toStringAsFixed(2)}',
            isBold: true,
          ),
        ],
      ],
    );
  }

  Widget _infoRow(
    BuildContext context,
    String label,
    String value, {
    bool isBold = false,
  }) {
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
          Expanded(
            child: Text(
              value,
              style: typo.bodyMedium.copyWith(
                fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
                color: isBold ? colors.primary : null,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime dt) =>
      DateFormat('MMM d, yyyy').format(dt.toLocal());

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
      case 'missed':
        return 'Missed';
      default:
        return status;
    }
  }
}

import 'package:flutter/material.dart';
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Order Info', style: typo.titleMedium),
        const SizedBox(height: 8),
        _infoRow(context, 'Status', _statusText(order.status)),
        _infoRow(context, 'Type', order.orderType.toUpperCase()),
        _infoRow(
          context,
          'Date',
          order.createdAt.toLocal().toString().split(' ')[0],
        ),
        _infoRow(context, 'Counterparty', counterpartyName ?? 'Unknown'),
        // NOTE: Show deposit only for rental orders with non-zero deposit
        if (order.orderType == 'rental' && order.depositAmount > 0)
          _infoRow(
            context,
            'Deposit',
            '\$${order.depositAmount.toStringAsFixed(2)}',
          ),
        if (order.pickupLocation != null)
          _infoRow(context, 'Pickup', order.pickupLocation!.name),
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
}

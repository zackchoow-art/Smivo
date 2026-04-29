import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:smivo/core/theme/theme_extensions.dart';
import 'package:smivo/data/models/order.dart';

class RentalDateSection extends StatelessWidget {
  const RentalDateSection({super.key, required this.order});
  final Order order;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Duration row: computed from date range (daily / weekly / monthly)
        _infoRow(context, 'Duration', _computeRentalDuration(order)),
        _infoRow(context, 'Start', _formatDate(order.rentalStartDate!)),
        _infoRow(
          context,
          'End',
          order.rentalEndDate != null ? _formatDate(order.rentalEndDate!) : '—',
        ),
        if (order.returnConfirmedAt != null)
          _infoRow(context, 'Returned', _formatDate(order.returnConfirmedAt!)),
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

  String _formatDate(DateTime dt) =>
      DateFormat('MMM d, yyyy').format(dt.toLocal());

  /// Infers rental duration label from the date range.
  /// Priority: monthly → weekly → daily.
  String _computeRentalDuration(Order order) {
    if (order.rentalStartDate == null || order.rentalEndDate == null) {
      return '—';
    }
    final days = order.rentalEndDate!.difference(order.rentalStartDate!).inDays;
    if (days >= 30 && days % 30 == 0) {
      final months = days ~/ 30;
      return '$months Month${months > 1 ? 's' : ''}';
    }
    if (days >= 7 && days % 7 == 0) {
      final weeks = days ~/ 7;
      return '$weeks Week${weeks > 1 ? 's' : ''}';
    }
    return '$days Day${days > 1 ? 's' : ''}';
  }
}

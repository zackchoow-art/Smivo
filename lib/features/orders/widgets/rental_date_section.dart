import 'package:flutter/material.dart';
import 'package:smivo/core/theme/theme_extensions.dart';
import 'package:smivo/data/models/order.dart';

class RentalDateSection extends StatelessWidget {
  const RentalDateSection({super.key, required this.order});
  final Order order;

  @override
  Widget build(BuildContext context) {
    final typo = context.smivoTypo;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Rental Period', style: typo.titleMedium),
        const SizedBox(height: 8),
        _infoRow(
          context,
          'Start',
          order.rentalStartDate!.toLocal().toString().split(' ')[0],
        ),
        if (order.rentalEndDate != null)
          _infoRow(
            context,
            'End',
            order.rentalEndDate!.toLocal().toString().split(' ')[0],
          ),
        if (order.returnConfirmedAt != null)
          _infoRow(
            context,
            'Returned',
            order.returnConfirmedAt!.toLocal().toString().split(' ')[0],
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
}

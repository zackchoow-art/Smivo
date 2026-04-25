import 'package:flutter/material.dart';
import 'package:smivo/core/theme/theme_extensions.dart';
import 'package:smivo/data/models/order.dart';

class OrderFinancialSummary extends StatelessWidget {
  const OrderFinancialSummary({super.key, required this.order});
  final Order order;

  @override
  Widget build(BuildContext context) {
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
            'FINANCIAL SUMMARY',
            style: typo.labelSmall.copyWith(
              color: colors.onSurface.withValues(alpha: 0.5),
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 12),
          _summaryRow(context, 'Type', order.orderType.toUpperCase()),
          if (order.orderType == 'rental' && order.listing != null) ...[
            if ((order.listing!.rentalDailyPrice ?? 0) > 0)
              _summaryRow(
                context,
                'Daily Rate',
                '\$${order.listing!.rentalDailyPrice!.toStringAsFixed(2)}',
              ),
            if ((order.listing!.rentalWeeklyPrice ?? 0) > 0)
              _summaryRow(
                context,
                'Weekly Rate',
                '\$${order.listing!.rentalWeeklyPrice!.toStringAsFixed(2)}',
              ),
            if ((order.listing!.rentalMonthlyPrice ?? 0) > 0)
              _summaryRow(
                context,
                'Monthly Rate',
                '\$${order.listing!.rentalMonthlyPrice!.toStringAsFixed(2)}',
              ),
          ],
          if (order.depositAmount > 0)
            _summaryRow(
              context,
              'Deposit',
              '\$${order.depositAmount.toStringAsFixed(2)}',
            ),
          // NOTE: Rental orders display Grand Total in OrderInfoSection instead
          if (order.orderType != 'rental') ...[ 
            const Divider(),
            _summaryRow(
              context,
              'Total',
              '\$${order.totalPrice.toStringAsFixed(2)}',
              isBold: true,
            ),
          ],
        ],
      ),
    );
  }

  Widget _summaryRow(
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
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: typo.bodyMedium),
          Text(
            value,
            style: typo.bodyMedium.copyWith(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              color: isBold ? colors.primary : null,
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:smivo/core/theme/theme_extensions.dart';
import 'package:smivo/data/models/order.dart';

/// Displays the listing's pricing information at the time of order.
///
/// NOTE: This is an archival record of the item's price structure,
/// not the order's calculated total.
class OrderFinancialSummary extends StatelessWidget {
  const OrderFinancialSummary({super.key, required this.order});
  final Order order;

  @override
  Widget build(BuildContext context) {
    final colors = context.smivoColors;
    final radius = context.smivoRadius;
    final listing = order.listing;
    final isRental = order.orderType == 'rental';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(radius.lg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Sale order: show listing price
          if (!isRental) ...[
            _pricingRow(
              context,
              'Sale Price',
              '\$${order.totalPrice.toStringAsFixed(2)}',
            ),
          ],

          // Rental order: show available rental rates + deposit
          if (isRental && listing != null) ...[
            if ((listing.rentalDailyPrice ?? 0) > 0)
              _pricingRow(
                context,
                'Daily Rate',
                '\$${listing.rentalDailyPrice!.toStringAsFixed(2)} / day',
              ),
            if ((listing.rentalWeeklyPrice ?? 0) > 0)
              _pricingRow(
                context,
                'Weekly Rate',
                '\$${listing.rentalWeeklyPrice!.toStringAsFixed(2)} / week',
              ),
            if ((listing.rentalMonthlyPrice ?? 0) > 0)
              _pricingRow(
                context,
                'Monthly Rate',
                '\$${listing.rentalMonthlyPrice!.toStringAsFixed(2)} / month',
              ),
            if (order.depositAmount > 0) ...[
              const Divider(height: 16),
              _pricingRow(
                context,
                'Deposit',
                '\$${order.depositAmount.toStringAsFixed(2)}',
              ),
            ],
          ],
        ],
      ),
    );
  }

  Widget _pricingRow(BuildContext context, String label, String value) {
    final colors = context.smivoColors;
    final typo = context.smivoTypo;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: typo.bodyMedium.copyWith(color: colors.outlineVariant),
          ),
          Text(
            value,
            style: typo.bodyMedium.copyWith(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

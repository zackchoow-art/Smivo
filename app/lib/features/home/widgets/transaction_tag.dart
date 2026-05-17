import 'package:flutter/material.dart';
import 'package:smivo/core/theme/theme_extensions.dart';

class TransactionTag extends StatelessWidget {
  const TransactionTag({super.key, required this.transactionType});

  final String transactionType;

  @override
  Widget build(BuildContext context) {
    final isSale = transactionType.toLowerCase() == 'sale';
    final colors = context.smivoColors;
    final typo = context.smivoTypo;
    final radius = context.smivoRadius;

    // Use useDividers as a proxy for the Flat theme variant (Teal uses dividers, Flat doesn't)
    final isFlat = !colors.useDividers;

    // Flat (IKEA/Flat): Sale = Red (error), Rent = Pink (errorContainer)
    // Teal: Sale = Brighter Blue, Rent = Bright Teal/Cyan
    final saleColor = isFlat ? colors.error : const Color(0xFF4C73FF);
    final rentColor =
        isFlat ? colors.errorContainer : const Color(0xFF00C4B4);

    final backgroundColor = isSale ? saleColor : rentColor;
    final textColor = isSale ? Colors.white : (isFlat ? colors.onSurface : Colors.white);
    final label = isSale ? 'Sale' : 'Rent';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(radius.sm),
      ),
      child: Text(
        label,
        style: typo.labelSmall.copyWith(color: textColor, letterSpacing: 0.5),
      ),
    );
  }
}

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

    // Check if current theme is IKEA based on primary color
    final isIkea = colors.primary == const Color(0xFF004181);

    // IKEA: Sale = Blue, Rent = Bright Yellow
    // Teal: Sale = Brighter Blue, Rent = Bright Teal/Cyan
    final saleColor = isIkea ? colors.primary : const Color(0xFF4C73FF);
    final rentColor =
        isIkea ? const Color(0xFFFDD816) : const Color(0xFF00C4B4);

    final backgroundColor = isSale ? saleColor : rentColor;
    final textColor = Colors.white;
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

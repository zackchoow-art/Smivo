import 'package:flutter/material.dart';
import 'package:smivo/core/theme/theme_extensions.dart';

class TransactionTag extends StatelessWidget {
  const TransactionTag({
    super.key,
    required this.transactionType,
  });

  final String transactionType;

  @override
  Widget build(BuildContext context) {
    final isSale = transactionType.toLowerCase() == 'sale';
    final colors = context.smivoColors;
    final typo = context.smivoTypo;
    final radius = context.smivoRadius;

    // NOTE: Sale uses priceAccent (bright green in Teal, dark in IKEA);
    // Rent uses secondaryContainer (orange in Teal, yellow in IKEA).
    final backgroundColor = isSale
        ? colors.priceAccent.withValues(alpha: 0.2)
        : colors.secondaryContainer.withValues(alpha: 0.3);
    final textColor = isSale ? colors.onSurface : colors.onSurface;
    final label = isSale ? 'FOR SALE' : 'FOR RENT';

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(radius.sm),
      ),
      child: Text(
        label,
        style: typo.labelSmall.copyWith(
          color: textColor,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

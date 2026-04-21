import 'package:flutter/material.dart';
import 'package:smivo/core/theme/app_colors.dart';
import 'package:smivo/core/theme/app_spacing.dart';
import 'package:smivo/core/theme/app_text_styles.dart';

class TransactionTag extends StatelessWidget {
  const TransactionTag({
    super.key,
    required this.transactionType,
  });

  final String transactionType;

  @override
  Widget build(BuildContext context) {
    final isSale = transactionType.toLowerCase() == 'sale';
    
    // In the screenshot, "FOR SALE" uses a cyan tag and "FOR RENT" uses a purplish tag.
    // Using design system colors: primaryContainer for sale, secondaryContainer for rent, or similar.
    final backgroundColor = isSale ? const Color(0xFF00FFAA) : const Color(0xFFE2E0FF);
    final textColor = isSale ? AppColors.onSurface : const Color(0xFF2B2A51);
    final label = isSale ? 'FOR SALE' : 'FOR RENT';

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
      ),
      child: Text(
        label,
        style: AppTextStyles.labelSmall.copyWith(
          color: textColor,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

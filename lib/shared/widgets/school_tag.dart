import 'package:flutter/material.dart';

import 'package:smivo/core/theme/app_colors.dart';
import 'package:smivo/core/theme/app_spacing.dart';
import 'package:smivo/core/theme/app_text_styles.dart';

/// Displays a school name tag chip next to user info.
///
/// Shows which campus community the user belongs to.
/// Trust signal per project brief — confirms campus membership.
class SchoolTag extends StatelessWidget {
  const SchoolTag({required this.school, super.key});

  /// The school name to display (e.g. "Smith College").
  final String school;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
      ),
      child: Text(
        school,
        style: AppTextStyles.labelSmall.copyWith(
          color: AppColors.textSecondary,
        ),
      ),
    );
  }
}

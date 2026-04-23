import 'package:flutter/material.dart';
import 'package:smivo/core/theme/theme_extensions.dart';

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
    final colors = context.smivoColors;
    final typo = context.smivoTypo;
    final radius = context.smivoRadius;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(radius.sm),
      ),
      child: Text(
        school,
        style: typo.labelSmall.copyWith(
          color: colors.onSurfaceVariant,
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:smivo/core/theme/theme_extensions.dart';

/// Maps a listing condition value to a user-friendly display label.
///
/// NOTE: The IKEA design uses prominent yellow badges for item condition.
/// This widget is intentionally IKEA-specific and only used in IKEA
/// theme card variants.
String _conditionLabel(String condition) {
  switch (condition.toLowerCase()) {
    case 'new':
      return 'NEW';
    case 'like_new':
      return 'NEARLY NEW';
    case 'good':
      return 'GOOD CONDITION';
    case 'fair':
      return 'FAIR';
    case 'poor':
      return 'WELL LOVED';
    default:
      return condition.toUpperCase();
  }
}

class ConditionBadge extends StatelessWidget {
  const ConditionBadge({
    super.key,
    required this.condition,
  });

  final String condition;

  @override
  Widget build(BuildContext context) {
    final colors = context.smivoColors;
    final typo = context.smivoTypo;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        // NOTE: Uses IKEA yellow (secondaryContainer) as the badge
        // background to match the IKEA design language.
        color: colors.secondaryContainer,
        borderRadius: BorderRadius.circular(2),
      ),
      child: Text(
        _conditionLabel(condition),
        style: typo.labelSmall.copyWith(
          color: colors.onSecondaryContainer,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

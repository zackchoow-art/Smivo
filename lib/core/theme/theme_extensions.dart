import 'package:flutter/material.dart';

import 'smivo_colors.dart';
import 'smivo_radius.dart';
import 'smivo_shadows.dart';
import 'smivo_typography.dart';

export 'smivo_colors.dart';
export 'smivo_radius.dart';
export 'smivo_shadows.dart';
export 'smivo_typography.dart';

/// Convenience extensions on [BuildContext] to access Smivo theme tokens.
///
/// Usage: `context.smivoColors.primary`, `context.smivoRadius.card`, etc.
///
/// NOTE: Uses null-aware fallback instead of `!` to prevent
/// Unexpected null value crashes in edge cases (e.g. nested
/// ConsumerWidget inside TabBarView/PageView).
extension SmivoThemeExtension on BuildContext {
  /// Semantic color palette for the active theme variant.
  SmivoColors get smivoColors =>
      Theme.of(this).extension<SmivoColors>() ?? SmivoColors.teal();

  /// Border-radius tokens for the active theme variant.
  SmivoRadius get smivoRadius =>
      Theme.of(this).extension<SmivoRadius>() ?? SmivoRadius.teal();

  /// Shadow tokens for the active theme variant.
  SmivoShadows get smivoShadows =>
      Theme.of(this).extension<SmivoShadows>() ?? SmivoShadows.teal();

  /// Typography tokens for the active theme variant.
  SmivoTypography get smivoTypo =>
      Theme.of(this).extension<SmivoTypography>() ?? SmivoTypography.teal();
}

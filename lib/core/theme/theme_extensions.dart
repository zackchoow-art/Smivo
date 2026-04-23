import 'package:flutter/material.dart';

import 'smivo_colors.dart';
import 'smivo_radius.dart';
import 'smivo_shadows.dart';
import 'smivo_typography.dart';

/// Convenience extensions on [BuildContext] to access Smivo theme tokens.
///
/// Usage: `context.smivoColors.primary`, `context.smivoRadius.card`, etc.
/// These are null-safe shortcuts that avoid the verbose
/// `Theme.of(context).extension<SmivoColors>()!` pattern.
extension SmivoThemeExtension on BuildContext {
  /// Semantic color palette for the active theme variant.
  SmivoColors get smivoColors =>
      Theme.of(this).extension<SmivoColors>()!;

  /// Border-radius tokens for the active theme variant.
  SmivoRadius get smivoRadius =>
      Theme.of(this).extension<SmivoRadius>()!;

  /// Shadow tokens for the active theme variant.
  SmivoShadows get smivoShadows =>
      Theme.of(this).extension<SmivoShadows>()!;

  /// Typography tokens for the active theme variant.
  SmivoTypography get smivoTypo =>
      Theme.of(this).extension<SmivoTypography>()!;
}

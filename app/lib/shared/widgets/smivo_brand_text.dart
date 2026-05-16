import 'package:flutter/material.dart';
import 'package:smivo/core/theme/theme_extensions.dart';

/// Standardized sizes for the Smivo brand title.
enum SmivoBrandSize {
  /// 24px - Used on HomeHeader, Register, Forgot Password.
  small,

  /// 32px - Used on Admin Login, NavRail.
  medium,

  /// 48px - Used on Login screen.
  large,
}

/// A standardized widget for displaying the "Smivo" brand title.
///
/// Uses tokens from [SmivoTypography] to ensure consistent styling
/// across different themes and screens.
class SmivoBrandText extends StatelessWidget {
  const SmivoBrandText({
    super.key,
    this.size = SmivoBrandSize.medium,
    this.color,
    this.suffix,
  });

  final SmivoBrandSize size;

  /// Optional color override. If null, uses the color from the theme token
  /// (usually primary color, or onSurface for Admin).
  final Color? color;

  /// Optional text to append after "Smivo" (e.g., "Admin").
  final String? suffix;

  @override
  Widget build(BuildContext context) {
    final typo = context.smivoTypo;
    final colors = context.smivoColors;

    TextStyle style;
    switch (size) {
      case SmivoBrandSize.small:
        style = typo.brandSmall;
        break;
      case SmivoBrandSize.medium:
        style = typo.brandMedium;
        break;
      case SmivoBrandSize.large:
        style = typo.brandLarge;
        break;
    }

    // Apply color override if provided, otherwise ensure it has a color
    if (color != null) {
      style = style.copyWith(color: color);
    } else if (style.color == null) {
      style = style.copyWith(color: colors.primary);
    }

    final text = suffix != null ? 'Smivo $suffix' : 'Smivo';

    return Text(
      text,
      style: style,
    );
  }
}

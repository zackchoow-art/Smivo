import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'theme_variant.dart';

/// Typography tokens for the Smivo design system.
///
/// Teal uses Plus Jakarta Sans for headlines + Manrope for body;
/// IKEA uses Plus Jakarta Sans throughout. Labels in the IKEA theme
/// are uppercase with wider letter-spacing.
///
/// Widgets access typography via `context.smivoTypo`.
class SmivoTypography extends ThemeExtension<SmivoTypography> {
  const SmivoTypography({
    required this.displayLarge,
    required this.headlineLarge,
    required this.headlineMedium,
    required this.headlineSmall,
    required this.bodyLarge,
    required this.bodyMedium,
    required this.bodySmall,
    required this.titleMedium,
    required this.labelLarge,
    required this.labelSmall,
    required this.labelUppercase,
    required this.priceStyle,
  });

  final TextStyle displayLarge;
  final TextStyle headlineLarge;
  final TextStyle headlineMedium;
  final TextStyle headlineSmall;
  final TextStyle bodyLarge;
  final TextStyle bodyMedium;
  final TextStyle bodySmall;
  final TextStyle titleMedium;
  final TextStyle labelLarge;
  final TextStyle labelSmall;

  /// All-caps utility label (categories, statuses).
  final TextStyle labelUppercase;

  /// Price display — bright + bold in Teal, dark + extrabold in IKEA.
  final TextStyle priceStyle;

  // ── Factory: Teal ──────────────────────────────────────────
  factory SmivoTypography.teal() {
    final headline = GoogleFonts.plusJakartaSans;
    final body = GoogleFonts.manrope;
    const c = Color(0xFF181C1D);

    return SmivoTypography(
      displayLarge: headline(
        fontSize: 56,
        fontWeight: FontWeight.w800,
        color: c,
        letterSpacing: -1.12,
      ),
      headlineLarge: headline(
        fontSize: 32,
        fontWeight: FontWeight.w800,
        color: c,
        letterSpacing: -0.64,
      ),
      headlineMedium: headline(
        fontSize: 24,
        fontWeight: FontWeight.w800,
        color: c,
        letterSpacing: -0.48,
      ),
      headlineSmall: headline(
        fontSize: 20,
        fontWeight: FontWeight.w800,
        color: c,
      ),
      bodyLarge: body(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: c,
        height: 1.5,
      ),
      bodyMedium: body(fontSize: 14, fontWeight: FontWeight.w400, color: c),
      bodySmall: body(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: c.withValues(alpha: 0.7),
      ),
      titleMedium: body(fontSize: 16, fontWeight: FontWeight.w700, color: c),
      labelLarge: body(fontSize: 14, fontWeight: FontWeight.w700, color: c),
      labelSmall: body(fontSize: 10, fontWeight: FontWeight.w700, color: c),
      labelUppercase: body(
        fontSize: 10,
        fontWeight: FontWeight.w700,
        color: c,
        letterSpacing: 0.7,
      ),
      priceStyle: headline(
        fontSize: 20,
        fontWeight: FontWeight.w800,
        color: const Color(0xFF00FFAA),
      ),
    );
  }

  // ── Factory: IKEA ──────────────────────────────────────────
  factory SmivoTypography.ikea() {
    final font = GoogleFonts.plusJakartaSans;
    const c = Color(0xFF1A1C1C);

    return SmivoTypography(
      displayLarge: font(
        fontSize: 56,
        fontWeight: FontWeight.w700,
        color: c,
        letterSpacing: -1.12,
      ),
      headlineLarge: font(
        fontSize: 28,
        fontWeight: FontWeight.w600,
        color: c,
        letterSpacing: -0.56,
      ),
      headlineMedium: font(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        color: c,
        letterSpacing: -0.48,
      ),
      headlineSmall: font(fontSize: 20, fontWeight: FontWeight.w700, color: c),
      bodyLarge: font(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: c,
        height: 1.5,
      ),
      bodyMedium: font(fontSize: 14, fontWeight: FontWeight.w400, color: c),
      bodySmall: font(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: c.withValues(alpha: 0.7),
      ),
      titleMedium: font(fontSize: 16, fontWeight: FontWeight.w700, color: c),
      labelLarge: font(fontSize: 14, fontWeight: FontWeight.w700, color: c),
      labelSmall: font(fontSize: 12, fontWeight: FontWeight.w700, color: c),
      // IKEA labels are always uppercase with wider tracking
      labelUppercase: font(
        fontSize: 12,
        fontWeight: FontWeight.w700,
        color: c,
        letterSpacing: 1.2,
      ),
      priceStyle: font(
        fontSize: 20,
        fontWeight: FontWeight.w800,
        color: c,
        letterSpacing: -0.4,
      ),
    );
  }

  /// Resolve the correct typography for a given [variant].
  factory SmivoTypography.fromVariant(SmivoThemeVariant variant) {
    switch (variant) {
      case SmivoThemeVariant.teal:
        return SmivoTypography.teal();
      case SmivoThemeVariant.ikea:
        return SmivoTypography.ikea();
    }
  }

  @override
  SmivoTypography copyWith({
    TextStyle? displayLarge,
    TextStyle? headlineLarge,
    TextStyle? headlineMedium,
    TextStyle? headlineSmall,
    TextStyle? bodyLarge,
    TextStyle? bodyMedium,
    TextStyle? bodySmall,
    TextStyle? titleMedium,
    TextStyle? labelLarge,
    TextStyle? labelSmall,
    TextStyle? labelUppercase,
    TextStyle? priceStyle,
  }) {
    return SmivoTypography(
      displayLarge: displayLarge ?? this.displayLarge,
      headlineLarge: headlineLarge ?? this.headlineLarge,
      headlineMedium: headlineMedium ?? this.headlineMedium,
      headlineSmall: headlineSmall ?? this.headlineSmall,
      bodyLarge: bodyLarge ?? this.bodyLarge,
      bodyMedium: bodyMedium ?? this.bodyMedium,
      bodySmall: bodySmall ?? this.bodySmall,
      titleMedium: titleMedium ?? this.titleMedium,
      labelLarge: labelLarge ?? this.labelLarge,
      labelSmall: labelSmall ?? this.labelSmall,
      labelUppercase: labelUppercase ?? this.labelUppercase,
      priceStyle: priceStyle ?? this.priceStyle,
    );
  }

  @override
  SmivoTypography lerp(covariant SmivoTypography? other, double t) {
    if (other is! SmivoTypography) return this;
    return SmivoTypography(
      displayLarge: TextStyle.lerp(displayLarge, other.displayLarge, t)!,
      headlineLarge: TextStyle.lerp(headlineLarge, other.headlineLarge, t)!,
      headlineMedium: TextStyle.lerp(headlineMedium, other.headlineMedium, t)!,
      headlineSmall: TextStyle.lerp(headlineSmall, other.headlineSmall, t)!,
      bodyLarge: TextStyle.lerp(bodyLarge, other.bodyLarge, t)!,
      bodyMedium: TextStyle.lerp(bodyMedium, other.bodyMedium, t)!,
      bodySmall: TextStyle.lerp(bodySmall, other.bodySmall, t)!,
      titleMedium: TextStyle.lerp(titleMedium, other.titleMedium, t)!,
      labelLarge: TextStyle.lerp(labelLarge, other.labelLarge, t)!,
      labelSmall: TextStyle.lerp(labelSmall, other.labelSmall, t)!,
      labelUppercase: TextStyle.lerp(labelUppercase, other.labelUppercase, t)!,
      priceStyle: TextStyle.lerp(priceStyle, other.priceStyle, t)!,
    );
  }
}

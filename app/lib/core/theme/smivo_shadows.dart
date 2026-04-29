import 'package:flutter/material.dart';

import 'theme_variant.dart';

/// Shadow tokens for the Smivo design system.
///
/// Teal theme uses minimal shadows; IKEA uses "ambient" diffused shadows
/// as per the "Democratic Architect" design spec. Widgets access these
/// via `context.smivoShadows`.
class SmivoShadows extends ThemeExtension<SmivoShadows> {
  const SmivoShadows({
    required this.card,
    required this.elevated,
    required this.floating,
    required this.bottomNav,
  });

  /// Shadow applied to standard cards and containers.
  final List<BoxShadow> card;

  /// Shadow applied to elevated elements (e.g. FABs, modals).
  final List<BoxShadow> elevated;

  /// Shadow for floating elements (e.g. bottom action bars).
  final List<BoxShadow> floating;

  /// Shadow for the bottom navigation bar.
  final List<BoxShadow> bottomNav;

  // ── Factory: Teal (subtle / minimal) ───────────────────────
  factory SmivoShadows.teal() => const SmivoShadows(
    card: [],
    elevated: [
      BoxShadow(color: Color(0x11000000), blurRadius: 8, offset: Offset(0, 2)),
    ],
    floating: [
      BoxShadow(
        color: Color(0x18000000),
        blurRadius: 16,
        offset: Offset(0, -4),
      ),
    ],
    bottomNav: [
      BoxShadow(color: Color(0x11000000), blurRadius: 8, offset: Offset(0, -2)),
    ],
  );

  // ── Factory: IKEA (ambient / diffused) ─────────────────────
  factory SmivoShadows.ikea() => const SmivoShadows(
    card: [
      BoxShadow(
        color: Color(0x0F1A1C1C),
        blurRadius: 24,
        spreadRadius: -4,
        offset: Offset(0, 8),
      ),
    ],
    elevated: [
      BoxShadow(
        color: Color(0x0F1A1C1C),
        blurRadius: 24,
        spreadRadius: -4,
        offset: Offset(0, 8),
      ),
    ],
    floating: [
      BoxShadow(
        color: Color(0x0F1A1C1C),
        blurRadius: 24,
        spreadRadius: -4,
        offset: Offset(0, -8),
      ),
    ],
    bottomNav: [
      BoxShadow(
        color: Color(0x0F1A1C1C),
        blurRadius: 24,
        spreadRadius: -4,
        offset: Offset(0, -8),
      ),
    ],
  );

  /// Resolve the correct shadows for a given [variant].
  factory SmivoShadows.fromVariant(SmivoThemeVariant variant) {
    switch (variant) {
      case SmivoThemeVariant.teal:
        return SmivoShadows.teal();
      case SmivoThemeVariant.ikea:
        return SmivoShadows.ikea();
    }
  }

  @override
  SmivoShadows copyWith({
    List<BoxShadow>? card,
    List<BoxShadow>? elevated,
    List<BoxShadow>? floating,
    List<BoxShadow>? bottomNav,
  }) {
    return SmivoShadows(
      card: card ?? this.card,
      elevated: elevated ?? this.elevated,
      floating: floating ?? this.floating,
      bottomNav: bottomNav ?? this.bottomNav,
    );
  }

  @override
  SmivoShadows lerp(covariant SmivoShadows? other, double t) {
    if (other is! SmivoShadows) return this;
    // BoxShadow lists don't lerp cleanly; snap at midpoint.
    return t < 0.5 ? this : other;
  }
}

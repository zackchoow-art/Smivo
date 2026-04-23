import 'dart:ui';

import 'package:flutter/material.dart';

import 'theme_variant.dart';

/// Semantic border-radius tokens for the Smivo design system.
///
/// Teal theme uses rounded, pill-like corners; IKEA theme uses
/// near-right-angle "architectural" corners. Widgets access these
/// via `context.smivoRadius`.
class SmivoRadius extends ThemeExtension<SmivoRadius> {
  const SmivoRadius({
    required this.xs,
    required this.sm,
    required this.md,
    required this.lg,
    required this.xl,
    required this.full,
    required this.card,
    required this.button,
    required this.input,
    required this.chip,
    required this.avatar,
    required this.image,
    required this.bottomSheet,
    required this.dialog,
  });

  final double xs;
  final double sm;
  final double md;
  final double lg;
  final double xl;
  final double full;

  // Semantic aliases for specific components
  final double card;
  final double button;
  final double input;
  final double chip;
  final double avatar;
  final double image;
  final double bottomSheet;
  final double dialog;

  /// Helper to get a [BorderRadius.circular] from a token value.
  BorderRadius circularXs() => BorderRadius.circular(xs);
  BorderRadius circularSm() => BorderRadius.circular(sm);
  BorderRadius circularMd() => BorderRadius.circular(md);
  BorderRadius circularLg() => BorderRadius.circular(lg);
  BorderRadius circularXl() => BorderRadius.circular(xl);
  BorderRadius circularFull() => BorderRadius.circular(full);
  BorderRadius circularCard() => BorderRadius.circular(card);
  BorderRadius circularButton() => BorderRadius.circular(button);
  BorderRadius circularInput() => BorderRadius.circular(input);
  BorderRadius circularChip() => BorderRadius.circular(chip);
  BorderRadius circularAvatar() => BorderRadius.circular(avatar);
  BorderRadius circularImage() => BorderRadius.circular(image);
  BorderRadius circularBottomSheet() => BorderRadius.circular(bottomSheet);
  BorderRadius circularDialog() => BorderRadius.circular(dialog);

  // ── Factory: Teal (rounded) ────────────────────────────────
  factory SmivoRadius.teal() => const SmivoRadius(
        xs: 4,
        sm: 8,
        md: 12,
        lg: 16,
        xl: 24,
        full: 999,
        card: 16,
        button: 12,
        input: 12,
        chip: 999,
        avatar: 999,
        image: 12,
        bottomSheet: 24,
        dialog: 16,
      );

  // ── Factory: IKEA (architectural / sharp) ──────────────────
  factory SmivoRadius.ikea() => const SmivoRadius(
        xs: 2,
        sm: 2,
        md: 4,
        lg: 4,
        xl: 8,
        full: 12,
        card: 4,
        button: 2,
        input: 2,
        chip: 2,
        avatar: 999, // Avatars stay round in both themes
        image: 4,
        bottomSheet: 8,
        dialog: 8,
      );

  /// Resolve the correct radii for a given [variant].
  factory SmivoRadius.fromVariant(SmivoThemeVariant variant) {
    switch (variant) {
      case SmivoThemeVariant.teal:
        return SmivoRadius.teal();
      case SmivoThemeVariant.ikea:
        return SmivoRadius.ikea();
    }
  }

  @override
  SmivoRadius copyWith({
    double? xs,
    double? sm,
    double? md,
    double? lg,
    double? xl,
    double? full,
    double? card,
    double? button,
    double? input,
    double? chip,
    double? avatar,
    double? image,
    double? bottomSheet,
    double? dialog,
  }) {
    return SmivoRadius(
      xs: xs ?? this.xs,
      sm: sm ?? this.sm,
      md: md ?? this.md,
      lg: lg ?? this.lg,
      xl: xl ?? this.xl,
      full: full ?? this.full,
      card: card ?? this.card,
      button: button ?? this.button,
      input: input ?? this.input,
      chip: chip ?? this.chip,
      avatar: avatar ?? this.avatar,
      image: image ?? this.image,
      bottomSheet: bottomSheet ?? this.bottomSheet,
      dialog: dialog ?? this.dialog,
    );
  }

  @override
  SmivoRadius lerp(covariant SmivoRadius? other, double t) {
    if (other is! SmivoRadius) return this;
    return SmivoRadius(
      xs: lerpDouble(xs, other.xs, t)!,
      sm: lerpDouble(sm, other.sm, t)!,
      md: lerpDouble(md, other.md, t)!,
      lg: lerpDouble(lg, other.lg, t)!,
      xl: lerpDouble(xl, other.xl, t)!,
      full: lerpDouble(full, other.full, t)!,
      card: lerpDouble(card, other.card, t)!,
      button: lerpDouble(button, other.button, t)!,
      input: lerpDouble(input, other.input, t)!,
      chip: lerpDouble(chip, other.chip, t)!,
      avatar: lerpDouble(avatar, other.avatar, t)!,
      image: lerpDouble(image, other.image, t)!,
      bottomSheet: lerpDouble(bottomSheet, other.bottomSheet, t)!,
      dialog: lerpDouble(dialog, other.dialog, t)!,
    );
  }
}

import 'package:flutter/material.dart';

import 'color_scheme_variant.dart';
import 'theme_variant.dart';

/// Semantic color tokens for the Smivo design system.
///
/// Injected as a [ThemeExtension] so that every widget can resolve
/// colours from the active theme variant via `context.smivoColors`.
///
/// The palette is resolved by [fromVariantAndScheme], which combines
/// a structural theme variant (teal / flat) with a color scheme
/// (default / rosé / pastel / sage).
class SmivoColors extends ThemeExtension<SmivoColors> {
  const SmivoColors({
    // Brand
    required this.primary,
    required this.primaryContainer,
    required this.secondary,
    required this.secondaryContainer,
    required this.tertiary,
    required this.onPrimary,
    required this.onSecondaryContainer,
    // Surfaces
    required this.background,
    required this.surface,
    required this.surfaceContainerLowest,
    required this.surfaceContainerLow,
    required this.surfaceContainer,
    required this.surfaceContainerHigh,
    required this.surfaceContainerHighest,
    required this.surfaceBright,
    // Text & elements
    required this.onSurface,
    required this.onSurfaceVariant,
    required this.outline,
    required this.outlineVariant,
    // Semantic status
    required this.error,
    required this.errorContainer,
    required this.success,
    required this.successContainer,
    required this.warning,
    required this.warningContainer,
    // Specialised
    required this.priceAccent,
    required this.priceAccentContainer,
    required this.settingsIcon,
    required this.settingsIconBg,
    required this.settingsText,
    required this.settingsTextSecondary,
    // Gradients & decorations
    required this.gradientStart,
    required this.gradientEnd,
    required this.secondaryGradientStart,
    required this.secondaryGradientEnd,
    required this.dividerColor,
    required this.useDividers,
    // Borders
    required this.borderLight,
    // Bottom nav
    required this.navActiveBackground,
    required this.navActiveIcon,
    // Chat
    required this.chatBubbleSelf,
    required this.chatBubbleOther,
    required this.chatBubbleTextSelf,
    required this.chatBubbleTextOther,
    // Order status badges
    required this.statusConfirmed,
    required this.statusCompleted,
    required this.statusPending,
    required this.statusCancelled,
    // Shadow base
    required this.shadow,
  });

  // ── Brand ──────────────────────────────────────────────────
  final Color primary;
  final Color primaryContainer;
  final Color secondary;
  final Color secondaryContainer;
  final Color tertiary;
  final Color onPrimary;
  final Color onSecondaryContainer;

  // ── Surfaces ───────────────────────────────────────────────
  final Color background;
  final Color surface;
  final Color surfaceContainerLowest;
  final Color surfaceContainerLow;
  final Color surfaceContainer;
  final Color surfaceContainerHigh;
  final Color surfaceContainerHighest;
  final Color surfaceBright;

  // ── Text & Elements ────────────────────────────────────────
  final Color onSurface;
  final Color onSurfaceVariant;
  final Color outline;
  final Color outlineVariant;

  // ── Semantic Status ────────────────────────────────────────
  final Color error;
  final Color errorContainer;
  final Color success;
  final Color successContainer;
  final Color warning;
  final Color warningContainer;

  // ── Specialised ────────────────────────────────────────────
  final Color priceAccent;
  final Color priceAccentContainer;
  final Color settingsIcon;
  final Color settingsIconBg;
  final Color settingsText;
  final Color settingsTextSecondary;

  // ── Gradients & Decorations ────────────────────────────────
  final Color gradientStart;
  final Color gradientEnd;
  final Color secondaryGradientStart;
  final Color secondaryGradientEnd;
  final Color dividerColor;

  /// Whether 1px divider lines are used in this theme.
  /// Teal uses traditional dividers; Flat replaces them with whitespace.
  final bool useDividers;

  // ── Borders ────────────────────────────────────────────────
  final Color borderLight;

  // ── Bottom Navigation ──────────────────────────────────────
  final Color navActiveBackground;
  final Color navActiveIcon;

  // ── Chat ───────────────────────────────────────────────────
  final Color chatBubbleSelf;
  final Color chatBubbleOther;
  final Color chatBubbleTextSelf;
  final Color chatBubbleTextOther;

  // ── Order Status Badges ────────────────────────────────────
  final Color statusConfirmed;
  final Color statusCompleted;
  final Color statusPending;
  final Color statusCancelled;

  // ── Shadow ─────────────────────────────────────────────────
  final Color shadow;

  // ── Factory: Teal (current brand) ──────────────────────────
  factory SmivoColors.teal() => const SmivoColors(
    // Brand
    primary: Color(0xFF2D5BFF),
    primaryContainer: Color(0xFF1E40ED),
    secondary: Color(0xFF646681),
    secondaryContainer: Color(0xFFE5EBFF),
    tertiary: Color(0xFF2B2A51),
    onPrimary: Color(0xFFFFFFFF),
    onSecondaryContainer: Color(0xFF2B2A51),
    // Surfaces
    background: Color(0xFFFAF8FE),
    surface: Color(0xFFFAF8FE),
    surfaceContainerLowest: Color(0xFFFFFFFF),
    surfaceContainerLow: Color(0xFFF4F3FA),
    surfaceContainer: Color(0xFFEAEAFA),
    surfaceContainerHigh: Color(0xFFE0E0F5),
    surfaceContainerHighest: Color(0xFFD5D5ED),
    surfaceBright: Color(0xFFFAF8FE),
    // Text & elements
    onSurface: Color(0xFF2B2A51),
    onSurfaceVariant: Color(0xFF646681),
    outline: Color(0xFFB4B6C8),
    outlineVariant: Color(0xFFDCDDE5),
    // Semantic
    error: Color(0xFFEF4444),
    errorContainer: Color(0xFFFFDAD6),
    success: Color(0xFF2E7D32),
    successContainer: Color(0xFFCCF7E5),
    warning: Color(0xFFE65100),
    warningContainer: Color(0xFFFFBBAA),
    // Specialised — bright neon price accents for Teal theme
    priceAccent: Color(0xFF2D5BFF),
    priceAccentContainer: Color(0xFFE5EBFF),
    settingsIcon: Color(0xFF2D5BFF),
    settingsIconBg: Color(0xFFF4F3FA),
    settingsText: Color(0xFF2B2A51),
    settingsTextSecondary: Color(0xFF646681),
    // Gradients
    gradientStart: Color(0xFF2D5BFF),
    gradientEnd: Color(0xFF4C73FF),
    secondaryGradientStart: Color(0xFF7B2FF7),
    secondaryGradientEnd: Color(0xFFA855F7),
    dividerColor: Color(0xFFDCDDE5),
    useDividers: true,
    // Borders
    borderLight: Color(0xFFE0E0F5),
    // Nav
    navActiveBackground: Color(0xFF2D5BFF),
    navActiveIcon: Color(0xFFFFFFFF),
    // Chat
    chatBubbleSelf: Color(0xFF2D5BFF),
    chatBubbleOther: Color(0xFFF4F3FA),
    chatBubbleTextSelf: Color(0xFFFFFFFF),
    chatBubbleTextOther: Color(0xFF2B2A51),
    // Status badges
    statusConfirmed: Color(0xFF00FFCC),
    statusCompleted: Color(0xFFDCD2FE),
    statusPending: Color(0xFFFFBBAA),
    statusCancelled: Color(0xFFEF4444),
    // Shadow
    shadow: Color(0x11000000),
  );

  // ── Factory: Flat (blue + yellow flat) ─────────────────────
  factory SmivoColors.flat() => const SmivoColors(
    // Brand
    primary: Color(0xFF004181),
    primaryContainer: Color(0xFF0058AB),
    secondary: Color(0xFF6F5D00),
    secondaryContainer: Color(0xFFFDD816),
    tertiary: Color(0xFF702D00),
    onPrimary: Color(0xFFFFFFFF),
    onSecondaryContainer: Color(0xFF705E00),
    // Surfaces — neutral warm grays
    background: Color(0xFFF9F9F9),
    surface: Color(0xFFF9F9F9),
    surfaceContainerLowest: Color(0xFFFFFFFF),
    surfaceContainerLow: Color(0xFFF3F3F3),
    surfaceContainer: Color(0xFFEEEEEE),
    surfaceContainerHigh: Color(0xFFE8E8E8),
    surfaceContainerHighest: Color(0xFFE2E2E2),
    surfaceBright: Color(0xFFF9F9F9),
    // Text & elements
    onSurface: Color(0xFF1A1C1C),
    onSurfaceVariant: Color(0xFF424752),
    outline: Color(0xFF727783),
    outlineVariant: Color(0xFFC2C6D3),
    // Semantic — same across themes
    error: Color(0xFFBA1A1A),
    errorContainer: Color(0xFFFFDAD6),
    success: Color(0xFF2E7D32),
    successContainer: Color(0xFFCCF7E5),
    warning: Color(0xFFE65100),
    warningContainer: Color(0xFFFFBBAA),
    // Specialised — dark bold price for Flat
    priceAccent: Color(0xFF1A1C1C),
    priceAccentContainer: Color(0xFF1A1C1C),
    settingsIcon: Color(0xFF004181),
    settingsIconBg: Color(0xFFF3F3F3),
    settingsText: Color(0xFF1A1C1C),
    settingsTextSecondary: Color(0xFF424752),
    // Gradients — Flat uses flat solid colors, no gradient
    gradientStart: Color(0xFF004181),
    gradientEnd: Color(0xFF004181),
    secondaryGradientStart: Color(0xFF004181),
    secondaryGradientEnd: Color(0xFF0058AB),
    dividerColor: Color(0xFFC2C6D3),
    useDividers: false,
    // Borders
    borderLight: Color(0xFFE8E8E8),
    // Nav — yellow highlight pill
    navActiveBackground: Color(0xFFFDD816),
    navActiveIcon: Color(0xFF004181),
    // Chat
    chatBubbleSelf: Color(0xFF004181),
    chatBubbleOther: Color(0xFFF3F3F3),
    chatBubbleTextSelf: Color(0xFFFFFFFF),
    chatBubbleTextOther: Color(0xFF1A1C1C),
    // Status badges
    statusConfirmed: Color(0xFF00FFCC),
    statusCompleted: Color(0xFFE8E8E8),
    statusPending: Color(0xFFFDD816),
    statusCancelled: Color(0xFFFF6666),
    // Shadow
    shadow: Color(0x0F1A1C1C),
  );

  /// Resolve the correct palette for a given [variant] (default scheme).
  factory SmivoColors.fromVariant(SmivoThemeVariant variant) {
    switch (variant) {
      case SmivoThemeVariant.teal:
        return SmivoColors.teal();
      case SmivoThemeVariant.flat:
        return SmivoColors.flat();
    }
  }

  /// Resolve the palette for a [variant] + [scheme] combination.
  ///
  /// The [variant] determines structural properties (useDividers, shadow
  /// opacity), while [scheme] determines the hue palette.
  factory SmivoColors.fromVariantAndScheme(
    SmivoThemeVariant variant,
    SmivoColorScheme scheme,
  ) {
    if (scheme == SmivoColorScheme.defaultScheme) {
      return SmivoColors.fromVariant(variant);
    }
    return switch (scheme) {
      SmivoColorScheme.rose => _buildRose(variant),
      SmivoColorScheme.pastel => _buildPastel(variant),
      SmivoColorScheme.sage => _buildSage(variant),
      SmivoColorScheme.defaultScheme => SmivoColors.fromVariant(variant),
    };
  }

  // ── Palette: Rosé (warm dusty rose + peach + cream) ────────
  static SmivoColors _buildRose(SmivoThemeVariant variant) {
    final isTeal = variant == SmivoThemeVariant.teal;
    return SmivoColors(
      primary: const Color(0xFFA57480),
      primaryContainer: const Color(0xFF8E5F6A),
      secondary: const Color(0xFFD4A373),
      secondaryContainer: const Color(0xFFF5E0D0),
      tertiary: const Color(0xFF6B4150),
      onPrimary: const Color(0xFFFFFFFF),
      onSecondaryContainer: const Color(0xFF5C3A28),
      background: const Color(0xFFFDF6F3),
      surface: const Color(0xFFFDF6F3),
      surfaceContainerLowest: const Color(0xFFFFFFFF),
      surfaceContainerLow: const Color(0xFFFBF1ED),
      surfaceContainer: const Color(0xFFF5E8E2),
      surfaceContainerHigh: const Color(0xFFEFDDD6),
      surfaceContainerHighest: const Color(0xFFE9D2CA),
      surfaceBright: const Color(0xFFFDF6F3),
      onSurface: const Color(0xFF3D2B2B),
      onSurfaceVariant: const Color(0xFF7D6060),
      outline: const Color(0xFFBDA0A0),
      outlineVariant: const Color(0xFFE0CCCC),
      error: const Color(0xFFBA1A1A),
      errorContainer: const Color(0xFFFFDAD6),
      success: const Color(0xFF2E7D32),
      successContainer: const Color(0xFFCCF7E5),
      warning: const Color(0xFFE65100),
      warningContainer: const Color(0xFFFFBBAA),
      priceAccent:
          isTeal ? const Color(0xFFA57480) : const Color(0xFF3D2B2B),
      priceAccentContainer: const Color(0xFFF5E0D0),
      settingsIcon: const Color(0xFFA57480),
      settingsIconBg: const Color(0xFFFBF1ED),
      settingsText: const Color(0xFF3D2B2B),
      settingsTextSecondary: const Color(0xFF7D6060),
      gradientStart: const Color(0xFFA57480),
      gradientEnd:
          isTeal ? const Color(0xFFC9A0A8) : const Color(0xFFA57480),
      secondaryGradientStart: const Color(0xFFD4A373),
      secondaryGradientEnd: const Color(0xFFE0B899),
      dividerColor: const Color(0xFFE0CCCC),
      useDividers: isTeal,
      borderLight: const Color(0xFFEFDDD6),
      navActiveBackground:
          isTeal ? const Color(0xFFA57480) : const Color(0xFFF5E0D0),
      navActiveIcon:
          isTeal ? const Color(0xFFFFFFFF) : const Color(0xFFA57480),
      chatBubbleSelf: const Color(0xFFA57480),
      chatBubbleOther: const Color(0xFFFBF1ED),
      chatBubbleTextSelf: const Color(0xFFFFFFFF),
      chatBubbleTextOther: const Color(0xFF3D2B2B),
      statusConfirmed: const Color(0xFFFFB4C2),
      statusCompleted:
          isTeal ? const Color(0xFFF5E0D0) : const Color(0xFFEFDDD6),
      statusPending: const Color(0xFFFFD4A3),
      statusCancelled: const Color(0xFFEF4444),
      shadow: isTeal
          ? const Color(0x11000000)
          : const Color(0x0F3D2B2B),
    );
  }

  // ── Palette: Pastel (pink + sky blue + butter + lavender) ──
  static SmivoColors _buildPastel(SmivoThemeVariant variant) {
    final isTeal = variant == SmivoThemeVariant.teal;
    return SmivoColors(
      primary: const Color(0xFF8B7EC8),
      primaryContainer: const Color(0xFF7568B5),
      secondary: const Color(0xFFE8A0BF),
      secondaryContainer: const Color(0xFFF9E4ED),
      tertiary: const Color(0xFF5B5087),
      onPrimary: const Color(0xFFFFFFFF),
      onSecondaryContainer: const Color(0xFF5A3248),
      background: const Color(0xFFF9F7FE),
      surface: const Color(0xFFF9F7FE),
      surfaceContainerLowest: const Color(0xFFFFFFFF),
      surfaceContainerLow: const Color(0xFFF5F2FB),
      surfaceContainer: const Color(0xFFEDEAF7),
      surfaceContainerHigh: const Color(0xFFE4E0F2),
      surfaceContainerHighest: const Color(0xFFDAD5EB),
      surfaceBright: const Color(0xFFF9F7FE),
      onSurface: const Color(0xFF2B2640),
      onSurfaceVariant: const Color(0xFF6B6485),
      outline: const Color(0xFFA9A2C0),
      outlineVariant: const Color(0xFFD6D0E8),
      error: const Color(0xFFBA1A1A),
      errorContainer: const Color(0xFFFFDAD6),
      success: const Color(0xFF2E7D32),
      successContainer: const Color(0xFFCCF7E5),
      warning: const Color(0xFFE65100),
      warningContainer: const Color(0xFFFFBBAA),
      priceAccent:
          isTeal ? const Color(0xFF8B7EC8) : const Color(0xFF2B2640),
      priceAccentContainer: const Color(0xFFF9E4ED),
      settingsIcon: const Color(0xFF8B7EC8),
      settingsIconBg: const Color(0xFFF5F2FB),
      settingsText: const Color(0xFF2B2640),
      settingsTextSecondary: const Color(0xFF6B6485),
      gradientStart: const Color(0xFF8B7EC8),
      gradientEnd:
          isTeal ? const Color(0xFFB0A5DC) : const Color(0xFF8B7EC8),
      secondaryGradientStart: const Color(0xFFE8A0BF),
      secondaryGradientEnd: const Color(0xFFF0BCCF),
      dividerColor: const Color(0xFFD6D0E8),
      useDividers: isTeal,
      borderLight: const Color(0xFFE4E0F2),
      navActiveBackground:
          isTeal ? const Color(0xFF8B7EC8) : const Color(0xFFF9E4ED),
      navActiveIcon:
          isTeal ? const Color(0xFFFFFFFF) : const Color(0xFF8B7EC8),
      chatBubbleSelf: const Color(0xFF8B7EC8),
      chatBubbleOther: const Color(0xFFF5F2FB),
      chatBubbleTextSelf: const Color(0xFFFFFFFF),
      chatBubbleTextOther: const Color(0xFF2B2640),
      statusConfirmed: const Color(0xFFB5D8EB),
      statusCompleted:
          isTeal ? const Color(0xFFE0D5F5) : const Color(0xFFE4E0F2),
      statusPending: const Color(0xFFF5E6B8),
      statusCancelled: const Color(0xFFEF4444),
      shadow: isTeal
          ? const Color(0x11000000)
          : const Color(0x0F2B2640),
    );
  }

  // ── Palette: Sage (sage green + blush + cream + taupe) ─────
  static SmivoColors _buildSage(SmivoThemeVariant variant) {
    final isTeal = variant == SmivoThemeVariant.teal;
    return SmivoColors(
      primary: const Color(0xFF7D8B6E),
      primaryContainer: const Color(0xFF6B7A5E),
      secondary: const Color(0xFFB49082),
      secondaryContainer: const Color(0xFFF0EAD6),
      tertiary: const Color(0xFF5A6650),
      onPrimary: const Color(0xFFFFFFFF),
      onSecondaryContainer: const Color(0xFF4A3830),
      background: const Color(0xFFF7F5EF),
      surface: const Color(0xFFF7F5EF),
      surfaceContainerLowest: const Color(0xFFFFFFFF),
      surfaceContainerLow: const Color(0xFFF2F0EA),
      surfaceContainer: const Color(0xFFECE9E0),
      surfaceContainerHigh: const Color(0xFFE5E2D7),
      surfaceContainerHighest: const Color(0xFFDDDACE),
      surfaceBright: const Color(0xFFF7F5EF),
      onSurface: const Color(0xFF2D2D25),
      onSurfaceVariant: const Color(0xFF6B6B5A),
      outline: const Color(0xFFA5A590),
      outlineVariant: const Color(0xFFD5D5C5),
      error: const Color(0xFFBA1A1A),
      errorContainer: const Color(0xFFFFDAD6),
      success: const Color(0xFF2E7D32),
      successContainer: const Color(0xFFCCF7E5),
      warning: const Color(0xFFE65100),
      warningContainer: const Color(0xFFFFBBAA),
      priceAccent:
          isTeal ? const Color(0xFF7D8B6E) : const Color(0xFF2D2D25),
      priceAccentContainer: const Color(0xFFF0EAD6),
      settingsIcon: const Color(0xFF7D8B6E),
      settingsIconBg: const Color(0xFFF2F0EA),
      settingsText: const Color(0xFF2D2D25),
      settingsTextSecondary: const Color(0xFF6B6B5A),
      gradientStart: const Color(0xFF7D8B6E),
      gradientEnd:
          isTeal ? const Color(0xFFA0AD90) : const Color(0xFF7D8B6E),
      secondaryGradientStart: const Color(0xFFB49082),
      secondaryGradientEnd: const Color(0xFFC8A898),
      dividerColor: const Color(0xFFD5D5C5),
      useDividers: isTeal,
      borderLight: const Color(0xFFE5E2D7),
      navActiveBackground:
          isTeal ? const Color(0xFF7D8B6E) : const Color(0xFFF0EAD6),
      navActiveIcon:
          isTeal ? const Color(0xFFFFFFFF) : const Color(0xFF7D8B6E),
      chatBubbleSelf: const Color(0xFF7D8B6E),
      chatBubbleOther: const Color(0xFFF2F0EA),
      chatBubbleTextSelf: const Color(0xFFFFFFFF),
      chatBubbleTextOther: const Color(0xFF2D2D25),
      statusConfirmed: const Color(0xFFB8D4A8),
      statusCompleted:
          isTeal ? const Color(0xFFF0EAD6) : const Color(0xFFE5E2D7),
      statusPending: const Color(0xFFE8D4B8),
      statusCancelled: const Color(0xFFEF4444),
      shadow: isTeal
          ? const Color(0x11000000)
          : const Color(0x0F2D2D25),
    );
  }


  @override
  SmivoColors copyWith({
    Color? primary,
    Color? primaryContainer,
    Color? secondary,
    Color? secondaryContainer,
    Color? tertiary,
    Color? onPrimary,
    Color? onSecondaryContainer,
    Color? background,
    Color? surface,
    Color? surfaceContainerLowest,
    Color? surfaceContainerLow,
    Color? surfaceContainer,
    Color? surfaceContainerHigh,
    Color? surfaceContainerHighest,
    Color? surfaceBright,
    Color? onSurface,
    Color? onSurfaceVariant,
    Color? outline,
    Color? outlineVariant,
    Color? error,
    Color? errorContainer,
    Color? success,
    Color? successContainer,
    Color? warning,
    Color? warningContainer,
    Color? priceAccent,
    Color? priceAccentContainer,
    Color? settingsIcon,
    Color? settingsIconBg,
    Color? settingsText,
    Color? settingsTextSecondary,
    Color? gradientStart,
    Color? gradientEnd,
    Color? secondaryGradientStart,
    Color? secondaryGradientEnd,
    Color? dividerColor,
    bool? useDividers,
    Color? borderLight,
    Color? navActiveBackground,
    Color? navActiveIcon,
    Color? chatBubbleSelf,
    Color? chatBubbleOther,
    Color? chatBubbleTextSelf,
    Color? chatBubbleTextOther,
    Color? statusConfirmed,
    Color? statusCompleted,
    Color? statusPending,
    Color? statusCancelled,
    Color? shadow,
  }) {
    return SmivoColors(
      primary: primary ?? this.primary,
      primaryContainer: primaryContainer ?? this.primaryContainer,
      secondary: secondary ?? this.secondary,
      secondaryContainer: secondaryContainer ?? this.secondaryContainer,
      tertiary: tertiary ?? this.tertiary,
      onPrimary: onPrimary ?? this.onPrimary,
      onSecondaryContainer: onSecondaryContainer ?? this.onSecondaryContainer,
      background: background ?? this.background,
      surface: surface ?? this.surface,
      surfaceContainerLowest:
          surfaceContainerLowest ?? this.surfaceContainerLowest,
      surfaceContainerLow: surfaceContainerLow ?? this.surfaceContainerLow,
      surfaceContainer: surfaceContainer ?? this.surfaceContainer,
      surfaceContainerHigh: surfaceContainerHigh ?? this.surfaceContainerHigh,
      surfaceContainerHighest:
          surfaceContainerHighest ?? this.surfaceContainerHighest,
      surfaceBright: surfaceBright ?? this.surfaceBright,
      onSurface: onSurface ?? this.onSurface,
      onSurfaceVariant: onSurfaceVariant ?? this.onSurfaceVariant,
      outline: outline ?? this.outline,
      outlineVariant: outlineVariant ?? this.outlineVariant,
      error: error ?? this.error,
      errorContainer: errorContainer ?? this.errorContainer,
      success: success ?? this.success,
      successContainer: successContainer ?? this.successContainer,
      warning: warning ?? this.warning,
      warningContainer: warningContainer ?? this.warningContainer,
      priceAccent: priceAccent ?? this.priceAccent,
      priceAccentContainer: priceAccentContainer ?? this.priceAccentContainer,
      settingsIcon: settingsIcon ?? this.settingsIcon,
      settingsIconBg: settingsIconBg ?? this.settingsIconBg,
      settingsText: settingsText ?? this.settingsText,
      settingsTextSecondary:
          settingsTextSecondary ?? this.settingsTextSecondary,
      gradientStart: gradientStart ?? this.gradientStart,
      gradientEnd: gradientEnd ?? this.gradientEnd,
      secondaryGradientStart:
          secondaryGradientStart ?? this.secondaryGradientStart,
      secondaryGradientEnd: secondaryGradientEnd ?? this.secondaryGradientEnd,
      dividerColor: dividerColor ?? this.dividerColor,
      useDividers: useDividers ?? this.useDividers,
      borderLight: borderLight ?? this.borderLight,
      navActiveBackground: navActiveBackground ?? this.navActiveBackground,
      navActiveIcon: navActiveIcon ?? this.navActiveIcon,
      chatBubbleSelf: chatBubbleSelf ?? this.chatBubbleSelf,
      chatBubbleOther: chatBubbleOther ?? this.chatBubbleOther,
      chatBubbleTextSelf: chatBubbleTextSelf ?? this.chatBubbleTextSelf,
      chatBubbleTextOther: chatBubbleTextOther ?? this.chatBubbleTextOther,
      statusConfirmed: statusConfirmed ?? this.statusConfirmed,
      statusCompleted: statusCompleted ?? this.statusCompleted,
      statusPending: statusPending ?? this.statusPending,
      statusCancelled: statusCancelled ?? this.statusCancelled,
      shadow: shadow ?? this.shadow,
    );
  }

  @override
  SmivoColors lerp(covariant SmivoColors? other, double t) {
    if (other is! SmivoColors) return this;
    return SmivoColors(
      primary: Color.lerp(primary, other.primary, t)!,
      primaryContainer:
          Color.lerp(primaryContainer, other.primaryContainer, t)!,
      secondary: Color.lerp(secondary, other.secondary, t)!,
      secondaryContainer:
          Color.lerp(secondaryContainer, other.secondaryContainer, t)!,
      tertiary: Color.lerp(tertiary, other.tertiary, t)!,
      onPrimary: Color.lerp(onPrimary, other.onPrimary, t)!,
      onSecondaryContainer:
          Color.lerp(onSecondaryContainer, other.onSecondaryContainer, t)!,
      background: Color.lerp(background, other.background, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      surfaceContainerLowest:
          Color.lerp(surfaceContainerLowest, other.surfaceContainerLowest, t)!,
      surfaceContainerLow:
          Color.lerp(surfaceContainerLow, other.surfaceContainerLow, t)!,
      surfaceContainer:
          Color.lerp(surfaceContainer, other.surfaceContainer, t)!,
      surfaceContainerHigh:
          Color.lerp(surfaceContainerHigh, other.surfaceContainerHigh, t)!,
      surfaceContainerHighest:
          Color.lerp(
            surfaceContainerHighest,
            other.surfaceContainerHighest,
            t,
          )!,
      surfaceBright: Color.lerp(surfaceBright, other.surfaceBright, t)!,
      onSurface: Color.lerp(onSurface, other.onSurface, t)!,
      onSurfaceVariant:
          Color.lerp(onSurfaceVariant, other.onSurfaceVariant, t)!,
      outline: Color.lerp(outline, other.outline, t)!,
      outlineVariant: Color.lerp(outlineVariant, other.outlineVariant, t)!,
      error: Color.lerp(error, other.error, t)!,
      errorContainer: Color.lerp(errorContainer, other.errorContainer, t)!,
      success: Color.lerp(success, other.success, t)!,
      successContainer:
          Color.lerp(successContainer, other.successContainer, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      warningContainer:
          Color.lerp(warningContainer, other.warningContainer, t)!,
      priceAccent: Color.lerp(priceAccent, other.priceAccent, t)!,
      priceAccentContainer:
          Color.lerp(priceAccentContainer, other.priceAccentContainer, t)!,
      settingsIcon: Color.lerp(settingsIcon, other.settingsIcon, t)!,
      settingsIconBg: Color.lerp(settingsIconBg, other.settingsIconBg, t)!,
      settingsText: Color.lerp(settingsText, other.settingsText, t)!,
      settingsTextSecondary:
          Color.lerp(settingsTextSecondary, other.settingsTextSecondary, t)!,
      gradientStart: Color.lerp(gradientStart, other.gradientStart, t)!,
      gradientEnd: Color.lerp(gradientEnd, other.gradientEnd, t)!,
      secondaryGradientStart:
          Color.lerp(secondaryGradientStart, other.secondaryGradientStart, t)!,
      secondaryGradientEnd:
          Color.lerp(secondaryGradientEnd, other.secondaryGradientEnd, t)!,
      dividerColor: Color.lerp(dividerColor, other.dividerColor, t)!,
      useDividers: t < 0.5 ? useDividers : other.useDividers,
      borderLight: Color.lerp(borderLight, other.borderLight, t)!,
      navActiveBackground:
          Color.lerp(navActiveBackground, other.navActiveBackground, t)!,
      navActiveIcon: Color.lerp(navActiveIcon, other.navActiveIcon, t)!,
      chatBubbleSelf: Color.lerp(chatBubbleSelf, other.chatBubbleSelf, t)!,
      chatBubbleOther: Color.lerp(chatBubbleOther, other.chatBubbleOther, t)!,
      chatBubbleTextSelf:
          Color.lerp(chatBubbleTextSelf, other.chatBubbleTextSelf, t)!,
      chatBubbleTextOther:
          Color.lerp(chatBubbleTextOther, other.chatBubbleTextOther, t)!,
      statusConfirmed: Color.lerp(statusConfirmed, other.statusConfirmed, t)!,
      statusCompleted: Color.lerp(statusCompleted, other.statusCompleted, t)!,
      statusPending: Color.lerp(statusPending, other.statusPending, t)!,
      statusCancelled: Color.lerp(statusCancelled, other.statusCancelled, t)!,
      shadow: Color.lerp(shadow, other.shadow, t)!,
    );
  }
}

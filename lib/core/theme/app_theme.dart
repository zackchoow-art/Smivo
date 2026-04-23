import 'package:flutter/material.dart';

import 'smivo_colors.dart';
import 'smivo_radius.dart';
import 'smivo_shadows.dart';
import 'smivo_typography.dart';
import 'theme_variant.dart';

/// Centralized ThemeData factory for the Smivo app.
///
/// Call [buildTheme] with a [SmivoThemeVariant] to produce a fully
/// configured [ThemeData] with all four Smivo [ThemeExtension]s
/// (colors, radii, shadows, typography) injected.
///
/// The old static [lightTheme] getter is kept for backward compatibility
/// during the migration period but delegates to the new system.
class AppTheme {
  AppTheme._();

  /// Build a complete [ThemeData] for the given [variant].
  ///
  /// This is the single entry point used by [MaterialApp.theme].
  /// All component themes (buttons, inputs, cards, nav) are derived
  /// from the variant's token set so they stay in sync automatically.
  static ThemeData buildTheme(SmivoThemeVariant variant) {
    final colors = SmivoColors.fromVariant(variant);
    final radius = SmivoRadius.fromVariant(variant);
    final shadows = SmivoShadows.fromVariant(variant);
    final typo = SmivoTypography.fromVariant(variant);

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.fromSeed(
        seedColor: colors.primary,
        brightness: Brightness.light,
        surface: colors.surface,
        error: colors.error,
      ),
      scaffoldBackgroundColor: colors.background,

      // ── AppBar ───────────────────────────────────────────
      appBarTheme: AppBarTheme(
        backgroundColor: colors.surface,
        foregroundColor: colors.onSurface,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: typo.headlineSmall,
      ),

      // ── ElevatedButton ───────────────────────────────────
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colors.primary,
          foregroundColor: colors.onPrimary,
          minimumSize: const Size(double.infinity, 48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radius.button),
          ),
          textStyle: typo.labelLarge,
        ),
      ),

      // ── OutlinedButton ───────────────────────────────────
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: colors.primary,
          minimumSize: const Size(double.infinity, 48),
          side: BorderSide(color: colors.primary),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radius.button),
          ),
          textStyle: typo.labelLarge,
        ),
      ),

      // ── InputDecoration ──────────────────────────────────
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colors.surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radius.input),
          borderSide: BorderSide(color: colors.outlineVariant),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radius.input),
          borderSide: BorderSide(color: colors.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radius.input),
          borderSide: BorderSide(color: colors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radius.input),
          borderSide: BorderSide(color: colors.error),
        ),
        hintStyle: typo.bodyMedium.copyWith(
          color: colors.onSurfaceVariant,
        ),
      ),

      // ── Card ─────────────────────────────────────────────
      cardTheme: CardThemeData(
        color: colors.surfaceContainerLowest,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radius.card),
          side: colors.useDividers
              ? BorderSide(color: colors.outlineVariant)
              : BorderSide.none,
        ),
      ),

      // ── Divider ──────────────────────────────────────────
      dividerTheme: DividerThemeData(
        color: colors.useDividers
            ? colors.dividerColor
            : Colors.transparent,
        thickness: colors.useDividers ? 1 : 0,
        space: colors.useDividers ? 1 : 0,
      ),

      // ── BottomNavigationBar ──────────────────────────────
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: colors.surfaceContainerLowest,
        selectedItemColor: colors.primary,
        unselectedItemColor: colors.onSurfaceVariant,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),

      // ── Extensions ───────────────────────────────────────
      extensions: [colors, radius, shadows, typo],
    );
  }

  /// Legacy getter for backward compatibility during migration.
  ///
  /// Delegates to [buildTheme] with [SmivoThemeVariant.teal].
  /// Widgets and tests that still reference [AppTheme.lightTheme]
  /// will continue to work unchanged.
  @Deprecated('Use AppTheme.buildTheme(variant) instead. '
      'This getter will be removed after the theme migration.')
  static ThemeData get lightTheme => buildTheme(SmivoThemeVariant.teal);
}

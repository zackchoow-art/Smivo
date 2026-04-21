import 'package:flutter/material.dart';

/// Centralized color palette for the Smivo brand, matching Stitch MCP.
class AppColors {
  AppColors._();

  // ── Brand ──────────────────────────────────────────────────
  static const Color primary = Color(0xFF006067);
  static const Color primaryContainer = Color(0xFF007b83);
  static const Color secondary = Color(0xFF8b5000);
  static const Color secondaryContainer = Color(0xFFff9800);
  static const Color tertiary = Color(0xFF6f5200);

  // ── Surfaces ───────────────────────────────────────────────
  static const Color background = Color(0xFFf6fafa);
  static const Color surfaceContainerLow = Color(0xFFf1f4f4);
  static const Color surfaceContainerLowest = Color(0xFFffffff);
  static const Color surfaceContainerHigh = Color(0xFFe5e9e9);
  static const Color surfaceBright = Color(0xFFf6fafa); // Used for glassmorphism base

  // ── Text & Elements ────────────────────────────────────────
  static const Color onSurface = Color(0xFF181c1d);
  static const Color onPrimary = Color(0xFFffffff);
  static const Color outlineVariant = Color(0xFFbdc9ca); // Ghost borders

  // ── Aliases for backwards compatibility ─────────────────────
  static const Color surface = surfaceContainerLowest;
  static const Color textPrimary = onSurface;
  static const Color textSecondary = outlineVariant; // approximating
  static const Color textTertiary = outlineVariant;
  static const Color textOnPrimary = onPrimary;
  static const Color border = outlineVariant;
  static const Color borderLight = outlineVariant;
  static const Color divider = outlineVariant;
  static const Color inputBackground = surfaceContainerLow;
  static const Color gradientStart = primary;
  static const Color gradientEnd = primaryContainer;
  static const Color linkText = primary;

  // ── Semantic ───────────────────────────────────────────────
  static const Color error = Color(0xFFba1a1a);
  static const Color priceTagPrimary = Color(0xFF0546ED);
  static const Color priceTagSuccess = Color(0xFF00FFAA);
}

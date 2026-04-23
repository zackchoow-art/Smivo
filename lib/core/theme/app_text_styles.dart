import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// Typography system based on the Stitch Design System.
class AppTextStyles {
  AppTextStyles._();

  // ── Headlines (The Voice) ──────────────────────────────────
  static TextStyle get displayLarge => GoogleFonts.plusJakartaSans(
        fontSize: 56,
        fontWeight: FontWeight.w800,
        color: AppColors.onSurface,
        letterSpacing: -1.12, // -0.02em * 56
      );
      
  static TextStyle get headlineLarge => GoogleFonts.plusJakartaSans(
        fontSize: 32,
        fontWeight: FontWeight.w800,
        color: AppColors.onSurface,
        letterSpacing: -0.64,
      );

  static TextStyle get headlineMedium => GoogleFonts.plusJakartaSans(
        fontSize: 24,
        fontWeight: FontWeight.w800,
        color: AppColors.onSurface,
        letterSpacing: -0.48,
      );
      
  static TextStyle get headlineSmall => GoogleFonts.plusJakartaSans(
        fontSize: 20,
        fontWeight: FontWeight.w800,
        color: AppColors.onSurface,
      );

  // ── Body & Labels (The Narrative) ──────────────────────────
  static TextStyle get bodyLarge => GoogleFonts.manrope(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: AppColors.onSurface,
        height: 1.5,
      );

  static TextStyle get bodyMedium => GoogleFonts.manrope(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: AppColors.onSurface,
      );

  static TextStyle get bodySmall => GoogleFonts.manrope(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: AppColors.onSurface.withValues(alpha: 0.7),
      );

  static TextStyle get titleMedium => GoogleFonts.manrope(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: AppColors.onSurface,
      );

  static TextStyle get labelLarge => GoogleFonts.manrope(
        fontSize: 14,
        fontWeight: FontWeight.w700,
        color: AppColors.onSurface,
      );

  static TextStyle get labelSmall => GoogleFonts.manrope(
        fontSize: 10,
        fontWeight: FontWeight.w700,
        color: AppColors.onSurface,
      );

  // ── Aliases for backwards compatibility ────────────────────
  static TextStyle get logo => displayLarge.copyWith(fontStyle: FontStyle.italic, color: AppColors.primary);
  static TextStyle get linkText => bodyMedium.copyWith(color: AppColors.primary, fontWeight: FontWeight.w600);
  static TextStyle get buttonLarge => labelLarge.copyWith(color: AppColors.onPrimary, fontSize: 18);
  static TextStyle get buttonSecondary => labelLarge.copyWith(color: AppColors.primary, fontSize: 16);
  static TextStyle get footerText => bodySmall;
  static TextStyle get labelUppercase => labelSmall.copyWith(letterSpacing: 0.7);
}

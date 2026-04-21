/// Spacing constants for consistent padding and margins.
///
/// Uses a 4-point grid system. All spacing values are multiples of 4
/// for visual harmony and alignment.
class AppSpacing {
  AppSpacing._();

  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 20.0;
  static const double xxl = 24.0;
  static const double xxxl = 32.0;
  static const double huge = 48.0;

  // ── Radii ──────────────────────────────────────────────────
  static const double radiusSm = 8.0;
  static const double radiusMd = 12.0;
  static const double radiusLg = 16.0;
  static const double radiusXl = 24.0;
  static const double radiusFull = 999.0;

  // ── Touch Targets ──────────────────────────────────────────
  /// Minimum touch target per Apple HIG (44pt).
  static const double minTouchTarget = 44.0;
}

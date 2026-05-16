/// Available color scheme variants for the Smivo app.
///
/// Color schemes are orthogonal to [SmivoThemeVariant]. The theme variant
/// controls structural tokens (radius, shadows, typography, dividers),
/// while the color scheme controls the hue palette.
///
/// Each theme variant × color scheme combination produces a unique
/// [SmivoColors] instance via [SmivoColors.fromVariantAndScheme].
enum SmivoColorScheme {
  /// Uses the default palette of the active theme variant
  /// (blue-purple for Teal, blue-yellow for Flat).
  defaultScheme,

  /// Warm dusty rose + peach + cream palette.
  rose,

  /// Soft pastel: pink, sky blue, butter yellow, lavender.
  pastel,

  /// Earthy sage green + blush pink + cream + warm taupe.
  sage,
}

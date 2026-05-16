# Audit Report: "Smivo" Brand Title Usage (Task I-1)

## Objective
Find all occurrences of the text "Smivo" displayed in the UI across the entire Flutter app codebase and document the exact styling applied to each one.

## Findings Table

| File Path | Line # | Widget Type | Font Family | Font Size | Font Weight | Italic? | Color | Notes |
|-----------|--------|-------------|-------------|-----------|-------------|---------|-------|-------|
| `features/home/widgets/home_header.dart` | 39 | `Text` | Plus Jakarta Sans | 24 | w800 | No | `colors.primary` | Uses `typo.headlineMedium` without overrides. |
| `features/auth/screens/login_screen.dart` | 241 | `Text` | Plus Jakarta Sans | 48 | w800 | Yes | `colors.primary` | Uses `typo.displayLarge` with hardcoded `fontSize: 48` and `italic` overrides. |
| `features/auth/screens/register_screen.dart` | 269 | `Text` | Plus Jakarta Sans | 24 | w800 | Yes | `colors.primary` | Uses `typo.displayLarge` with hardcoded `fontSize: 24` and `italic` overrides. |
| `features/auth/screens/forgot_password_screen.dart` | 154 | `Text` | Plus Jakarta Sans | 24 | w800 | Yes | `colors.primary` | Uses `typo.displayLarge` with hardcoded `fontSize: 24` and `italic` overrides. |
| `features/admin/screens/admin_login_screen.dart` | 73 | `Text` | Plus Jakarta Sans | 32 | w900 | No | `colors.onSurface` | "Smivo Admin"; Uses `typo.headlineLarge` with `w900` override. |
| `features/admin/screens/admin_login_screen.dart` | 186 | `Text` | Manrope (def) | 14 (def) | normal | No | `primary` (def) | "Back to Smivo" inside `TextButton.icon`. |
| `features/admin/screens/admin_shell_screen.dart` | 224 | `Text` | Manrope | 16 | w800 | No | `colors.onSurface` | "Smivo Admin"; Uses `typo.titleMedium` with `w800` override. |
| `features/admin/screens/admin_shell_screen.dart` | 299 | `Text` | Manrope | 16 | w800 | No | Default | "Smivo Admin" in Drawer; Uses `typo.titleMedium` with `w800` override. |
| `shared/widgets/navigation_rail_bar.dart` | 66 | `Text` | Plus Jakarta Sans | 32 | Bold | Yes | `colors.primary` | Uses `typo.headlineLarge` with `bold`, `italic`, and `letterSpacing: -0.5` overrides. |

## Summary of Variations
There are **4 distinct styles** currently used for the Smivo brand name:

1.  **Display Brand (Auth)**: Uses `displayLarge` base with `italic` and varying sizes (24px and 48px). This is the most "logo-like" version.
2.  **Header Brand (Home)**: Uses `headlineMedium` (24px) without italics. Clean and integrated into the app bar area.
3.  **Admin Brand**: Uses `headlineLarge` or `titleMedium` with extra heavy weights (w800/w900) but no italics. Often coupled with the "Admin" text.
4.  **Navigation Brand (Rail)**: Uses `headlineLarge` with `bold`, `italic`, and custom `letterSpacing`.

## Recommendation
To ensure brand consistency across all platforms and themes (Teal vs. Flat), I recommend the following:

1.  **Standardize Typography Tokens**: Add dedicated brand tokens to `SmivoTypography` (e.g., `brandLarge` and `brandSmall`) that include the `FontStyle.italic` and correct `FontWeight` by default.
2.  **Create a Unified Widget**: Implement a `SmivoBrandText` (or `SmivoLogo`) widget in `shared/widgets/` that accepts a `size` enum (Small, Medium, Large) and handles all styling internally using theme tokens.
3.  **Canonical Style**: The style used in `LoginScreen` (Italic, Plus Jakarta Sans, ExtraBold) should be considered the canonical "Smivo" brand style, as it most closely matches the intended logo aesthetic.

## Additional Notes
- `AppTextStyles` contains a deprecated `.logo` alias that is currently not used by the new `SmivoThemeExtension` system. This should be consolidated into the new system.
- `AppConstants.appName` is defined but rarely used in `Text` widgets, leading to potential typos or inconsistent casing if changed in the future.

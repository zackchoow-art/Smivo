# Smivo Theme Architecture

> **Last updated**: 2026-04-23  
> **Status**: Production — all screens migrated to this system

## Overview

Smivo supports runtime theme switching between two visual variants: **Teal** (rounded, bright) and **IKEA Flat** (sharp corners, deep blue + yellow). The entire design system is built on Flutter's `ThemeExtension` mechanism, with four custom extension classes injected into `ThemeData`.

---

## File Map

All theme files live under `lib/core/theme/`:

| File | Purpose | Key Exports |
|---|---|---|
| `theme_variant.dart` | Enum defining available themes | `SmivoThemeVariant { teal, ikea }` |
| `smivo_colors.dart` | ~40 semantic color tokens | `SmivoColors` (factories: `.teal()`, `.ikea()`) |
| `smivo_radius.dart` | 14 border-radius tokens | `SmivoRadius` (factories: `.teal()`, `.ikea()`) |
| `smivo_typography.dart` | Typography scale tokens | `SmivoTypography` (factories: `.teal()`, `.ikea()`) |
| `smivo_shadows.dart` | Shadow tokens | `SmivoShadows` (factories: `.teal()`, `.ikea()`) |
| `theme_extensions.dart` | Convenience `BuildContext` getters | `context.smivoColors`, `.smivoRadius`, `.smivoTypo`, `.smivoShadows` |
| `app_theme.dart` | ThemeData factory | `AppTheme.buildTheme(SmivoThemeVariant)` |

### State Management

| File | Purpose |
|---|---|
| `lib/core/providers/theme_provider.dart` | `ThemeNotifier` — Riverpod provider that persists variant to `SharedPreferences` |

### App Entry Point

| File | Purpose |
|---|---|
| `lib/app.dart` | `ref.watch(themeNotifierProvider)` → `AppTheme.buildTheme(variant)` → `MaterialApp.theme` |

---

## Data Flow

```
User taps theme switcher (System Settings)
        │
        ▼
ref.read(themeNotifierProvider.notifier).setTheme(SmivoThemeVariant.ikea)
        │
        ├── Updates Riverpod state (triggers rebuild)
        └── Persists to SharedPreferences (survives restart)
        │
        ▼
app.dart: ref.watch(themeNotifierProvider) → SmivoThemeVariant.ikea
        │
        ▼
AppTheme.buildTheme(SmivoThemeVariant.ikea)
        │
        ├── SmivoColors.ikea()      → color tokens
        ├── SmivoRadius.ikea()      → radius tokens
        ├── SmivoTypography.ikea()  → type tokens
        └── SmivoShadows.ikea()     → shadow tokens
        │
        ▼
ThemeData(extensions: [colors, radius, shadows, typo])
        │
        ▼
MaterialApp.theme = themeData
        │
        ▼
All widgets rebuild with new tokens via context.smivoColors, etc.
```

---

## How Widgets Access Tokens

Import `theme_extensions.dart` and use the `BuildContext` extensions:

```dart
import 'package:smivo/core/theme/theme_extensions.dart';

// In any widget's build method:
final colors = context.smivoColors;   // SmivoColors
final typo   = context.smivoTypo;     // SmivoTypography
final radius = context.smivoRadius;   // SmivoRadius
final shadow = context.smivoShadows;  // SmivoShadows

// Usage examples:
Container(
  decoration: BoxDecoration(
    color: colors.surfaceContainerLow,
    borderRadius: BorderRadius.circular(radius.card),
  ),
);

Text('Hello', style: typo.titleMedium.copyWith(color: colors.primary));

ElevatedButton(
  style: ElevatedButton.styleFrom(
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(radius.button),
    ),
  ),
);
```

---

## Token Categories

### Colors (`SmivoColors`)

| Category | Tokens |
|---|---|
| Brand | `primary`, `primaryContainer`, `secondary`, `secondaryContainer`, `tertiary`, `onPrimary`, `onSecondaryContainer` |
| Surface | `background`, `surface`, `surfaceContainerLowest`, `surfaceContainerLow`, `surfaceContainer`, `surfaceContainerHigh`, `surfaceContainerHighest`, `surfaceBright` |
| Text | `onSurface`, `onSurfaceVariant`, `outline`, `outlineVariant` |
| Status | `error`, `errorContainer`, `success`, `successContainer`, `warning`, `warningContainer`, `statusPending`, `statusConfirmed`, `statusCancelled` |
| Special | `priceAccent`, `priceAccentContainer`, `settingsIcon`, `settingsIconBg`, `settingsText`, `settingsTextSecondary` |
| Decoration | `gradientStart`, `gradientEnd`, `shimmerBase`, `shimmerHighlight`, `dividerColor`, `useDividers` (bool) |

### Radius (`SmivoRadius`)

| Token | Teal | IKEA | Semantic Use |
|---|---|---|---|
| `xs` | 4 | 2 | Tiny elements |
| `sm` | 8 | 2 | Small containers |
| `md` | 12 | 4 | Medium containers |
| `lg` | 16 | 4 | Large containers |
| `xl` | 24 | 8 | Extra-large |
| `full` | 999 | 12 | Pills/badges |
| `card` | 16 | 4 | Card containers |
| `button` | 12 | 2 | All buttons |
| `input` | 12 | 2 | Text fields, dropdowns |
| `chip` | 999 | 2 | Filter chips |
| `avatar` | 999 | 999 | Always circular |
| `image` | 12 | 4 | Image thumbnails |
| `bottomSheet` | 24 | 8 | Bottom sheets |
| `dialog` | 16 | 8 | Alert dialogs |

### Typography (`SmivoTypography`)

Provides: `headlineLarge`, `headlineMedium`, `headlineSmall`, `titleLarge`, `titleMedium`, `bodyLarge`, `bodyMedium`, `bodySmall`, `labelLarge`, `labelSmall`

### Shadows (`SmivoShadows`)

Provides: `card`, `elevated`, `modal` — each returns a `List<BoxShadow>`

---

## Adding a New Theme

1. Add a new value to `SmivoThemeVariant` enum in `theme_variant.dart`
2. Add a new factory constructor in each of the 4 token classes:
   - `SmivoColors.newTheme()`
   - `SmivoRadius.newTheme()`
   - `SmivoTypography.newTheme()`
   - `SmivoShadows.newTheme()`
3. Update the `fromVariant()` switch in each class
4. Add a new `ButtonSegment` in `system_settings_screen.dart`

No other files need to change — the architecture is fully variant-driven.

---

## Modifying an Existing Theme

**To change colors**: Edit the corresponding factory in `smivo_colors.dart`  
**To change radii**: Edit the corresponding factory in `smivo_radius.dart`  
**To change fonts**: Edit the corresponding factory in `smivo_typography.dart`  
**To change shadows**: Edit the corresponding factory in `smivo_shadows.dart`

Changes take effect immediately for all widgets using the token system.

---

## Rules for New Widgets

1. **Never** import `app_colors.dart`, `app_text_styles.dart`, or `app_spacing.dart` — these are legacy dead code
2. **Never** hardcode `Color(0xFF...)` or `BorderRadius.circular(12)` — always use tokens
3. **Always** import `theme_extensions.dart` and use `context.smivoColors`, etc.
4. Use **semantic tokens** for component-specific radii:
   - Buttons → `radius.button`
   - Cards/containers → `radius.card`
   - Inputs/dropdowns → `radius.input`
   - Chips → `radius.chip`
   - Images → `radius.image`
5. Use generic scale tokens (`radius.sm`, `radius.md`) only for non-standard elements

---

## Theme Switcher UI

Located in: `lib/features/settings/screens/system_settings_screen.dart`

Uses a `SegmentedButton<SmivoThemeVariant>` in the Display section.  
Reads: `ref.watch(themeNotifierProvider)`  
Writes: `ref.read(themeNotifierProvider.notifier).setTheme(variant)`

Selection is persisted to `SharedPreferences` under key `smivo_theme_variant`.

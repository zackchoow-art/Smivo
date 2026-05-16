# Audit Report: Home Header School Name Styling (Task I-6)

## Objective
Find the school name text in the Home page header and compare its styling between Teal and Flat theme variants, specifically checking for visual weight consistency.

## Findings
The school name is displayed in the `HomeHeader` widget using the `headlineLarge` typography token. Currently, there is no conditional logic to differentiate the styling between theme variants in the widget itself; both themes rely on the default values provided by the `SmivoTypography` extension.

### Detailed Location
- **File**: `lib/features/home/widgets/home_header.dart`
- **Line**: 44-51
- **Widget**: `Text(schoolName, ...)`

### Current Implementation
```dart
44:                     Text(
45:                       schoolName,
46:                       style: typo.headlineLarge.copyWith(
47:                         color: colors.secondaryGradientStart,
48:                       ),
49:                       maxLines: 1,
50:                       overflow: TextOverflow.ellipsis,
51:                     ),
```

### Theme Variant Comparison
| Theme Variant | `headlineLarge` Base Weight | `secondaryGradientStart` Color | Visual Assessment |
|---------------|---------------------------|-------------------------------|-------------------|
| **Teal**      | `w800` (Extra Bold)       | `#00FFE0` (Bright Cyan)      | High contrast and weight. |
| **Flat**      | `w600` (Semi-Bold)        | `#FFD700` (Yellow)           | Lighter weight; needs bold for parity. |

### Analysis
The Flat theme variant uses a significantly lighter font weight (`w600`) for the `headlineLarge` token compared to the Teal theme (`w800`). In the Flat theme, the school name is rendered in yellow (`#FFD700`) on a light background, which requires additional font weight to maintain readability and visual hierarchy.

---

## Audit Deliverable

**File**: `home_header.dart`
**Line**: 46-48
**Teal style**: `style: typo.headlineLarge.copyWith(color: colors.secondaryGradientStart)` (Result: `w800`)
**Flat style**: `style: typo.headlineLarge.copyWith(color: colors.secondaryGradientStart)` (Result: `w600`)
**Proposed fix**:
Add a conditional branch to ensure the Flat theme uses a bolder weight for the school name.

```dart
style: typo.headlineLarge.copyWith(
  color: colors.secondaryGradientStart,
  fontWeight: ref.watch(themeProvider) == SmivoThemeVariant.flat 
      ? FontWeight.w700 
      : null,
),
```

**Note**: This change will require importing `theme_provider.dart` and `theme_variant.dart` in `home_header.dart`.

# Theme Refactor Audit Report

This report documents the current state of theme coverage and identifies hardcoded design values that need to be centralized into the theme system for the Smivo app.

---

## Part 1: Current Theme Coverage

### lib/core/theme/app_colors.dart
- **Defined**: Brand colors (`primary`, `secondary`, `tertiary`), Surface colors (`background`, `surfaceContainerLow/Lowest/High`, `surfaceBright`), Text & Elements (`onSurface`, `onPrimary`, `outlineVariant`), and various aliases for backward compatibility.
- **Missing**: Specific semantic colors for "Success", "Warning", and "Info" (currently only `error` is defined). Missing specific colors for "Rental" vs "Sale" tags which are hardcoded in multiple places.

### lib/core/theme/app_text_styles.dart
- **Defined**: Headlines (`displayLarge`, `headlineLarge/Medium/Small`), Body & Labels (`bodyLarge/Medium/Small`, `titleMedium`, `labelLarge/Small`), and aliases (`logo`, `linkText`, `buttonLarge/Secondary`).
- **Missing**: A clear mapping to `ThemeData.textTheme`. Some styles use hardcoded `GoogleFonts` properties that might vary if not carefully managed. Missing specific styles for "Caption" and "Overline".

### lib/core/theme/app_theme.dart
- **Defined**: `lightTheme` configuring `useMaterial3`, `colorScheme`, `scaffoldBackgroundColor`, `appBarTheme`, `elevatedButtonTheme`, `outlinedButtonTheme`, `inputDecorationTheme`, `cardTheme`, `dividerTheme`, `bottomNavigationBarTheme`.
- **Missing**: 
  - `TextButtonThemeData`
  - `ChipThemeData`
  - `FloatingActionButtonThemeData`
  - `DialogTheme`
  - `PopupMenuThemeData`
  - `SnackBarThemeData`

### lib/core/theme/app_spacing.dart
- **Defined**: Spacing constants (`xs` to `huge`), Radii constants (`radiusSm` to `radiusFull` as doubles), and touch targets.
- **Missing**: Centralized `BorderRadius` objects (e.g., `AppRadius.md`) and `BoxShadow` constants.

---

## Part 2: Hardcoded Value Inventory

### 2A. Hardcoded Colors
- **Count**: ~350 occurrences.
- **Common Patterns**:
  - `Color(0xFF2B2A51)` (Dark Blue): Used extensively in `create_listing_form_screen.dart` and `listing_detail_screen.dart`.
  - `Color(0xFF0546ED)` (Vibrant Blue): Used for primary actions and location icons.
  - `Color(0xFFF2EFFF)` (Lavender): Used as input backgrounds and container fills.
  - `Color(0xFF585781)` (Muted Blue): Used for secondary text and icons.
  - `Colors.white`, `Colors.black`, `Colors.green` (for success).

### 2B. Hardcoded Border Radius
- **Count**: ~75 occurrences.
- **Common Patterns**:
  - `BorderRadius.circular(24)`: Dominant for main action buttons and auth cards.
  - `BorderRadius.circular(16)`: Common for cards and feature images.
  - `BorderRadius.circular(12)`: Standard for inputs and smaller buttons.
  - `BorderRadius.circular(8)`: Used for status tags and small UI elements.

### 2C. Hardcoded Shadows
- **Count**: 19 occurrences.
- **Common Patterns**:
  - Most are standard `BoxShadow` with `offset: Offset(0, 4)` and `blurRadius: 10` or similar. Used for "elevated" feel on cards and bottom navigation.

### 2D. Hardcoded Text Styles
- **Count**: ~120 occurrences.
- **Common Patterns**:
  - `fontSize: 32/36`: Large titles in listing and auth screens.
  - `fontWeight: FontWeight.w800/w900`: Heavy emphasis for headlines and badges.
  - `letterSpacing: 0.5/1.0`: Often applied to labels and uppercase text.

### 2E. Hardcoded Border Widths
- **Count**: ~25 occurrences.
- **Common Patterns**:
  - `width: 2`: Common for active state borders (inputs, selected categories).
  - `width: 1`: Standard border for cards and dividers.

---

## Part 3: Aggregation

| Category | Total Occurrences | Top 5 Affected Files | Dominant Design Pattern |
| :--- | :--- | :--- | :--- |
| **Colors** | ~350 | `create_listing_form_screen.dart`, `listing_detail_screen.dart`, `listing_image_carousel.dart`, `custom_text_field.dart`, `app_text_field.dart` | Dark Blue (`0xFF2B2A51`) & Vibrant Blue (`0xFF0546ED`) |
| **Border Radius** | ~75 | `login_screen.dart`, `register_screen.dart`, `chat_popup.dart`, `order_card.dart`, `orders_screen.dart` | `circular(24)` for Auth, `circular(16)` for Cards |
| **Shadows** | 19 | `email_verification_screen.dart`, `login_screen.dart`, `chat_popup.dart`, `edit_profile_screen.dart`, `settings_screen.dart` | Standard elevation (Blur 10, Y-Offset 4) |
| **Text Styles** | ~120 | `listing_detail_screen.dart`, `transaction_snapshot_modal.dart`, `orders_screen.dart`, `create_listing_form_screen.dart`, `bottom_nav_bar.dart` | Heavy headlines (`w800+`), letter-spaced labels |
| **Border Widths** | ~25 | `message_badge_icon.dart`, `photo_picker_section.dart`, `order_card.dart`, `chat_popup.dart`, `home_header.dart` | `width: 2` for emphasis, `width: 1` for default |

---

## Part 4: Refactor Plan

### Step 1: Create Missing Theme Constants
1.  **`lib/core/theme/app_radius.dart`**:
    - `AppRadius.xs = BorderRadius.circular(4)`
    - `AppRadius.sm = BorderRadius.circular(8)`
    - `AppRadius.md = BorderRadius.circular(12)`
    - `AppRadius.lg = BorderRadius.circular(16)`
    - `AppRadius.xl = BorderRadius.circular(24)`
    - `AppRadius.xxl = BorderRadius.circular(32)`
2.  **`lib/core/theme/app_shadows.dart`**:
    - `AppShadows.card`: Standard elevation for list items.
    - `AppShadows.elevated`: Higher elevation for buttons and popups.
    - `AppShadows.subtle`: Light shadow for input fields or ghost elements.

### Step 2: Centralize Existing Scattered Values
- **HIGH PRIORITY (Estimated 120 mins)**:
  - `lib/features/listing/screens/create_listing_form_screen.dart` (Replace ~25 colors/text styles)
  - `lib/features/listing/screens/listing_detail_screen.dart` (Replace ~20 colors/text styles)
  - `lib/features/auth/screens/login_screen.dart` & `register_screen.dart` (Centralize radii and shadows)
- **MEDIUM PRIORITY (Estimated 90 mins)**:
  - `lib/features/orders/widgets/order_card.dart`
  - `lib/features/chat/widgets/chat_popup.dart`
  - `lib/shared/widgets/app_text_field.dart`
- **LOW PRIORITY (Estimated 60 mins)**:
  - Shared icons, badges, and minor settings screens.

### Step 3: ThemeData Integration
Update `lib/core/theme/app_theme.dart` to include:
- `textButtonTheme`
- `chipTheme`
- `floatingActionButtonThemeData`
- `dialogTheme`
- `popupMenuTheme`

---

## Part 5: Final Verdict

1.  **How many total hardcoded values need refactoring?**
    - Approximately **580+** total occurrences across all categories.
2.  **How many files are affected?**
    - Roughly **45-50 files** in the `lib/` directory.
3.  **Total estimated refactor time?**
    - **4.5 - 6 hours** (assuming a focused manual refactor or semi-automated replacement).
4.  **After refactor, will changing 4 files be enough?**
    - **YES**, mostly. By centralizing values into `app_colors.dart`, `app_text_styles.dart`, `app_radius.dart`, and `app_shadows.dart`, and ensuring `ThemeData` consumes them, the entire app's skin can be swapped. However, some layout-specific colors (like custom gradients) may still need one-off checks.
5.  **Any blockers or edge cases?**
    - **Stitch Design Sync**: The hardcoded `0xFF2B2A51` and `0xFF0546ED` colors seem to be specific to current Stitch designs but aren't in `AppColors`. They should be added as brand colors.
    - **Opacity Modifiers**: Many places use `.withOpacity()`. These should be converted to specific color tokens (e.g., `AppColors.onSurfaceVariant`) where possible to avoid runtime opacity calculations and maintain consistency.
    - **Third-party Widgets**: Some packages might have their own styling systems that don't fully respect `ThemeData`.

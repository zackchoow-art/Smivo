# DEFERRED — Theme Refactor Plan

> [!IMPORTANT]
> 此任务已暂时搁置，将在 Listings, Chat, and Orders 功能集成完成后恢复执行。

## 1. Audit Findings (Step 1)

### AppColors Token Usage
| Token Name | Count | Key Files |
| :--- | :--- | :--- |
| `AppColors.primary` | 42 | `listing_detail_screen.dart`, `order_card.dart` |
| `AppColors.onSurface` | 38 | `rental_options_section.dart`, `list_order_card.dart` |
| `AppColors.background` | 12 | `home_screen.dart`, `login_screen.dart` |
| `AppColors.surfaceContainerLow` | 15 | `seller_profile_card.dart`, `list_order_card.dart` |
| `AppColors.outlineVariant` | 18 | `app_text_field.dart`, `home_search_bar.dart` |

### Hardcoded Color Literals (120+ occurrences)
- **Orders**: `order_card.dart` has many status colors (e.g., `0xFF00FFCC`, `0xFFDCD2FE`).
- **Listings**: `create_listing_form_screen.dart` uses `0xFF2B2A51` (deep blue) and `0xFF5271FF` (blue button).
- **Listing Detail**: `0xFF013DFD` and `0xFFF2EFFF` are frequently used.
- **Shared**: `bottom_nav_bar.dart` and `photo_picker_section.dart` contain literals.

### Hardcoded BorderRadius (65+ occurrences)
- `chat_popup.dart`: `24`, `12`, `4`, `16`.
- `auth`: `login_screen.dart` and `register_screen.dart` use `24`.
- `shared`: `app_text_field.dart` uses `16`.
- `orders`: `orders_screen.dart` uses `28`, `24`, `16`, `8`.

---

## 2. Execution Phases

### Phase A: Normalize Current Code (Cleanup)

#### A1. Verify Design Tokens
- **AppSpacing**: Ensure `radiusXs=4`, `radiusSm=8`, `radiusMd=12`, `radiusLg=16`, `radiusXl=24` exist.
- **AppColors**: Maintain current state during cleanup.

#### A2. Migrate Colors
- Map hardcoded values to `AppColors` semantic tokens.
- **Mapping Guide**:
  - `0xFF2B2A51` (Deep Blue) → `AppColors.onSurface`
  - `0xFF5271FF` (Button Blue) → `AppColors.primary`
  - `0xFF013DFD` → `AppColors.primary`
  - `0xFFF2EFFF` (Light Surface) → `AppColors.surfaceContainerLow`
  - `0xFFE2DFFF` → Add `AppColors.accentSurface`
- Add new semantic tokens for unique state colors (especially in `order_card.dart`).

#### A3. Migrate Radius
- 4 → `AppSpacing.radiusXs`
- 8 → `AppSpacing.radiusSm`
- 12 → `AppSpacing.radiusMd`
- 16 → `AppSpacing.radiusLg`
- 24/28 → `AppSpacing.radiusXl` (Round 28 down to 24)

#### A4. Validation
- Run `flutter analyze` — zero warnings allowed.

### Phase B: New Theme System

#### B1. Directory Structure
```
lib/core/theme/
├── app_theme.dart
├── theme_variant.dart
├── architect/
│   ├── architect_colors.dart
│   ├── architect_radius.dart
│   ├── architect_text_styles.dart
│   └── architect_theme.dart
├── editorial/
└── extensions/
    └── theme_extensions.dart
```

#### B2. Theme Definitions
- **Architect**: IKEA-inspired, deep blue (#004181) + yellow (#fdd816), small radii, Plus Jakarta Sans.
- **Editorial**: High-energy, electric blue (#0040df) + mint (#26fedc), large radii (pill-style), Plus Jakarta Sans.

#### B3. Persistence
- Use `SharedPreferences` to persist `ThemeVariant`.
- Provider: `ThemeNotifier extends AsyncNotifier<ThemeVariant>`.

#### B4. Settings UI
- "Appearance" section in `system_settings_screen.dart`.
- Bottom sheet for selection with color preview swatches.

---

## 3. Migration Strategy (Batches)
1. **Batch 1**: `lib/features/orders/`
2. **Batch 2**: `lib/features/listing/`
3. **Batch 3**: `lib/features/auth/` + `lib/features/chat/`
4. **Batch 4**: `lib/shared/widgets/`
5. **Batch 5**: Remaining files

---

## 4. Commit Convention
- All changes related to this refactor must be grouped and committed with a clear "Theme Refactor" scope.

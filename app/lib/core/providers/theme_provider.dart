import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../theme/theme_variant.dart';

part 'theme_provider.g.dart';

/// Persists and exposes the user's chosen [SmivoThemeVariant].
///
/// On first launch, defaults to [SmivoThemeVariant.teal]. The selected
/// variant is saved to SharedPreferences so it survives app restarts.
///
/// Widgets watch this provider via `ref.watch(themeNotifierProvider)`
/// and pass the variant to [AppTheme.buildTheme].
@Riverpod(keepAlive: true)
class ThemeNotifier extends _$ThemeNotifier {
  static const _key = 'smivo_theme_variant';

  @override
  SmivoThemeVariant build() {
    // NOTE: Synchronously returns default; async load updates later.
    _loadSavedTheme();
    return SmivoThemeVariant.teal;
  }

  /// Switch to a new theme variant and persist the choice.
  Future<void> setTheme(SmivoThemeVariant variant) async {
    state = variant;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, variant.name);
  }

  /// Load the persisted theme variant (if any) from SharedPreferences.
  Future<void> _loadSavedTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_key);
    if (saved != null) {
      try {
        state = SmivoThemeVariant.values.byName(saved);
      } catch (_) {
        // HACK: If the persisted value is invalid (e.g. old enum name),
        // silently fall back to default. This prevents crashes after
        // enum renames.
      }
    }
  }
}

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../theme/color_scheme_variant.dart';

part 'color_scheme_provider.g.dart';

/// Persists and exposes the user's chosen [SmivoColorScheme].
///
/// On first launch, defaults to [SmivoColorScheme.defaultScheme].
/// The selected scheme is saved to SharedPreferences so it survives
/// app restarts.
///
/// Widgets watch this provider via `ref.watch(colorSchemeProvider)`
/// and pass the scheme to [AppTheme.buildTheme].
@Riverpod(keepAlive: true)
class ColorSchemeNotifier extends _$ColorSchemeNotifier {
  static const _key = 'smivo_color_scheme';

  @override
  SmivoColorScheme build() {
    // NOTE: Synchronously returns default; async load updates later.
    _loadSaved();
    return SmivoColorScheme.defaultScheme;
  }

  /// Switch to a new color scheme and persist the choice.
  Future<void> setScheme(SmivoColorScheme scheme) async {
    state = scheme;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, scheme.name);
  }

  /// Load the persisted color scheme (if any) from SharedPreferences.
  Future<void> _loadSaved() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_key);
    if (saved != null) {
      try {
        state = SmivoColorScheme.values.byName(saved);
      } catch (_) {
        // HACK: If the persisted value is invalid (e.g. removed enum),
        // silently fall back to default to prevent crashes.
      }
    }
  }
}

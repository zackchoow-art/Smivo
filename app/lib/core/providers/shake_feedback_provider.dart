import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'shake_feedback_provider.g.dart';

/// Persists and exposes whether the "Shake to Report Bug" feature is enabled.
/// Default is false — user must explicitly enable in Settings.
@Riverpod(keepAlive: true)
class ShakeFeedbackNotifier extends _$ShakeFeedbackNotifier {
  static const _key = 'smivo_shake_feedback_enabled';

  @override
  bool build() {
    // Synchronously return default, async load will update if needed
    _loadSavedState();
    return false;
  }

  Future<void> toggle(bool enabled) async {
    state = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_key, enabled);
  }

  Future<void> _loadSavedState() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getBool(_key);
    if (saved != null) {
      state = saved;
    }
  }
}

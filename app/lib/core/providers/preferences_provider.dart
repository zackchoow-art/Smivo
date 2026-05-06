import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'preferences_provider.g.dart';

// ── Keys ───────────────────────────────────────────────────────────────────
// NOTE: Use a namespaced prefix to avoid collisions with other SharedPrefs.
const _kLastPickupLocationId = 'smivo.listing.lastPickupLocationId';
// NOTE: Controls visibility of the floating quick-nav dial.
// Defaults to true (visible) on first launch.
const _kShowFloatingNav = 'smivo.ui.showFloatingNav';

// ── SharedPreferences singleton ────────────────────────────────────────────

/// Provides the SharedPreferences instance.
///
/// NOTE: keepAlive: true ensures the instance is only created once per app
/// launch and is never garbage-collected. AsyncNotifier is used because
/// SharedPreferences.getInstance() is async.
@Riverpod(keepAlive: true)
Future<SharedPreferences> sharedPreferences(Ref ref) async {
  return SharedPreferences.getInstance();
}

// ── Last Pickup Location ID ────────────────────────────────────────────────

/// Persists and retrieves the last pickup location the user selected.
///
/// This is used in [CreateListingFormScreen] to pre-select the previous
/// pickup location when opening the form, improving UX for repeat sellers.
///
/// NOTE: keepAlive: true so the value survives tab switches and navigations.
@Riverpod(keepAlive: true)
class LastPickupLocationId extends _$LastPickupLocationId {
  @override
  String? build() {
    // Read from SharedPreferences synchronously once the prefs are loaded.
    // If prefs aren't ready yet, return null (no pre-selection).
    final prefs = ref.watch(sharedPreferencesProvider).value;
    return prefs?.getString(_kLastPickupLocationId);
  }

  /// Persists [locationId] as the new default pickup location.
  Future<void> save(String locationId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kLastPickupLocationId, locationId);
    state = locationId;
  }

  /// Clears the stored preference (used by "Clear Cache" in settings).
  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kLastPickupLocationId);
    state = null;
  }
}

// ── Floating Quick-Nav Visibility ─────────────────────────────────────────

/// Persists whether the floating quick-nav speed-dial is shown.
///
/// Defaults to [true] (visible) if no preference has been saved.
/// Users can toggle this from System Settings.
///
/// NOTE: keepAlive: true so the toggle survives tab switches.
@Riverpod(keepAlive: true)
class ShowFloatingNav extends _$ShowFloatingNav {
  @override
  bool build() {
    final prefs = ref.watch(sharedPreferencesProvider).value;
    // Default to true — show the dial by default on first launch.
    return prefs?.getBool(_kShowFloatingNav) ?? true;
  }

  /// Persists [value] and updates local state immediately.
  Future<void> set(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kShowFloatingNav, value);
    state = value;
  }
}

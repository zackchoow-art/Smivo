import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:smivo/data/repositories/profile_repository.dart';

part 'settings_provider.g.dart';

// System Settings
@riverpod
class DarkModeState extends _$DarkModeState {
  @override
  bool build() => false;

  void toggle() => state = !state;
}

@riverpod
class DataUsageState extends _$DataUsageState {
  @override
  bool build() => true;

  void toggle() => state = !state;
}

@riverpod
class PrivacySettingsState extends _$PrivacySettingsState {
  @override
  bool build() => false;

  void toggle() => state = !state;
}

// Notification Settings
@riverpod
class NewMessagesNotifState extends _$NewMessagesNotifState {
  @override
  bool build() => true;

  void toggle() => state = !state;
}

@riverpod
class PriceAlertsNotifState extends _$PriceAlertsNotifState {
  @override
  bool build() => false;

  void toggle() => state = !state;
}

@riverpod
class OrderUpdatesNotifState extends _$OrderUpdatesNotifState {
  @override
  bool build() => true;

  void toggle() => state = !state;
}

@riverpod
class CampusAnnouncementsNotifState extends _$CampusAnnouncementsNotifState {
  @override
  bool build() => true;

  void toggle() => state = !state;
}

@riverpod
class WeeklyEmailDigestNotifState extends _$WeeklyEmailDigestNotifState {
  @override
  bool build() => false;

  void toggle() => state = !state;
}

/// Persisted email notification preference — reads from user profile,
/// writes to DB via profile repository.
@riverpod
class EmailNotificationsState extends _$EmailNotificationsState {
  @override
  bool build() {
    // NOTE: Initial value is loaded from auth profile in the screen.
    // Default to true until profile loads.
    return true;
  }

  void setInitial(bool value) => state = value;

  Future<void> toggle({
    required String userId,
    required ProfileRepository profileRepo,
  }) async {
    final newValue = !state;
    state = newValue;
    try {
      await profileRepo.updateEmailNotificationPref(
        userId: userId,
        enabled: newValue,
      );
    } catch (_) {
      // Revert on failure
      state = !newValue;
    }
  }
}

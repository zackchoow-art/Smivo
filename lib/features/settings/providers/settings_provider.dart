import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:smivo/data/repositories/profile_repository.dart';

part 'settings_provider.g.dart';

// Notification Settings
@riverpod
class PushNotificationsState extends _$PushNotificationsState {
  @override
  bool build() => true;

  void setInitial(bool value) => state = value;

  Future<void> toggle({
    required String userId,
    required ProfileRepository profileRepo,
    required bool pushMessages,
    required bool pushOrderUpdates,
  }) async {
    final newValue = !state;
    state = newValue;
    try {
      await profileRepo.updatePushPreferences(
        userId: userId,
        pushEnabled: newValue,
        pushMessages: pushMessages,
        pushOrderUpdates: pushOrderUpdates,
      );
    } catch (_) {
      state = !newValue;
    }
  }
}

@riverpod
class PushMessagesNotifState extends _$PushMessagesNotifState {
  @override
  bool build() => true;

  void setInitial(bool value) => state = value;

  Future<void> toggle({
    required String userId,
    required ProfileRepository profileRepo,
    required bool pushEnabled,
    required bool pushOrderUpdates,
  }) async {
    final newValue = !state;
    state = newValue;
    try {
      await profileRepo.updatePushPreferences(
        userId: userId,
        pushEnabled: pushEnabled,
        pushMessages: newValue,
        pushOrderUpdates: pushOrderUpdates,
      );
    } catch (_) {
      state = !newValue;
    }
  }
}

@riverpod
class PushOrderUpdatesNotifState extends _$PushOrderUpdatesNotifState {
  @override
  bool build() => true;

  void setInitial(bool value) => state = value;

  Future<void> toggle({
    required String userId,
    required ProfileRepository profileRepo,
    required bool pushEnabled,
    required bool pushMessages,
  }) async {
    final newValue = !state;
    state = newValue;
    try {
      await profileRepo.updatePushPreferences(
        userId: userId,
        pushEnabled: pushEnabled,
        pushMessages: pushMessages,
        pushOrderUpdates: newValue,
      );
    } catch (_) {
      state = !newValue;
    }
  }
}

@riverpod
class PriceAlertsNotifState extends _$PriceAlertsNotifState {
  @override
  bool build() => false;

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

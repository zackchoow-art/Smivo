import 'package:riverpod_annotation/riverpod_annotation.dart';

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

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:smivo/data/repositories/profile_repository.dart';

part 'settings_provider.g.dart';

class NotificationPreferences {
  final bool emailNotificationsEnabled;
  final bool pushNotificationsEnabled;
  final bool pushMessages;
  final bool emailMessages;
  final bool pushOrderUpdates;
  final bool emailOrderUpdates;
  final bool pushCampusAnnouncements;
  final bool emailCampusAnnouncements;
  final bool pushAnnouncements;
  final bool emailAnnouncements;

  const NotificationPreferences({
    this.emailNotificationsEnabled = false,
    this.pushNotificationsEnabled = true,
    this.pushMessages = true,
    this.emailMessages = false,
    this.pushOrderUpdates = true,
    this.emailOrderUpdates = false,
    this.pushCampusAnnouncements = true,
    this.emailCampusAnnouncements = false,
    this.pushAnnouncements = true,
    this.emailAnnouncements = false,
  });

  NotificationPreferences copyWith({
    bool? emailNotificationsEnabled,
    bool? pushNotificationsEnabled,
    bool? pushMessages,
    bool? emailMessages,
    bool? pushOrderUpdates,
    bool? emailOrderUpdates,
    bool? pushCampusAnnouncements,
    bool? emailCampusAnnouncements,
    bool? pushAnnouncements,
    bool? emailAnnouncements,
  }) {
    return NotificationPreferences(
      emailNotificationsEnabled: emailNotificationsEnabled ?? this.emailNotificationsEnabled,
      pushNotificationsEnabled: pushNotificationsEnabled ?? this.pushNotificationsEnabled,
      pushMessages: pushMessages ?? this.pushMessages,
      emailMessages: emailMessages ?? this.emailMessages,
      pushOrderUpdates: pushOrderUpdates ?? this.pushOrderUpdates,
      emailOrderUpdates: emailOrderUpdates ?? this.emailOrderUpdates,
      pushCampusAnnouncements: pushCampusAnnouncements ?? this.pushCampusAnnouncements,
      emailCampusAnnouncements: emailCampusAnnouncements ?? this.emailCampusAnnouncements,
      pushAnnouncements: pushAnnouncements ?? this.pushAnnouncements,
      emailAnnouncements: emailAnnouncements ?? this.emailAnnouncements,
    );
  }
}

@riverpod
class NotificationSettingsState extends _$NotificationSettingsState {
  @override
  NotificationPreferences build() {
    return const NotificationPreferences();
  }

  void setInitial(NotificationPreferences prefs) {
    state = prefs;
  }

  Future<void> updatePreferences({
    required String userId,
    required ProfileRepository profileRepo,
    bool? emailNotificationsEnabled,
    bool? pushNotificationsEnabled,
    bool? pushMessages,
    bool? emailMessages,
    bool? pushOrderUpdates,
    bool? emailOrderUpdates,
    bool? pushCampusAnnouncements,
    bool? emailCampusAnnouncements,
    bool? pushAnnouncements,
    bool? emailAnnouncements,
  }) async {
    final previousState = state;
    final newState = state.copyWith(
      emailNotificationsEnabled: emailNotificationsEnabled,
      pushNotificationsEnabled: pushNotificationsEnabled,
      pushMessages: pushMessages,
      emailMessages: emailMessages,
      pushOrderUpdates: pushOrderUpdates,
      emailOrderUpdates: emailOrderUpdates,
      pushCampusAnnouncements: pushCampusAnnouncements,
      emailCampusAnnouncements: emailCampusAnnouncements,
      pushAnnouncements: pushAnnouncements,
      emailAnnouncements: emailAnnouncements,
    );
    
    state = newState;

    try {
      await profileRepo.updateNotificationPreferences(
        userId: userId,
        emailNotificationsEnabled: newState.emailNotificationsEnabled,
        pushNotificationsEnabled: newState.pushNotificationsEnabled,
        pushMessages: newState.pushMessages,
        emailMessages: newState.emailMessages,
        pushOrderUpdates: newState.pushOrderUpdates,
        emailOrderUpdates: newState.emailOrderUpdates,
        pushCampusAnnouncements: newState.pushCampusAnnouncements,
        emailCampusAnnouncements: newState.emailCampusAnnouncements,
        pushAnnouncements: newState.pushAnnouncements,
        emailAnnouncements: newState.emailAnnouncements,
      );
    } catch (_) {
      // Revert on failure
      state = previousState;
    }
  }
}

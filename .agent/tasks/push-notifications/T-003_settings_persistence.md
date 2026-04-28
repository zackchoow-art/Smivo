# T-003: Settings Page Notification Persistence

## Goal
Persist notification settings toggles to DB. Replace in-memory providers with DB-backed ones.

## Prerequisites
- T-001 done (UserProfile has push fields, ProfileRepository has updatePushPreferences)
- T-002 done (push_notification_provider.dart exists)

## Boundary
### DO:
1. Modify `lib/features/settings/providers/settings_provider.dart`
2. Modify `lib/features/settings/screens/notification_settings_screen.dart`
3. Run build_runner + flutter analyze

### DO NOT:
- Touch user_profile.dart, profile_repository.dart, push_notification_provider.dart
- Touch main.dart, app.dart, pubspec.yaml, iOS/Android configs
- Delete EmailNotificationsState

## Changes

### settings_provider.dart
Add 3 new persisted providers following EmailNotificationsState pattern:
- `PushNotificationsState` — master push toggle
- `PushMessagesNotifState` — messages push toggle  
- `PushOrderUpdatesNotifState` — order updates push toggle

Each has: `setInitial(bool)`, `toggle({userId, profileRepo, ...sibling values})`.
Toggle calls `profileRepo.updatePushPreferences(...)`, reverts on failure.
Keep PriceAlerts/CampusAnnouncements/WeeklyDigest as memory-only.

### notification_settings_screen.dart
- In initState, load push prefs from profile (like _loadEmailPref)
- Add Push Notifications master toggle as first item
- Replace newMessagesNotifStateProvider → pushMessagesNotifStateProvider
- Replace orderUpdatesNotifStateProvider → pushOrderUpdatesNotifStateProvider
- Update onChanged callbacks with required params

## Verification
```bash
dart run build_runner build --delete-conflicting-outputs
flutter analyze --no-fatal-infos
```

## Report
Write to: `/Users/george/smivo/.agent/tasks/push-notifications/T-003_report.md`

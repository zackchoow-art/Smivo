import 'package:flutter/material.dart';
import 'package:smivo/core/theme/theme_extensions.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smivo/data/repositories/profile_repository.dart';
import 'package:smivo/features/auth/providers/auth_provider.dart';
import 'package:smivo/features/settings/providers/settings_provider.dart';
import 'package:smivo/features/settings/widgets/setting_toggle_row.dart';
import 'package:smivo/features/settings/widgets/category_notification_row.dart';
import 'package:smivo/shared/widgets/collapsing_title_app_bar.dart';
import 'package:smivo/shared/widgets/content_width_constraint.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:app_settings/app_settings.dart';

class NotificationSettingsScreen extends ConsumerStatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  ConsumerState<NotificationSettingsScreen> createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState
    extends ConsumerState<NotificationSettingsScreen>
    with WidgetsBindingObserver {
  bool _initialized = false;
  bool _systemPushEnabled = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkSystemPushStatus();
      _loadPrefs();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // User might have returned from iOS settings
      _checkSystemPushStatus();
    }
  }

  void _checkSystemPushStatus() {
    final hasPermission = OneSignal.Notifications.permission;
    if (_systemPushEnabled != hasPermission) {
      setState(() {
        _systemPushEnabled = hasPermission;
      });
      // Also update DB if the master switch was enabled but system is disabled
      if (!hasPermission && _initialized) {
        final prefs = ref.read(notificationSettingsStateProvider);
        if (prefs.pushNotificationsEnabled) {
          final user = ref.read(authStateProvider).valueOrNull;
          if (user != null) {
            ref
                .read(notificationSettingsStateProvider.notifier)
                .updatePreferences(
                  userId: user.id,
                  profileRepo: ref.read(profileRepositoryProvider),
                  pushNotificationsEnabled: false,
                );
          }
        }
      }
    }
  }

  Future<void> _loadPrefs() async {
    if (_initialized) return;
    final user = ref.read(authStateProvider).valueOrNull;
    if (user == null) return;
    try {
      final profile = await ref
          .read(profileRepositoryProvider)
          .getProfile(user.id);
      if (profile == null) return;

      final prefs = NotificationPreferences(
        emailNotificationsEnabled: profile.emailNotificationsEnabled,
        pushNotificationsEnabled: profile.pushNotificationsEnabled,
        pushMessages: profile.pushMessages,
        emailMessages: profile.emailMessages,
        pushOrderUpdates: profile.pushOrderUpdates,
        emailOrderUpdates: profile.emailOrderUpdates,
        pushAnnouncements: profile.pushAnnouncements,
        emailAnnouncements: profile.emailAnnouncements,
      );

      ref.read(notificationSettingsStateProvider.notifier).setInitial(prefs);

      _initialized = true;
    } catch (_) {}
  }

  Future<void> _handleMasterPushToggle(bool value, String userId) async {
    if (value && !_systemPushEnabled) {
      // If they are trying to turn it on but system is off, prompt them
      AppSettings.openAppSettings(type: AppSettingsType.notification);
      // We don't update state here; we wait for them to return from settings
    } else {
      await ref
          .read(notificationSettingsStateProvider.notifier)
          .updatePreferences(
            userId: userId,
            profileRepo: ref.read(profileRepositoryProvider),
            pushNotificationsEnabled: value,
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.smivoColors;
    final typo = context.smivoTypo;
    final user = ref.watch(authStateProvider).valueOrNull;
    final prefs = ref.watch(notificationSettingsStateProvider);

    // Actual push enabled is true ONLY if both system and app preference are true
    final effectivePushEnabled =
        _systemPushEnabled && prefs.pushNotificationsEnabled;

    return Scaffold(
      backgroundColor: colors.surfaceContainerLowest,
      body: Center(
        child: ContentWidthConstraint(
          maxWidth: 640,
          child: CustomScrollView(
            slivers: [
              const CollapsingTitleAppBar(
                title: 'Notification Settings',
                subtitle:
                    'Control how and when you receive\nupdates from the campus network.',
              ),
              SliverPadding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 8,
                ),
                sliver: SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 16),
                      Text(
                        'Master Switches',
                        style: typo.headlineSmall.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      SettingToggleRow(
                        icon: Icons.notifications_active_outlined,
                        title: 'Push Notifications',
                        subtitle:
                            'Receive push alerts on your device. If disabled, you will not receive any push notifications.',
                        value: effectivePushEnabled,
                        onChanged: (val) {
                          if (user != null) {
                            _handleMasterPushToggle(val, user.id);
                          }
                        },
                      ),
                      const SizedBox(height: 16),
                      SettingToggleRow(
                        icon: Icons.email_outlined,
                        title: 'Email Notifications',
                        subtitle:
                            'Receive email alerts. If disabled, you will not receive any email notifications.',
                        value: prefs.emailNotificationsEnabled,
                        onChanged: (val) {
                          if (user != null) {
                            ref
                                .read(
                                  notificationSettingsStateProvider.notifier,
                                )
                                .updatePreferences(
                                  userId: user.id,
                                  profileRepo: ref.read(
                                    profileRepositoryProvider,
                                  ),
                                  emailNotificationsEnabled: val,
                                );
                          }
                        },
                      ),
                      const SizedBox(height: 32),
                      Text(
                        'Category Preferences',
                        style: typo.headlineSmall.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      CategoryNotificationRow(
                        icon: Icons.chat_bubble_outline,
                        title: 'New Messages',
                        subtitle:
                            'Get notified when someone sends you a direct message or replies to your thread.',
                        pushValue: prefs.pushMessages,
                        emailValue: prefs.emailMessages,
                        pushEnabled: effectivePushEnabled,
                        emailEnabled: prefs.emailNotificationsEnabled,
                        onPushChanged: (val) {
                          if (user != null) {
                            ref
                                .read(
                                  notificationSettingsStateProvider.notifier,
                                )
                                .updatePreferences(
                                  userId: user.id,
                                  profileRepo: ref.read(
                                    profileRepositoryProvider,
                                  ),
                                  pushMessages: val,
                                );
                          }
                        },
                        onEmailChanged: (val) {
                          if (user != null) {
                            ref
                                .read(
                                  notificationSettingsStateProvider.notifier,
                                )
                                .updatePreferences(
                                  userId: user.id,
                                  profileRepo: ref.read(
                                    profileRepositoryProvider,
                                  ),
                                  emailMessages: val,
                                );
                          }
                        },
                      ),
                      const SizedBox(height: 16),
                      CategoryNotificationRow(
                        icon: Icons.shopping_bag_outlined,
                        title: 'Order Updates',
                        subtitle:
                            'Receive alerts when an order status changes, e.g., confirmed, cancelled, or returned.',
                        pushValue: prefs.pushOrderUpdates,
                        emailValue: prefs.emailOrderUpdates,
                        pushEnabled: effectivePushEnabled,
                        emailEnabled: prefs.emailNotificationsEnabled,
                        onPushChanged: (val) {
                          if (user != null) {
                            ref
                                .read(
                                  notificationSettingsStateProvider.notifier,
                                )
                                .updatePreferences(
                                  userId: user.id,
                                  profileRepo: ref.read(
                                    profileRepositoryProvider,
                                  ),
                                  pushOrderUpdates: val,
                                );
                          }
                        },
                        onEmailChanged: (val) {
                          if (user != null) {
                            ref
                                .read(
                                  notificationSettingsStateProvider.notifier,
                                )
                                .updatePreferences(
                                  userId: user.id,
                                  profileRepo: ref.read(
                                    profileRepositoryProvider,
                                  ),
                                  emailOrderUpdates: val,
                                );
                          }
                        },
                      ),
                      const SizedBox(height: 16),
                      CategoryNotificationRow(
                        icon: Icons.school_outlined,
                        title: 'Campus Announcements',
                        subtitle:
                            'Get important updates, news, and events specific to your campus.',
                        pushValue: prefs.pushCampusAnnouncements,
                        emailValue: prefs.emailCampusAnnouncements,
                        pushEnabled: effectivePushEnabled,
                        emailEnabled: prefs.emailNotificationsEnabled,
                        onPushChanged: (val) {
                          if (user != null) {
                            ref
                                .read(
                                  notificationSettingsStateProvider.notifier,
                                )
                                .updatePreferences(
                                  userId: user.id,
                                  profileRepo: ref.read(
                                    profileRepositoryProvider,
                                  ),
                                  pushCampusAnnouncements: val,
                                );
                          }
                        },
                        onEmailChanged: (val) {
                          if (user != null) {
                            ref
                                .read(
                                  notificationSettingsStateProvider.notifier,
                                )
                                .updatePreferences(
                                  userId: user.id,
                                  profileRepo: ref.read(
                                    profileRepositoryProvider,
                                  ),
                                  emailCampusAnnouncements: val,
                                );
                          }
                        },
                      ),
                      const SizedBox(height: 16),
                      CategoryNotificationRow(
                        icon: Icons.campaign_outlined,
                        title: 'Platform Announcements',
                        subtitle:
                            'Stay updated on the latest features, platform news, and community events.',
                        pushValue: prefs.pushAnnouncements,
                        emailValue: prefs.emailAnnouncements,
                        pushEnabled: effectivePushEnabled,
                        emailEnabled: prefs.emailNotificationsEnabled,
                        onPushChanged: (val) {
                          if (user != null) {
                            ref
                                .read(
                                  notificationSettingsStateProvider.notifier,
                                )
                                .updatePreferences(
                                  userId: user.id,
                                  profileRepo: ref.read(
                                    profileRepositoryProvider,
                                  ),
                                  pushAnnouncements: val,
                                );
                          }
                        },
                        onEmailChanged: (val) {
                          if (user != null) {
                            ref
                                .read(
                                  notificationSettingsStateProvider.notifier,
                                )
                                .updatePreferences(
                                  userId: user.id,
                                  profileRepo: ref.read(
                                    profileRepositoryProvider,
                                  ),
                                  emailAnnouncements: val,
                                );
                          }
                        },
                      ),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

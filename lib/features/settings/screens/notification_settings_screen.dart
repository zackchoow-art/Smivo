import 'package:flutter/material.dart';
import 'package:smivo/core/theme/theme_extensions.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smivo/data/repositories/profile_repository.dart';
import 'package:smivo/features/auth/providers/auth_provider.dart';
import 'package:smivo/features/settings/providers/settings_provider.dart';
import 'package:smivo/features/settings/widgets/setting_toggle_row.dart';
import 'package:smivo/shared/widgets/collapsing_title_app_bar.dart';
import 'package:smivo/shared/widgets/content_width_constraint.dart';

class NotificationSettingsScreen extends ConsumerStatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  ConsumerState<NotificationSettingsScreen> createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState
    extends ConsumerState<NotificationSettingsScreen> {
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadPrefs();
    });
  }

  Future<void> _loadPrefs() async {
    if (_initialized) return;
    final user = ref.read(authStateProvider).valueOrNull;
    if (user == null) return;
    try {
      final profile =
          await ref.read(profileRepositoryProvider).getProfile(user.id);
      if (profile == null) return;
      
      ref
          .read(emailNotificationsStateProvider.notifier)
          .setInitial(profile.emailNotificationsEnabled);
      ref
          .read(pushNotificationsStateProvider.notifier)
          .setInitial(profile.pushNotificationsEnabled);
      ref
          .read(pushMessagesNotifStateProvider.notifier)
          .setInitial(profile.pushMessages);
      ref
          .read(pushOrderUpdatesNotifStateProvider.notifier)
          .setInitial(profile.pushOrderUpdates);
          
      _initialized = true;
    } catch (_) {
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.smivoColors;
    final user = ref.watch(authStateProvider).valueOrNull;

    return Scaffold(
      backgroundColor: colors.surfaceContainerLowest,
      body: Center(
        child: ContentWidthConstraint(
          maxWidth: 640,
          child: CustomScrollView(
            slivers: [
              const CollapsingTitleAppBar(
                title: 'Notification Settings',
                subtitle: 'Control how and when you receive\nupdates from the campus network.',
              ),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                sliver: SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 16),
                      SettingToggleRow(
                        icon: Icons.notifications_active_outlined,
                        title: 'Push\nNotifications',
                        subtitle:
                            'Receive push alerts\non your device for\nimportant activity.',
                        value: ref.watch(pushNotificationsStateProvider),
                        onChanged: (_) {
                          if (user != null) {
                            ref
                                .read(pushNotificationsStateProvider.notifier)
                                .toggle(
                                  userId: user.id,
                                  profileRepo: ref.read(profileRepositoryProvider),
                                  pushMessages: ref.read(pushMessagesNotifStateProvider),
                                  pushOrderUpdates: ref.read(pushOrderUpdatesNotifStateProvider),
                                );
                          }
                        },
                      ),
                      const SizedBox(height: 16),
                      SettingToggleRow(
                        icon: Icons.email_outlined,
                        title: 'Email\nNotifications',
                        subtitle:
                            'Receive email alerts\nfor all order updates,\nmessages, and\nimportant events.',
                        value: ref.watch(emailNotificationsStateProvider),
                        onChanged: (_) {
                          if (user != null) {
                            ref
                                .read(emailNotificationsStateProvider.notifier)
                                .toggle(
                                  userId: user.id,
                                  profileRepo: ref.read(profileRepositoryProvider),
                                );
                          }
                        },
                      ),
                      const SizedBox(height: 16),
                      Divider(color: colors.dividerColor),
                      const SizedBox(height: 16),
                      SettingToggleRow(
                        icon: Icons.chat_bubble_outline,
                        title: 'New Messages',
                        subtitle:
                            'Get notified when\nsomeone sends you a\ndirect message or\nreplies to your thread.',
                        value: ref.watch(pushMessagesNotifStateProvider),
                        onChanged: (_) {
                          if (user != null) {
                            ref
                                .read(pushMessagesNotifStateProvider.notifier)
                                .toggle(
                                  userId: user.id,
                                  profileRepo: ref.read(profileRepositoryProvider),
                                  pushEnabled: ref.read(pushNotificationsStateProvider),
                                  pushOrderUpdates: ref.read(pushOrderUpdatesNotifStateProvider),
                                );
                          }
                        },
                      ),
                      const SizedBox(height: 16),
                      SettingToggleRow(
                        icon: Icons.payments_outlined,
                        title: 'Price Alerts',
                        subtitle:
                            'Receive immediate\nalerts when items on\nyour watchlist drop in\nprice.',
                        value: ref.watch(priceAlertsNotifStateProvider),
                        onChanged: (_) =>
                            ref.read(priceAlertsNotifStateProvider.notifier).toggle(),
                      ),
                      const SizedBox(height: 16),
                      SettingToggleRow(
                        icon: Icons.local_shipping_outlined,
                        title: 'Order Updates',
                        subtitle:
                            'Status changes,\nshipping tracking, and\ndelivery confirmations\nfor your purchases.',
                        value: ref.watch(pushOrderUpdatesNotifStateProvider),
                        onChanged: (_) {
                          if (user != null) {
                            ref
                                .read(pushOrderUpdatesNotifStateProvider.notifier)
                                .toggle(
                                  userId: user.id,
                                  profileRepo: ref.read(profileRepositoryProvider),
                                  pushEnabled: ref.read(pushNotificationsStateProvider),
                                  pushMessages: ref.read(pushMessagesNotifStateProvider),
                                );
                          }
                        },
                      ),
                      const SizedBox(height: 16),
                      SettingToggleRow(
                        icon: Icons.campaign_outlined,
                        title: 'Campus\nAnnouncements',
                        subtitle:
                            'Official updates, event\nreminders, and\nimportant news from\nthe university.',
                        value: ref.watch(campusAnnouncementsNotifStateProvider),
                        onChanged: (_) => ref
                            .read(campusAnnouncementsNotifStateProvider.notifier)
                            .toggle(),
                      ),
                      const SizedBox(height: 32),
                      Divider(color: colors.dividerColor),
                      const SizedBox(height: 32),
                      SettingToggleRow(
                        icon: Icons.summarize_outlined,
                        title: 'Weekly Email\nDigest',
                        subtitle:
                            'A summary of the\nweek\'s top activity\nsent to your student\nemail.',
                        value: ref.watch(weeklyEmailDigestNotifStateProvider),
                        onChanged: (_) => ref
                            .read(weeklyEmailDigestNotifStateProvider.notifier)
                            .toggle(),
                      ),
                      const SizedBox(height: 48),
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

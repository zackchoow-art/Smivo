import 'package:flutter/material.dart';
import 'package:smivo/core/theme/theme_extensions.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smivo/data/repositories/profile_repository.dart';
import 'package:smivo/features/auth/providers/auth_provider.dart';
import 'package:smivo/features/settings/providers/settings_provider.dart';
import 'package:smivo/features/settings/widgets/setting_toggle_row.dart';
import 'package:smivo/shared/widgets/custom_app_bar.dart';

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
    // Load the persisted email preference from the user's profile
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadEmailPref();
    });
  }

  Future<void> _loadEmailPref() async {
    if (_initialized) return;
    final user = ref.read(authStateProvider).valueOrNull;
    if (user == null) return;
    try {
      final profile =
          await ref.read(profileRepositoryProvider).getProfile(user.id);
      ref
          .read(emailNotificationsStateProvider.notifier)
          .setInitial(profile.emailNotificationsEnabled);
      _initialized = true;
    } catch (_) {
      // Non-critical — keep default
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.smivoColors;
    final typo = context.smivoTypo;
    final user = ref.watch(authStateProvider).valueOrNull;

    return Scaffold(
      backgroundColor: colors.surfaceContainerLowest,
      appBar: const CustomAppBar(),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Notification\nSettings',
                style: typo.headlineLarge.copyWith(
                  color: colors.settingsText,
                  fontWeight: FontWeight.w900,
                  height: 1.1,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Control how and when you receive\nupdates from the campus network.',
                style: typo.bodyMedium.copyWith(
                  color: colors.settingsTextSecondary,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 32),
              // Master email toggle — persisted to DB
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
                value: ref.watch(newMessagesNotifStateProvider),
                onChanged: (_) =>
                    ref.read(newMessagesNotifStateProvider.notifier).toggle(),
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
                value: ref.watch(orderUpdatesNotifStateProvider),
                onChanged: (_) =>
                    ref.read(orderUpdatesNotifStateProvider.notifier).toggle(),
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
    );
  }
}

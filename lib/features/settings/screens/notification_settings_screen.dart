import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:smivo/core/theme/app_colors.dart';
import 'package:smivo/core/theme/app_text_styles.dart';
import 'package:smivo/features/settings/providers/settings_provider.dart';
import 'package:smivo/features/settings/widgets/setting_toggle_row.dart';
import 'package:smivo/shared/widgets/custom_app_bar.dart';

class NotificationSettingsScreen extends ConsumerWidget {
  const NotificationSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.surfaceContainerLowest,
      appBar: const CustomAppBar(),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Notification\nSettings',
                style: AppTextStyles.headlineLarge.copyWith(
                  color: const Color(0xFF2B2A51),
                  fontWeight: FontWeight.w900,
                  height: 1.1,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Control how and when you receive\nupdates from the campus network.',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: const Color(0xFF2B2A51).withValues(alpha: 0.7),
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 32),
              
              SettingToggleRow(
                icon: Icons.chat_bubble_outline,
                title: 'New Messages',
                subtitle: 'Get notified when\nsomeone sends you a\ndirect message or\nreplies to your thread.',
                value: ref.watch(newMessagesNotifStateProvider),
                onChanged: (_) => ref.read(newMessagesNotifStateProvider.notifier).toggle(),
              ),
              const SizedBox(height: 16),
              SettingToggleRow(
                icon: Icons.payments_outlined,
                title: 'Price Alerts',
                subtitle: 'Receive immediate\nalerts when items on\nyour watchlist drop in\nprice.',
                value: ref.watch(priceAlertsNotifStateProvider),
                onChanged: (_) => ref.read(priceAlertsNotifStateProvider.notifier).toggle(),
              ),
              const SizedBox(height: 16),
              SettingToggleRow(
                icon: Icons.local_shipping_outlined,
                title: 'Order Updates',
                subtitle: 'Status changes,\nshipping tracking, and\ndelivery confirmations\nfor your purchases.',
                value: ref.watch(orderUpdatesNotifStateProvider),
                onChanged: (_) => ref.read(orderUpdatesNotifStateProvider.notifier).toggle(),
              ),
              const SizedBox(height: 16),
              SettingToggleRow(
                icon: Icons.campaign_outlined,
                title: 'Campus\nAnnouncements',
                subtitle: 'Official updates, event\nreminders, and\nimportant news from\nthe university.',
                value: ref.watch(campusAnnouncementsNotifStateProvider),
                onChanged: (_) => ref.read(campusAnnouncementsNotifStateProvider.notifier).toggle(),
              ),
              
              const SizedBox(height: 32),
              const Divider(color: Color(0xFFE2DFFF)),
              const SizedBox(height: 32),
              
              SettingToggleRow(
                icon: Icons.email_outlined,
                title: 'Weekly Email\nDigest',
                subtitle: 'A summary of the\nweek\'s top activity\nsent to your student\nemail.',
                value: ref.watch(weeklyEmailDigestNotifStateProvider),
                onChanged: (_) => ref.read(weeklyEmailDigestNotifStateProvider.notifier).toggle(),
              ),
              const SizedBox(height: 48),
            ],
          ),
        ),
      ),
    );
  }
}

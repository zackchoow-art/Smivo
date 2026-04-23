import 'package:flutter/material.dart';
import 'package:smivo/core/theme/theme_extensions.dart';
import 'package:go_router/go_router.dart';
import 'package:smivo/core/router/app_routes.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smivo/features/auth/providers/auth_provider.dart';
import 'package:smivo/shared/widgets/custom_app_bar.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.smivoColors;
    final typo = context.smivoTypo;
    final radius = context.smivoRadius;

    return Scaffold(
      backgroundColor: colors.surfaceContainerLowest,
      appBar: const CustomAppBar(showBackButton: true),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Settings', style: typo.headlineLarge.copyWith(color: colors.settingsText, fontWeight: FontWeight.w900)),
              const SizedBox(height: 8),
              Text('Manage your account preferences and\nconfigurations.',
                style: typo.bodyMedium.copyWith(color: colors.settingsTextSecondary, height: 1.4)),
              const SizedBox(height: 32),
              GridView.count(
                crossAxisCount: 2, shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 16, crossAxisSpacing: 16, childAspectRatio: 0.95,
                children: [
                  _buildMenuCard(context, icon: Icons.person_outline, title: 'Profile',
                    subtitle: 'Personal details,\navatar, security', onTap: () => context.pushNamed(AppRoutes.settingsProfile)),
                  _buildMenuCard(context, icon: Icons.monitor_outlined, title: 'System\nSettings',
                    subtitle: 'Display, language,\naccessibility', onTap: () => context.pushNamed(AppRoutes.settingsSystem)),
                  _buildMenuCard(context, icon: Icons.notifications_none_outlined, title: 'Notifications',
                    subtitle: 'Push, email, SMS\npreferences', onTap: () => context.pushNamed(AppRoutes.settingsNotifications)),
                  Opacity(opacity: 0.4, child: _buildMenuCard(context, icon: Icons.credit_card_outlined, title: 'Payments',
                    subtitle: 'Methods, billing\nhistory,...', onTap: () {})),
                ],
              ),
              const SizedBox(height: 32),
              GestureDetector(
                onTap: () => context.pushNamed(AppRoutes.settingsHelp),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: colors.surfaceContainerLowest,
                    borderRadius: BorderRadius.circular(radius.card),
                    boxShadow: [BoxShadow(color: colors.shadow, blurRadius: 10, offset: const Offset(0, 4))],
                  ),
                  child: Row(children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(color: colors.settingsIconBg, borderRadius: BorderRadius.circular(radius.md)),
                      child: Icon(Icons.help_outline, color: colors.settingsIcon),
                    ),
                    const SizedBox(width: 16),
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text('Help', style: typo.titleMedium.copyWith(color: colors.settingsText, fontWeight: FontWeight.w800)),
                      const SizedBox(height: 4),
                      Text('Support, FAQs, Contact\nUs', style: typo.bodyMedium.copyWith(color: colors.settingsTextSecondary, height: 1.3)),
                    ])),
                    Icon(Icons.chevron_right, color: colors.settingsText),
                  ]),
                ),
              ),
              const SizedBox(height: 48),
              Center(child: Consumer(builder: (context, ref, child) {
                return OutlinedButton.icon(
                  onPressed: () async {
                    await ref.read(authProvider.notifier).logout();
                    if (context.mounted) context.goNamed(AppRoutes.home);
                  },
                  icon: Icon(Icons.logout, color: colors.error),
                  label: Text('Logout', style: typo.labelLarge.copyWith(color: colors.error, fontWeight: FontWeight.w700)),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
                    side: BorderSide(color: colors.error.withValues(alpha: 0.3)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radius.md)),
                  ),
                );
              })),
              const SizedBox(height: 48),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuCard(BuildContext context, {required IconData icon, required String title, required String subtitle, required VoidCallback onTap}) {
    final colors = context.smivoColors;
    final typo = context.smivoTypo;
    final radius = context.smivoRadius;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: colors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(radius.card),
          boxShadow: [BoxShadow(color: colors.shadow, blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.center, mainAxisAlignment: MainAxisAlignment.start, children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: colors.settingsIconBg, borderRadius: BorderRadius.circular(radius.md)),
            child: Icon(icon, color: colors.settingsIcon),
          ),
          const SizedBox(height: 16),
          Text(title, textAlign: TextAlign.center, style: typo.titleMedium.copyWith(color: colors.settingsText, fontWeight: FontWeight.w800, height: 1.2)),
          const SizedBox(height: 8),
          Text(subtitle, textAlign: TextAlign.center, style: typo.bodySmall.copyWith(color: colors.settingsTextSecondary, height: 1.3)),
        ]),
      ),
    );
  }
}

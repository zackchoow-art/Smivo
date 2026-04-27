import 'package:flutter/material.dart';
import 'package:smivo/core/theme/theme_extensions.dart';
import 'package:go_router/go_router.dart';
import 'package:smivo/core/router/app_routes.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smivo/features/auth/providers/auth_provider.dart';
import 'package:smivo/shared/widgets/collapsing_title_app_bar.dart';
import 'package:smivo/shared/widgets/content_width_constraint.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.smivoColors;
    final typo = context.smivoTypo;
    final radius = context.smivoRadius;

    return Scaffold(
      backgroundColor: colors.surfaceContainerLowest,
      body: Center(
        child: ContentWidthConstraint(
          maxWidth: 640,
          child: CustomScrollView(
            slivers: [
              const CollapsingTitleAppBar(
                title: 'Settings',
                subtitle: 'Manage your account preferences and\nconfigurations.',
              ),
              SliverPadding(
                padding: const EdgeInsets.only(left: 24, right: 24, bottom: 8),
                sliver: SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      GridView.count(
                        crossAxisCount: 2, shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
                        mainAxisSpacing: 16, crossAxisSpacing: 16, childAspectRatio: 0.88,
                        children: [
                          _buildMenuCard(context, icon: Icons.person_outline, title: 'Profile',
                            subtitle: 'Personal details,\navatar, security', onTap: () => context.pushNamed(AppRoutes.settingsProfile)),
                          _buildMenuCard(context, icon: Icons.monitor_outlined, title: 'System\nSettings',
                            subtitle: 'Display, language,\naccessibility', onTap: () => context.pushNamed(AppRoutes.settingsSystem)),
                          _buildMenuCard(context, icon: Icons.notifications_none_outlined, title: 'Notifications',
                            subtitle: 'Push, email, SMS\npreferences', onTap: () => context.pushNamed(AppRoutes.settingsNotifications)),
                          _buildMenuCard(context, icon: Icons.help_outline, title: 'Help',
                            subtitle: 'Support, FAQs,\nContact Us', onTap: () => context.pushNamed(AppRoutes.settingsHelp)),
                        ],
                      ),
                      const SizedBox(height: 32),
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
                      const SizedBox(height: 16),
                      // Delete Account — destructive action with confirmation dialog
                      Center(child: Consumer(builder: (context, ref, child) {
                        return TextButton(
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (dialogContext) => AlertDialog(
                                title: const Text('Delete Account'),
                                content: const Text(
                                  'This action is permanent and cannot be undone. '
                                  'All your listings, orders, messages, and profile data will be deleted.',
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(dialogContext),
                                    child: const Text('Cancel'),
                                  ),
                                  TextButton(
                                    onPressed: () async {
                                      Navigator.pop(dialogContext);
                                      await ref.read(authProvider.notifier).deleteAccount();
                                      if (context.mounted) {
                                        context.goNamed(AppRoutes.home);
                                      }
                                    },
                                    style: TextButton.styleFrom(foregroundColor: colors.error),
                                    child: const Text('Delete'),
                                  ),
                                ],
                              ),
                            );
                          },
                          child: Text('Delete Account', style: typo.labelLarge.copyWith(
                            color: colors.error.withValues(alpha: 0.7),
                            fontWeight: FontWeight.w500,
                          )),
                        );
                      })),
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
          Text(title, textAlign: TextAlign.center, style: typo.titleMedium.copyWith(color: colors.onSurface, fontWeight: FontWeight.w800, height: 1.2)),
          const SizedBox(height: 8),
          Text(subtitle, textAlign: TextAlign.center, style: typo.bodySmall.copyWith(color: colors.onSurfaceVariant, height: 1.3)),
        ]),
      ),
    );
  }
}

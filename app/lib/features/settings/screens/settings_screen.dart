import 'package:flutter/material.dart';
import 'package:smivo/core/theme/theme_extensions.dart';
import 'package:go_router/go_router.dart';
import 'package:smivo/core/router/app_routes.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smivo/features/auth/providers/auth_provider.dart';
import 'package:smivo/shared/widgets/collapsing_title_app_bar.dart';
import 'package:smivo/shared/widgets/content_width_constraint.dart';
import 'package:smivo/core/providers/supabase_provider.dart';
import 'package:smivo/shared/widgets/unified_page_header.dart';
import 'package:smivo/core/theme/breakpoints.dart';

final _settingsConfigProvider = FutureProvider.autoDispose<Map<String, bool>>((
  ref,
) async {
  final supabase = ref.watch(supabaseClientProvider);
  final res = await supabase
      .from('system_settings')
      .select('key, value')
      .inFilter('key', ['feedback.enabled', 'plaza.enabled']);

  final map = {'feedback.enabled': true, 'plaza.enabled': false};
  for (final row in res) {
    final key = row['key'] as String;
    final val = row['value'];
    map[key] = val == true || val == 'true';
  }
  return map;
});

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.smivoColors;
    final typo = context.smivoTypo;
    final radius = context.smivoRadius;

    final configAsync = ref.watch(_settingsConfigProvider);
    final feedbackEnabled = configAsync.value?['feedback.enabled'] ?? true;
    final plazaEnabled = configAsync.value?['plaza.enabled'] ?? false;

    return Scaffold(
      backgroundColor: colors.surfaceContainerLowest,
      body: Center(
        child: ContentWidthConstraint(
          maxWidth: 640,
          child: CustomScrollView(
            slivers: [
              if (Breakpoints.isMobile(MediaQuery.of(context).size.width))
                const CollapsingTitleAppBar(
                  title: 'Settings',
                  subtitle:
                      'Manage your account preferences and\nconfigurations.',
                ),
              if (!Breakpoints.isMobile(MediaQuery.of(context).size.width))
                const SliverToBoxAdapter(
                  child: UnifiedPageHeader(title: 'Settings'),
                ),
              SliverPadding(
                padding: const EdgeInsets.only(left: 24, right: 24, bottom: 8),
                sliver: SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      GridView.count(
                        crossAxisCount: 2,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        mainAxisSpacing: 16,
                        crossAxisSpacing: 16,
                        childAspectRatio: 1.0,
                        children: [
                          _buildMenuCard(
                            context,
                            icon: Icons.person_outline,
                            title: 'Profile',
                            subtitle: 'Personal details,\navatar, security',
                            onTap:
                                () => context.pushNamed(
                                  AppRoutes.settingsProfile,
                                ),
                          ),
                          _buildMenuCard(
                            context,
                            icon: Icons.security_outlined,
                            title: 'Trust &\nSafety',
                            subtitle: 'Blocked users,\nReport history',
                            onTap:
                                () => context.pushNamed(
                                  AppRoutes.settingsTrustAndSafety,
                                ),
                          ),
                          _buildMenuCard(
                            context,
                            icon: Icons.monitor_outlined,
                            title: 'System\nSettings',
                            subtitle: 'Display, language,\naccessibility',
                            onTap:
                                () =>
                                    context.pushNamed(AppRoutes.settingsSystem),
                          ),
                          _buildMenuCard(
                            context,
                            icon: Icons.notifications_none_outlined,
                            title: 'Notifications',
                            subtitle: 'Push, email, SMS\npreferences',
                            onTap:
                                () => context.pushNamed(
                                  AppRoutes.settingsNotifications,
                                ),
                          ),
                          _buildMenuCard(
                            context,
                            icon: Icons.help_outline,
                            title: 'Help',
                            subtitle: 'Support, FAQs,\nContact Us',
                            onTap:
                                () => context.pushNamed(AppRoutes.settingsHelp),
                          ),
                          if (feedbackEnabled)
                            _buildMenuCard(
                              context,
                              icon: Icons.bug_report_outlined,
                              title: 'Feedback',
                              subtitle: 'Tell us about\nissues',
                              onTap:
                                  () =>
                                      context.pushNamed(AppRoutes.myFeedbacks),
                            ),
                          if (plazaEnabled)
                            _buildMenuCard(
                              context,
                              icon: Icons.military_tech_outlined,
                              title: 'My\nContributions',
                              subtitle: 'View your\npoints & level',
                              onTap:
                                  () => context.pushNamed(
                                    AppRoutes.myContributions,
                                  ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 32),
                      Center(
                        child: Consumer(
                          builder: (context, ref, child) {
                            return OutlinedButton.icon(
                              onPressed: () async {
                                await ref.read(authProvider.notifier).logout();
                                if (context.mounted) {
                                  context.goNamed(AppRoutes.home);
                                }
                              },
                              icon: Icon(Icons.logout, color: colors.error),
                              label: Text(
                                'Logout',
                                style: typo.labelLarge.copyWith(
                                  color: colors.error,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 48,
                                  vertical: 16,
                                ),
                                side: BorderSide(
                                  color: colors.error.withValues(alpha: 0.3),
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                    radius.md,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
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

  Widget _buildMenuCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    final colors = context.smivoColors;
    final typo = context.smivoTypo;
    final radius = context.smivoRadius;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(radius.card),
          boxShadow: [
            BoxShadow(
              color: colors.shadow,
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: colors.settingsIconBg,
                borderRadius: BorderRadius.circular(radius.md),
              ),
              child: Icon(icon, color: colors.settingsIcon, size: 20),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: typo.titleMedium.copyWith(
                color: colors.onSurface,
                fontWeight: FontWeight.w800,
                height: 1.2,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: typo.labelSmall.copyWith(
                color: colors.onSurfaceVariant,
                height: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

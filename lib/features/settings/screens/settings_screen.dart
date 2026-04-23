import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:smivo/core/router/app_routes.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smivo/core/theme/app_colors.dart';
import 'package:smivo/core/theme/app_text_styles.dart';
import 'package:smivo/features/auth/providers/auth_provider.dart';
import 'package:smivo/shared/widgets/custom_app_bar.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceContainerLowest,
      appBar: const CustomAppBar(showBackButton: true),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Settings',
                style: AppTextStyles.headlineLarge.copyWith(
                  color: const Color(0xFF2B2A51),
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Manage your account preferences and\nconfigurations.',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: const Color(0xFF2B2A51).withValues(alpha: 0.7),
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 32),
              
              // Grid of 4 cards
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 0.95,
                children: [
                  _buildMenuCard(
                    context,
                    icon: Icons.person_outline,
                    title: 'Profile',
                    subtitle: 'Personal details,\navatar, security',
                    onTap: () => context.pushNamed(AppRoutes.settingsProfile),
                  ),
                  _buildMenuCard(
                    context,
                    icon: Icons.monitor_outlined,
                    title: 'System\nSettings',
                    subtitle: 'Display, language,\naccessibility',
                    onTap: () => context.pushNamed(AppRoutes.settingsSystem),
                  ),
                  _buildMenuCard(
                    context,
                    icon: Icons.notifications_none_outlined,
                    title: 'Notifications',
                    subtitle: 'Push, email, SMS\npreferences',
                    onTap: () => context.pushNamed(AppRoutes.settingsNotifications),
                  ),
                  Opacity(
                    opacity: 0.4,
                    child: _buildMenuCard(
                      context,
                      icon: Icons.credit_card_outlined,
                      title: 'Payments',
                      subtitle: 'Methods, billing\nhistory,...',
                      onTap: () {
                        // User feedback: 支付页呈现灰色不可点击状态，这是后续开发的内容
                      },
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 32),
              
              // Help button
              GestureDetector(
                onTap: () => context.pushNamed(AppRoutes.settingsHelp),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.02),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF2EFFF),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.help_outline,
                          color: Color(0xFF013DFD),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Help',
                              style: AppTextStyles.titleMedium.copyWith(
                                color: const Color(0xFF2B2A51),
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Support, FAQs, Contact\nUs',
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: const Color(0xFF2B2A51).withValues(alpha: 0.7),
                                height: 1.3,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(
                        Icons.chevron_right,
                        color: Color(0xFF2B2A51),
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 48),
              
              // Logout Button
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
                      icon: const Icon(Icons.logout, color: Color(0xFFD32F2F)),
                      label: Text(
                        'Logout',
                        style: AppTextStyles.labelLarge.copyWith(
                          color: const Color(0xFFD32F2F),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
                        side: BorderSide(color: const Color(0xFFD32F2F).withValues(alpha: 0.3)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
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
    );
  }

  Widget _buildMenuCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF2EFFF),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: const Color(0xFF013DFD),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: AppTextStyles.titleMedium.copyWith(
                color: const Color(0xFF2B2A51),
                fontWeight: FontWeight.w800,
                height: 1.2,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: AppTextStyles.bodySmall.copyWith(
                color: const Color(0xFF2B2A51).withValues(alpha: 0.7),
                height: 1.3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

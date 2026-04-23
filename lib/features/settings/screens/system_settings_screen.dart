import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smivo/core/theme/app_colors.dart';
import 'package:smivo/core/theme/app_text_styles.dart';
import 'package:smivo/features/settings/providers/settings_provider.dart';
import 'package:smivo/features/settings/widgets/setting_card_container.dart';
import 'package:smivo/features/settings/widgets/setting_toggle_row.dart';
import 'package:smivo/shared/widgets/custom_app_bar.dart';

class SystemSettingsScreen extends ConsumerWidget {
  const SystemSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDarkMode = ref.watch(darkModeStateProvider);
    final isDataUsageEnabled = ref.watch(dataUsageStateProvider);
    final isPrivacyEnabled = ref.watch(privacySettingsStateProvider);

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
                'System Settings',
                style: AppTextStyles.headlineLarge.copyWith(
                  color: const Color(0xFF2B2A51),
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 32),
              
              Text(
                'Display',
                style: AppTextStyles.titleMedium.copyWith(
                  color: const Color(0xFF2B2A51),
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 16),
              SettingToggleRow(
                icon: Icons.dark_mode_outlined,
                title: 'Dark Mode',
                subtitle: 'Adjust interface\nappearance',
                value: isDarkMode,
                onChanged: (_) => ref.read(darkModeStateProvider.notifier).toggle(),
              ),
              const SizedBox(height: 16),
              SettingCardContainer(
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.language,
                        color: Color(0xFF013DFD),
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Language',
                            style: AppTextStyles.bodyLarge.copyWith(
                              color: const Color(0xFF2B2A51),
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'English (US)',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: const Color(0xFF2B2A51).withValues(alpha: 0.7),
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
              
              const SizedBox(height: 32),
              const Divider(color: Color(0xFFE2DFFF)),
              const SizedBox(height: 32),
              
              Text(
                'Network & Privacy',
                style: AppTextStyles.titleMedium.copyWith(
                  color: const Color(0xFF2B2A51),
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 16),
              SettingToggleRow(
                icon: Icons.data_usage,
                title: 'Data Usage',
                subtitle: 'Optimize imagery for\ncellular',
                value: isDataUsageEnabled,
                onChanged: (_) => ref.read(dataUsageStateProvider.notifier).toggle(),
              ),
              const SizedBox(height: 16),
              SettingToggleRow(
                icon: Icons.shield_outlined,
                title: 'Privacy Settings',
                subtitle: 'Limit profile visibility',
                value: isPrivacyEnabled,
                onChanged: (_) => ref.read(privacySettingsStateProvider.notifier).toggle(),
              ),
              const SizedBox(height: 48),
            ],
          ),
        ),
      ),
    );
  }
}

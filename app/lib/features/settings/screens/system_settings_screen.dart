import 'package:flutter/material.dart';
import 'package:smivo/core/theme/theme_extensions.dart';
import 'package:smivo/core/theme/theme_variant.dart';
import 'package:smivo/core/providers/theme_provider.dart';
import 'package:smivo/core/providers/shake_feedback_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:smivo/features/settings/widgets/setting_card_container.dart';
import 'package:smivo/shared/widgets/collapsing_title_app_bar.dart';
import 'package:go_router/go_router.dart';
import 'package:smivo/core/router/app_routes.dart';
import 'package:smivo/core/constants/debug_constants.dart';
import 'package:smivo/shared/widgets/content_width_constraint.dart';

class SystemSettingsScreen extends ConsumerWidget {
  const SystemSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentTheme = ref.watch(themeProvider);
    final colors = context.smivoColors;
    final typo = context.smivoTypo;

    return Scaffold(
      backgroundColor: colors.surfaceContainerLowest,
      body: Center(
        child: ContentWidthConstraint(
          maxWidth: 640,
          child: CustomScrollView(
            slivers: [
              const CollapsingTitleAppBar(
                title: 'System Settings',
                subtitle: 'Display, language, accessibility',
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
                        'Display',
                        style: typo.titleMedium.copyWith(
                          color: colors.onSurface,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Theme variant picker
                      SettingCardContainer(
                        child: Row(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: colors.surfaceContainerLowest,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.palette_outlined,
                                color: colors.settingsIcon,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'App Theme',
                                    style: typo.bodyLarge.copyWith(
                                      color: colors.onSurface,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Choose a visual style',
                                    style: typo.bodySmall.copyWith(
                                      color: colors.onSurfaceVariant,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  SizedBox(
                                    width: double.infinity,
                                    child: SegmentedButton<SmivoThemeVariant>(
                                      segments: const [
                                        ButtonSegment(
                                          value: SmivoThemeVariant.teal,
                                          label: Text('Teal'),
                                          icon: Icon(
                                            Icons.spa_outlined,
                                            size: 16,
                                          ),
                                        ),
                                        ButtonSegment(
                                          value: SmivoThemeVariant.ikea,
                                          label: Text('IKEA Flat'),
                                          icon: Icon(
                                            Icons.square_outlined,
                                            size: 16,
                                          ),
                                        ),
                                      ],
                                      selected: {currentTheme},
                                      onSelectionChanged: (selected) {
                                        ref
                                            .read(
                                              themeProvider.notifier,
                                            )
                                            .setTheme(selected.first);
                                      },
                                      style: ButtonStyle(
                                        shape: WidgetStatePropertyAll(
                                          RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              context.smivoRadius.button,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      SettingCardContainer(
                        child: Row(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: colors.surfaceContainerLowest,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.language,
                                color: colors.settingsIcon,
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
                                    style: typo.bodyLarge.copyWith(
                                      color: colors.onSurface,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'English (US)',
                                    style: typo.bodySmall.copyWith(
                                      color: colors.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Icon(Icons.chevron_right, color: colors.onSurface),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Feedback',
                        style: typo.titleMedium.copyWith(
                          color: colors.onSurface,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 16),
                      SettingCardContainer(
                        child: Row(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: colors.surfaceContainerLowest,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.vibration,
                                color: colors.settingsIcon,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Shake to Report',
                                    style: typo.bodyLarge.copyWith(
                                      color: colors.onSurface,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Shake your phone to capture a screenshot and report an issue',
                                    style: typo.bodySmall.copyWith(
                                      color: colors.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Consumer(
                              builder: (context, ref, child) {
                                final isEnabled = ref.watch(shakeFeedbackProvider);
                                return Switch.adaptive(
                                  value: isEnabled,
                                  activeColor: colors.primary,
                                  onChanged: (value) {
                                    ref.read(shakeFeedbackProvider.notifier).toggle(value);
                                  },
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),
                      if (kDebugBackdoorEnabled) ...[
                        Text(
                          'Developer',
                          style: typo.titleMedium.copyWith(
                            color: colors.onSurface,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 16),
                        GestureDetector(
                          onTap: () => context.pushNamed(AppRoutes.settingsDebug),
                          child: SettingCardContainer(
                            child: Row(
                              children: [
                                Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: colors.surfaceContainerLowest,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.bug_report,
                                    color: colors.settingsIcon,
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Debug Backend Data',
                                        style: typo.bodyLarge.copyWith(
                                          color: colors.onSurface,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        'View and toggle system configs and dictionaries',
                                        style: typo.bodySmall.copyWith(
                                          color: colors.onSurfaceVariant,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Icon(Icons.chevron_right, color: colors.onSurface),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 48),
                      ],
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

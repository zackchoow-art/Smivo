import 'package:flutter/material.dart';
import 'package:smivo/core/theme/theme_extensions.dart';
import 'package:smivo/core/theme/theme_variant.dart';
import 'package:smivo/core/providers/theme_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:smivo/features/settings/widgets/setting_card_container.dart';
import 'package:smivo/shared/widgets/collapsing_title_app_bar.dart';

class SystemSettingsScreen extends ConsumerWidget {
  const SystemSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentTheme = ref.watch(themeNotifierProvider);
    final colors = context.smivoColors;
    final typo = context.smivoTypo;

    return Scaffold(
      backgroundColor: colors.surfaceContainerLowest,
      body: CustomScrollView(
        slivers: [
          const CollapsingTitleAppBar(
            title: 'System Settings',
            subtitle: 'Display, language, accessibility',
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            sliver: SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  Text('Display', style: typo.titleMedium.copyWith(color: colors.onSurface, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 16),
                  // Theme variant picker
                  SettingCardContainer(
                    child: Row(children: [
                      Container(
                        width: 40, height: 40,
                        decoration: BoxDecoration(color: colors.surfaceContainerLowest, shape: BoxShape.circle),
                        child: Icon(Icons.palette_outlined, color: colors.settingsIcon, size: 20),
                      ),
                      const SizedBox(width: 16),
                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text('App Theme', style: typo.bodyLarge.copyWith(color: colors.onSurface, fontWeight: FontWeight.w700)),
                        const SizedBox(height: 2),
                        Text('Choose a visual style', style: typo.bodySmall.copyWith(color: colors.onSurfaceVariant)),
                        const SizedBox(height: 10),
                        SizedBox(
                          width: double.infinity,
                          child: SegmentedButton<SmivoThemeVariant>(
                            segments: const [
                              ButtonSegment(value: SmivoThemeVariant.teal, label: Text('Teal'), icon: Icon(Icons.spa_outlined, size: 16)),
                              ButtonSegment(value: SmivoThemeVariant.ikea, label: Text('IKEA Flat'), icon: Icon(Icons.square_outlined, size: 16)),
                            ],
                            selected: {currentTheme},
                            onSelectionChanged: (selected) {
                              ref.read(themeNotifierProvider.notifier).setTheme(selected.first);
                            },
                            style: ButtonStyle(
                              shape: WidgetStatePropertyAll(RoundedRectangleBorder(borderRadius: BorderRadius.circular(context.smivoRadius.button))),
                            ),
                          ),
                        ),
                      ])),
                    ]),
                  ),
                  const SizedBox(height: 16),
                  SettingCardContainer(
                    child: Row(children: [
                      Container(
                        width: 40, height: 40,
                        decoration: BoxDecoration(color: colors.surfaceContainerLowest, shape: BoxShape.circle),
                        child: Icon(Icons.language, color: colors.settingsIcon, size: 20),
                      ),
                      const SizedBox(width: 16),
                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text('Language', style: typo.bodyLarge.copyWith(color: colors.onSurface, fontWeight: FontWeight.w700)),
                        const SizedBox(height: 2),
                        Text('English (US)', style: typo.bodySmall.copyWith(color: colors.onSurfaceVariant)),
                      ])),
                      Icon(Icons.chevron_right, color: colors.onSurface),
                    ]),
                  ),
                  const SizedBox(height: 48),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}


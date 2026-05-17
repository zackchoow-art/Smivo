import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:smivo/core/theme/theme_extensions.dart';
import 'package:smivo/core/theme/theme_variant.dart';
import 'package:smivo/core/providers/theme_provider.dart';
import 'package:smivo/core/providers/color_scheme_provider.dart';
import 'package:smivo/core/providers/shake_feedback_provider.dart';
import 'package:smivo/core/providers/preferences_provider.dart';
import 'package:smivo/features/admin/providers/admin_auth_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:smivo/features/orders/providers/orders_provider.dart';
import 'package:smivo/features/chat/providers/chat_provider.dart';
import 'package:smivo/features/notifications/providers/notification_provider.dart';
import 'package:smivo/features/listing/providers/saved_listing_provider.dart';
import 'package:smivo/features/seller/providers/seller_center_provider.dart';
import 'package:smivo/features/home/providers/home_provider.dart';
import 'package:smivo/features/settings/widgets/setting_card_container.dart';
import 'package:smivo/shared/widgets/action_error_dialog.dart';
import 'package:smivo/shared/widgets/action_success_dialog.dart';
import 'package:smivo/shared/widgets/collapsing_title_app_bar.dart';
import 'package:smivo/shared/widgets/content_width_constraint.dart';
import 'package:go_router/go_router.dart';
import 'package:smivo/core/router/app_routes.dart';

class SystemSettingsScreen extends ConsumerStatefulWidget {
  const SystemSettingsScreen({super.key});

  @override
  ConsumerState<SystemSettingsScreen> createState() =>
      _SystemSettingsScreenState();
}

class _SystemSettingsScreenState extends ConsumerState<SystemSettingsScreen> {
  // ── Clear Cache ───────────────────────────────────────────────

  /// Clears all local caches: in-memory image cache, CachedNetworkImage
  /// disk store, and invalidates in-memory Riverpod provider state.
  ///
  /// NOTE: This method lives on the State so `mounted` is always valid,
  /// even after async gaps caused by provider invalidation triggering
  /// widget tree rebuilds.
  Future<void> _clearCache() async {
    // NOTE: showDialog() defaults to useRootNavigator: true, so the dialog
    // is pushed onto the ROOT navigator. We must also get the root navigator
    // here, otherwise nav.pop() would pop from the nearest ancestor navigator
    // (the StatefulShellRoute branch navigator) and accidentally pop /home
    // instead of the dialog.
    final nav = Navigator.of(context, rootNavigator: true);

    // Show non-dismissible loading indicator.
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => const Center(child: CircularProgressIndicator()),
    );

    try {
      // 1. Clear Flutter in-memory image cache (RAM).
      PaintingBinding.instance.imageCache.clear();
      PaintingBinding.instance.imageCache.clearLiveImages();

      // 2. Clear CachedNetworkImage disk store.
      // PaintingBinding only covers RAM; disk is managed by
      // flutter_cache_manager independently.
      await DefaultCacheManager().emptyCache();

      // 3. Invalidate Riverpod provider in-memory state.
      // NOTE: profileProvider is intentionally excluded — it is watched
      // by AppRouterNotifier, so invalidating it triggers GoRouter's
      // refreshListenable and can redirect the user mid-operation.
      ref.invalidate(allOrdersProvider);
      ref.invalidate(chatRoomListProvider);
      ref.invalidate(notificationListProvider);
      ref.invalidate(mySavedListingsProvider);
      ref.invalidate(myListingsProvider);
      ref.invalidate(homeListingsProvider);

      // Brief pause to let provider state settle.
      await Future.delayed(const Duration(milliseconds: 400));

      // Close loading dialog via stored nav (context may be stale).
      nav.pop();

      // Show success — State.mounted is reliable even post-rebuild.
      if (mounted) {
        showDialog(
          context: context,
          builder: (ctx) => const ActionSuccessDialog(
            title: 'Cache Cleared',
            message: 'Local cache cleared successfully.',
          ),
        );
      }
    } catch (e) {
      nav.pop();
      if (mounted) {
        showDialog(
          context: context,
          builder: (ctx) => ActionErrorDialog(
            title: 'Failed to Clear Cache',
            message: e.toString(),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final ref = this.ref;
    final currentTheme = ref.watch(themeProvider);
    final currentScheme = ref.watch(colorSchemeProvider);
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
                                          value: SmivoThemeVariant.flat,
                                          label: Text('Flat'),
                                          icon: Icon(
                                            Icons.square_outlined,
                                            size: 16,
                                          ),
                                        ),
                                      ],
                                      selected: {currentTheme},
                                      onSelectionChanged: (selected) {
                                        ref
                                            .read(themeProvider.notifier)
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
                      const SizedBox(height: 12),
                      // Color scheme picker
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
                                Icons.color_lens_outlined,
                                color: colors.settingsIcon,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Color Palette',
                                    style: typo.bodyLarge.copyWith(
                                      color: colors.onSurface,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Choose a color palette',
                                    style: typo.bodySmall.copyWith(
                                      color: colors.onSurfaceVariant,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  _ColorSchemeRow(
                                    selected: currentScheme,
                                    onSelected: (scheme) {
                                      ref
                                          .read(
                                            colorSchemeProvider.notifier,
                                          )
                                          .setScheme(scheme);
                                    },
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
                        'Storage',
                        style: typo.titleMedium.copyWith(
                          color: colors.onSurface,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 16),
                      GestureDetector(
                        onTap: _clearCache,
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
                                  Icons.cleaning_services_outlined,
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
                                      'Clear Local Cache',
                                      style: typo.bodyLarge.copyWith(
                                        color: colors.onSurface,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      'Free up space and remove old account data',
                                      style: typo.bodySmall.copyWith(
                                        color: colors.onSurfaceVariant,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Icon(
                                Icons.chevron_right,
                                color: colors.onSurface,
                              ),
                            ],
                          ),
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
                                final isEnabled = ref.watch(
                                  shakeFeedbackProvider,
                                );
                                return Switch.adaptive(
                                  value: isEnabled,
                                  activeTrackColor: colors.primary,
                                  onChanged: (value) {
                                    ref
                                        .read(shakeFeedbackProvider.notifier)
                                        .toggle(value);
                                  },
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Quick Navigation toggle
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
                                Icons.apps_rounded,
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
                                    'Quick Navigation',
                                    style: typo.bodyLarge.copyWith(
                                      color: colors.onSurface,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Show floating shortcut button for Home, Chat, Carpool, Orders',
                                    style: typo.bodySmall.copyWith(
                                      color: colors.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Consumer(
                              builder: (context, ref, _) {
                                final isEnabled = ref.watch(
                                  showFloatingNavProvider,
                                );
                                return Switch.adaptive(
                                  value: isEnabled,
                                  activeTrackColor: colors.primary,
                                  onChanged: (value) {
                                    ref
                                        .read(showFloatingNavProvider.notifier)
                                        .set(value);
                                  },
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),
                      if (ref
                          .watch(adminContextProvider)
                          .maybeWhen(
                            data: (ctx) => ctx.isSysadmin,
                            orElse: () => false,
                          )) ...[
                        Text(
                          'Developer',
                          style: typo.titleMedium.copyWith(
                            color: colors.onSurface,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 16),
                        GestureDetector(
                          onTap:
                              () => context.pushNamed(AppRoutes.settingsDebug),
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
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
                                Icon(
                                  Icons.chevron_right,
                                  color: colors.onSurface,
                                ),
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

/// Horizontal row of color scheme swatches with labels.
///
/// Each swatch shows the primary color of the scheme. The selected
/// one gets a highlight ring and a checkmark overlay.
class _ColorSchemeRow extends StatelessWidget {
  const _ColorSchemeRow({
    required this.selected,
    required this.onSelected,
  });

  final SmivoColorScheme selected;
  final ValueChanged<SmivoColorScheme> onSelected;

  @override
  Widget build(BuildContext context) {
    final colors = context.smivoColors;
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: SmivoColorScheme.values.map((scheme) {
        return Padding(
          padding: const EdgeInsets.only(right: 16),
          child: _SchemeCircle(
            scheme: scheme,
            isSelected: scheme == selected,
            onTap: () => onSelected(scheme),
            accentColor: colors.primary,
          ),
        );
      }).toList(),
    );
  }
}

/// A single color scheme swatch: circle with the scheme's primary
/// color, label underneath, and a ring + check when selected.
class _SchemeCircle extends StatelessWidget {
  const _SchemeCircle({
    required this.scheme,
    required this.isSelected,
    required this.onTap,
    required this.accentColor,
  });

  final SmivoColorScheme scheme;
  final bool isSelected;
  final VoidCallback onTap;
  final Color accentColor;

  /// Preview colors for each scheme (shown as gradient in circle).
  static const _previewColors = {
    SmivoColorScheme.defaultScheme: [
      Color(0xFF2D5BFF),
      Color(0xFF4C73FF),
    ],
    SmivoColorScheme.rose: [
      Color(0xFFA57480),
      Color(0xFFD4A373),
    ],
    SmivoColorScheme.pastel: [
      Color(0xFF8B7EC8),
      Color(0xFFE8A0BF),
    ],
    SmivoColorScheme.sage: [
      Color(0xFF7D8B6E),
      Color(0xFFB49082),
    ],
  };

  static const _labels = {
    SmivoColorScheme.defaultScheme: 'Default',
    SmivoColorScheme.rose: 'Rosé',
    SmivoColorScheme.pastel: 'Pastel',
    SmivoColorScheme.sage: 'Sage',
  };

  @override
  Widget build(BuildContext context) {
    final typo = context.smivoTypo;
    final colors = context.smivoColors;
    final previewPair = _previewColors[scheme]!;

    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOut,
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: isSelected
                  ? Border.all(color: accentColor, width: 2.5)
                  : Border.all(
                      color: colors.outlineVariant,
                      width: 1,
                    ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(2),
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: previewPair,
                  ),
                ),
                child: isSelected
                    ? const Icon(
                        Icons.check,
                        color: Colors.white,
                        size: 18,
                      )
                    : null,
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            _labels[scheme]!,
            style: typo.labelSmall.copyWith(
              color: isSelected
                  ? colors.onSurface
                  : colors.onSurfaceVariant,
              fontWeight:
                  isSelected ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

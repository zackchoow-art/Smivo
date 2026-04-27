import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:smivo/core/router/app_routes.dart';
import 'package:smivo/core/theme/theme_extensions.dart';
import 'package:smivo/features/chat/providers/chat_provider.dart';
import 'package:smivo/features/orders/providers/orders_provider.dart';

/// Vertical navigation rail for tablet-sized screens (600–1024px).
///
/// Mirrors the same tabs and badge logic as [BottomNavBar] but renders
/// as a narrow vertical strip on the left side of the screen.
/// On desktop (> 1024px), [extended] can be set to true to show labels.
class NavigationRailBar extends ConsumerWidget {
  const NavigationRailBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    this.extended = false,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;

  /// When true, shows text labels next to icons (desktop sidebar mode).
  final bool extended;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final totalUnreadAsync = ref.watch(chatTotalUnreadProvider);
    final totalUnread = totalUnreadAsync.valueOrNull ?? 0;
    final unreadOrderUpdatesAsync = ref.watch(unreadOrderUpdatesCountProvider);
    final unreadOrderUpdates = unreadOrderUpdatesAsync.valueOrNull ?? 0;
    final colors = context.smivoColors;
    final typo = context.smivoTypo;

    return NavigationRail(
      selectedIndex: currentIndex,
      onDestinationSelected: (index) {
        // NOTE: Index 2 in the rail is "Post" — a push action, not a tab.
        if (index == 2) {
          context.pushNamed(AppRoutes.createListing);
          return;
        }
        // Map rail indices to shell branch indices:
        // Rail 0=Home(branch 0), 1=Chat(branch 1), 3=Orders(branch 2)
        final branchIndex = index > 2 ? index - 1 : index;
        onTap(branchIndex);
      },
      extended: extended,
      minWidth: 72,
      minExtendedWidth: 200,
      backgroundColor: colors.surfaceContainerLowest,
      indicatorColor: colors.navActiveBackground,
      selectedIconTheme: IconThemeData(color: colors.navActiveIcon),
      unselectedIconTheme: IconThemeData(color: colors.onSurfaceVariant),
      // NOTE: Show labels on both states so the user always knows
      // what each icon means, especially on first visit.
      labelType: extended
          ? NavigationRailLabelType.none
          : NavigationRailLabelType.all,
      leading: Padding(
        padding: const EdgeInsets.only(top: 8, bottom: 16),
        child: Text(
          'Smivo',
          style: typo.titleMedium.copyWith(
            color: colors.primary,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.5,
          ),
        ),
      ),
      destinations: [
        const NavigationRailDestination(
          icon: Icon(Icons.home_outlined),
          selectedIcon: Icon(Icons.home),
          label: Text('Home'),
        ),
        NavigationRailDestination(
          icon: Badge(
            label: Text(
              totalUnread > 99 ? '99+' : totalUnread.toString(),
              style: TextStyle(fontSize: 9, color: colors.onPrimary),
            ),
            isLabelVisible: totalUnread > 0,
            backgroundColor: colors.error,
            child: const Icon(Icons.chat_bubble_outline),
          ),
          selectedIcon: Badge(
            label: Text(
              totalUnread > 99 ? '99+' : totalUnread.toString(),
              style: TextStyle(fontSize: 9, color: colors.onPrimary),
            ),
            isLabelVisible: totalUnread > 0,
            backgroundColor: colors.error,
            child: const Icon(Icons.chat_bubble),
          ),
          label: const Text('Chat'),
        ),
        const NavigationRailDestination(
          icon: Icon(Icons.add_circle_outline),
          selectedIcon: Icon(Icons.add_circle_outline),
          label: Text('Post'),
        ),
        NavigationRailDestination(
          icon: Badge(
            label: Text(
              unreadOrderUpdates > 99
                  ? '99+'
                  : unreadOrderUpdates.toString(),
              style: TextStyle(fontSize: 9, color: colors.onPrimary),
            ),
            isLabelVisible: unreadOrderUpdates > 0,
            backgroundColor: colors.error,
            child: const Icon(Icons.receipt_long_outlined),
          ),
          selectedIcon: Badge(
            label: Text(
              unreadOrderUpdates > 99
                  ? '99+'
                  : unreadOrderUpdates.toString(),
              style: TextStyle(fontSize: 9, color: colors.onPrimary),
            ),
            isLabelVisible: unreadOrderUpdates > 0,
            backgroundColor: colors.error,
            child: const Icon(Icons.receipt_long),
          ),
          label: const Text('Orders'),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:smivo/core/providers/preferences_provider.dart';
import 'package:smivo/core/theme/breakpoints.dart';
import 'package:smivo/shared/widgets/bottom_nav_bar.dart';
import 'package:smivo/shared/widgets/floating_quick_nav.dart';
import 'package:smivo/shared/widgets/navigation_rail_bar.dart';

/// Provides a [ScrollController] down the widget tree so that the
/// ResponsiveScaffold can trigger scroll-to-top when the user taps the
/// Home nav item while already on the Home branch.
class HomeScrollControllerScope extends InheritedWidget {
  const HomeScrollControllerScope({
    super.key,
    required this.controller,
    required super.child,
  });

  final ScrollController controller;

  static HomeScrollControllerScope? maybeOf(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<HomeScrollControllerScope>();
  }

  @override
  bool updateShouldNotify(HomeScrollControllerScope oldWidget) =>
      controller != oldWidget.controller;
}

/// Adaptive scaffold that switches navigation style based on screen width.
///
/// - **Mobile** (< 600px): Bottom navigation bar (original behavior)
/// - **Tablet** (600–1024px): Left NavigationRail (compact icons + labels)
/// - **Desktop** (> 1024px): Left NavigationRail extended (icons + text labels)
///
/// This widget replaces the original [AppShell] to provide responsive
/// navigation across all device classes while preserving the existing
/// GoRouter shell-branch architecture.
class ResponsiveScaffold extends ConsumerWidget {
  const ResponsiveScaffold({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  void _onTap(BuildContext context, int index) {
    // NOTE: If the user taps Home while already on Home, scroll back to top
    // instead of re-navigating (which would be a no-op from GoRouter).
    if (index == 0 && navigationShell.currentIndex == 0) {
      final scope = HomeScrollControllerScope.maybeOf(context);
      if (scope != null && scope.controller.hasClients) {
        scope.controller.animateTo(
          0,
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeOutCubic,
        );
        return;
      }
    }
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final showFloating = ref.watch(showFloatingNavProvider);
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;

        // --- Mobile: original bottom nav layout ---
        if (Breakpoints.isMobile(width)) {
          return Scaffold(
            body: Stack(
              children: [
                navigationShell,
                // NOTE: FloatingQuickNav is only shown when the user
                // has not disabled it in System Settings.
                if (showFloating) const FloatingQuickNav(),
              ],
            ),
            extendBody: true,
            bottomNavigationBar: BottomNavBar(
              currentIndex: navigationShell.currentIndex,
              onTap: (index) => _onTap(context, index),
            ),
          );
        }

        // --- Tablet / Desktop: side rail + content ---
        final isDesktop = Breakpoints.isDesktop(width);

        return Scaffold(
          body: Row(
            children: [
              // NOTE: NavigationRail is wrapped in a themed container
              // to visually separate it from the main content area.
              NavigationRailBar(
                currentIndex: _shellToRailIndex(navigationShell.currentIndex),
                onTap: (index) => _onTap(context, index),
                extended: isDesktop,
              ),
              // Vertical divider between rail and content
              VerticalDivider(
                thickness: 1,
                width: 1,
                color: Theme.of(context).dividerColor.withValues(alpha: 0.12),
              ),
              // Main content area fills remaining space
              Expanded(child: navigationShell),
            ],
          ),
        );
      },
    );
  }

  /// Maps shell branch index (0=Home, 1=Chat, 2=Orders) to rail index
  /// (0=Home, 1=Chat, 2=Post, 3=Orders) because the rail has the
  /// extra "Post" destination at index 2.
  int _shellToRailIndex(int shellIndex) {
    // Shell branches: 0=Home, 1=Chat, 2=Orders
    // Rail destinations: 0=Home, 1=Chat, 2=Post, 3=Orders
    if (shellIndex >= 2) return shellIndex + 1;
    return shellIndex;
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:smivo/core/providers/nav_scroll_provider.dart';
import 'package:smivo/core/theme/breakpoints.dart';
import 'package:smivo/shared/widgets/bottom_nav_bar.dart';

// NOTE: HomeScrollControllerScope is kept here because HomeScreen still wraps
// itself with it for PrimaryScrollController / iOS status-bar tap-to-top
// behaviour. It is no longer used by ResponsiveScaffold's own tap logic
// (which now uses Riverpod providers instead — see nav_scroll_provider.dart).
/// Provides a [ScrollController] down the widget tree.
/// Primarily used so iOS status-bar taps can find the Home scroll view.
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
/// ## Scroll-to-top on re-tap
/// When the user taps a nav button they are already on, instead of navigating,
/// this widget increments [homeScrollTriggerProvider] or
/// [chatScrollTriggerProvider]. The target screen listens to that provider
/// and animates its list to the top.
///
/// NOTE: We use Riverpod providers (not InheritedWidget) because
/// InheritedWidget.maybeOf() only traverses UP the widget tree, but the
/// scroll controllers live BELOW ResponsiveScaffold (inside navigationShell).
class ResponsiveScaffold extends ConsumerWidget {
  const ResponsiveScaffold({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // NOTE: Defined inside build() so it can close over `ref` without
    // converting ResponsiveScaffold to a StatefulWidget.
    void onTap(int index) {
      // If the user taps Home while already on Home, signal HomeScreen
      // to scroll to top via the provider — do NOT re-navigate.
      if (index == 0 && navigationShell.currentIndex == 0) {
        ref.read(homeScrollTriggerProvider.notifier).trigger();
        return;
      }
      // If the user taps Chat while already on Chat, signal ChatListScreen
      // to scroll to top via the provider — do NOT re-navigate.
      if (index == 1 && navigationShell.currentIndex == 1) {
        ref.read(chatScrollTriggerProvider.notifier).trigger();
        return;
      }
      navigationShell.goBranch(
        index,
        initialLocation: index == navigationShell.currentIndex,
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;

        // --- Mobile: original bottom nav layout ---
        if (Breakpoints.isMobile(width)) {
          return Scaffold(
            body: navigationShell,
            extendBody: true,
            bottomNavigationBar:
                navigationShell.currentIndex == 2
                    ? null
                    : BottomNavBar(
                      currentIndex: navigationShell.currentIndex,
                      onTap: onTap,
                    ),
          );
        }

        // --- Tablet / Desktop ---
        // GlobalLayoutShell handles the sidebar on iPad/Desktop.
        // We just return the shell content here.
        return navigationShell;
      },
    );
  }
}

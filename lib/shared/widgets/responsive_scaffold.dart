import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:smivo/core/theme/breakpoints.dart';
import 'package:smivo/shared/widgets/bottom_nav_bar.dart';
import 'package:smivo/shared/widgets/navigation_rail_bar.dart';

/// Adaptive scaffold that switches navigation style based on screen width.
///
/// - **Mobile** (< 600px): Bottom navigation bar (original behavior)
/// - **Tablet** (600–1024px): Left NavigationRail (compact icons + labels)
/// - **Desktop** (> 1024px): Left NavigationRail extended (icons + text labels)
///
/// This widget replaces the original [AppShell] to provide responsive
/// navigation across all device classes while preserving the existing
/// GoRouter shell-branch architecture.
class ResponsiveScaffold extends StatelessWidget {
  const ResponsiveScaffold({
    super.key,
    required this.navigationShell,
  });

  final StatefulNavigationShell navigationShell;

  void _onTap(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;

        // --- Mobile: original bottom nav layout ---
        if (Breakpoints.isMobile(width)) {
          return Scaffold(
            body: navigationShell,
            extendBody: true,
            bottomNavigationBar: BottomNavBar(
              currentIndex: navigationShell.currentIndex,
              onTap: _onTap,
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
                onTap: _onTap,
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

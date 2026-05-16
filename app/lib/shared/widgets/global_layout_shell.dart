import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:smivo/core/theme/breakpoints.dart';
import 'package:smivo/shared/widgets/navigation_rail_bar.dart';

class GlobalLayoutShell extends StatelessWidget {
  const GlobalLayoutShell({
    super.key,
    required this.child,
    required this.state,
  });

  final Widget child;
  final GoRouterState state;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;

        // Mobile uses the standard layout (handled by ResponsiveScaffold inside StatefulShellRoute)
        // For top-level routes outside StatefulShellRoute, Mobile just shows them full screen.
        if (Breakpoints.isMobile(width)) {
          return child;
        }

        // --- Tablet / Desktop Global Sidebar ---
        final isDesktop = Breakpoints.isDesktop(width);

        // Determine the active tab based on the current URI path
        final location = state.uri.path;
        int currentIndex = 0; // Default to Home

        if (location.startsWith('/chat')) {
          currentIndex = 1;
        } else if (location.startsWith('/create-listing')) {
          currentIndex = 2;
        } else if (location.startsWith('/carpool')) {
          currentIndex = 3;
        } else if (location.startsWith('/orders') ||
            location.startsWith('/buyer') ||
            location.startsWith('/seller')) {
          currentIndex = 4;
        }
        // Notification, Profile, Settings default to 0 (Home active) or we could add another logic.
        // For now, retaining 0 is fine since they are accessed from Home/Profile usually.

        return Scaffold(
          body: Row(
            children: [
              NavigationRailBar(
                currentIndex: currentIndex,
                onTap: (index) {
                  switch (index) {
                    case 0:
                      context.goNamed('home');
                      break;
                    case 1:
                      context.goNamed('chatList');
                      break;
                    case 2:
                      context.goNamed('createListing');
                      break;
                    case 3:
                      context.goNamed('carpoolList');
                      break;
                    case 4:
                      context.goNamed('orders');
                      break;
                  }
                },
                extended: isDesktop,
              ),
              VerticalDivider(
                thickness: 1,
                width: 1,
                color: Theme.of(context).dividerColor.withValues(alpha: 0.12),
              ),
              Expanded(child: child),
            ],
          ),
        );
      },
    );
  }
}

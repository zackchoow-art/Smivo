import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:smivo/shared/widgets/responsive_scaffold.dart';

/// Root shell widget used by GoRouter's [StatefulShellRoute].
///
/// Delegates entirely to [ResponsiveScaffold] which handles
/// adaptive navigation (BottomNav / Rail / Sidebar) based on
/// screen width breakpoints.
class AppShell extends StatelessWidget {
  const AppShell({
    super.key,
    required this.navigationShell,
  });

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    return ResponsiveScaffold(navigationShell: navigationShell);
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/router/router.dart';
import 'core/theme/app_theme.dart';

/// Root application widget.
///
/// Uses MaterialApp.router with GoRouter for declarative navigation
/// and the light theme from AppTheme. Dark theme will be added in Phase 2.
class SmivoApp extends ConsumerWidget {
  const SmivoApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'Smivo',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      // TODO: Add darkTheme in Phase 2.
      routerConfig: router,
    );
  }
}

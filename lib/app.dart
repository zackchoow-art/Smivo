import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/providers/theme_provider.dart';
import 'core/router/router.dart';
import 'core/theme/app_theme.dart';

/// Root application widget.
///
/// Uses MaterialApp.router with GoRouter for declarative navigation.
/// The theme is driven by [ThemeNotifier], which persists the user's
/// chosen [SmivoThemeVariant] across sessions.
class SmivoApp extends ConsumerWidget {
  const SmivoApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final themeVariant = ref.watch(themeNotifierProvider);

    return MaterialApp.router(
      title: 'Smivo',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.buildTheme(themeVariant),
      routerConfig: router,
    );
  }
}

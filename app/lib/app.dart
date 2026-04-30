import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/providers/push_notification_provider.dart';
import 'core/providers/theme_provider.dart';
import 'core/router/router.dart';
import 'core/theme/app_theme.dart';

import 'dart:async';
import 'package:app_links/app_links.dart';

/// Root application widget.
///
/// Uses MaterialApp.router with GoRouter for declarative navigation.
/// The theme is driven by [ThemeNotifier], which persists the user's
/// chosen [SmivoThemeVariant] across sessions.
class SmivoApp extends ConsumerStatefulWidget {
  const SmivoApp({super.key});

  @override
  ConsumerState<SmivoApp> createState() => _SmivoAppState();
}

class _SmivoAppState extends ConsumerState<SmivoApp> {
  late AppLinks _appLinks;
  StreamSubscription<Uri>? _linkSubscription;

  @override
  void initState() {
    super.initState();
    _initDeepLinks();
  }

  Future<void> _initDeepLinks() async {
    _appLinks = AppLinks();
    
    // Check initial link if app was in cold state (terminated)
    try {
      final initialUri = await _appLinks.getInitialLink();
      if (initialUri != null) {
        _handleDeepLink(initialUri);
      }
    } catch (e) {
      debugPrint('Error handling initial deep link: $e');
    }

    // Handle link when app is in warm state (foreground or background)
    _linkSubscription = _appLinks.uriLinkStream.listen((uri) {
      _handleDeepLink(uri);
    }, onError: (err) {
      debugPrint('Error handling incoming deep link: $err');
    });
  }

  void _handleDeepLink(Uri uri) {
    if (uri.path.isNotEmpty) {
      // Defer navigation until the router is ready
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(routerProvider).go(uri.path);
      });
    }
  }

  @override
  void dispose() {
    _linkSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Initialize push notification lifecycle
    ref.watch(pushNotificationManagerProvider);

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

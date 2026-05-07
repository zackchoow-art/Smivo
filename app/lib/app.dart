import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'core/providers/preferences_provider.dart';
import 'core/providers/push_notification_provider.dart';
import 'core/providers/theme_provider.dart';
import 'core/providers/shake_feedback_provider.dart';
import 'core/router/router.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/breakpoints.dart';
import 'shared/widgets/floating_quick_nav.dart';

import 'dart:async';
import 'package:app_links/app_links.dart';

import 'package:feedback/feedback.dart';
import 'package:shake/shake.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:smivo/data/repositories/storage_repository.dart';
import 'package:smivo/data/repositories/feedback_repository.dart';
import 'package:smivo/features/auth/providers/auth_provider.dart';
import 'package:uuid/uuid.dart';

/// Global navigator key so BetterFeedback callbacks (which run outside the
/// MaterialApp widget tree) can access ScaffoldMessenger correctly.
///
/// NOTE: BetterFeedback wraps MaterialApp, meaning its callback context has
/// no ScaffoldMessenger ancestor. We retrieve the navigator key from GoRouter
/// directly (routerDelegate.navigatorKey) rather than injecting a custom key.
// Intentionally not using a custom key here — see _showSnackBar() for pattern.

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
    _linkSubscription = _appLinks.uriLinkStream.listen(
      (uri) {
        _handleDeepLink(uri);
      },
      onError: (err) {
        debugPrint('Error handling incoming deep link: $err');
      },
    );
  }

  void _handleDeepLink(Uri uri) {
    // NOTE: Auth callback deep links carry tokens from email verification.
    //
    // IMPORTANT: In custom URL schemes, Dart's Uri parser treats the part
    // after :// as the HOST, not the path:
    //   smivo://auth/callback  →  host="auth", path="/callback"
    //   https://smivo.io/auth/callback  →  host="smivo.io", path="/auth/callback"
    // We must check both formats to handle custom scheme + Universal Links.
    debugPrint('[DeepLink] received: $uri');
    debugPrint('[DeepLink] scheme=${uri.scheme} host=${uri.host} path=${uri.path}');
    debugPrint('[DeepLink] queryParams=${uri.queryParameters}');

    if (_isAuthCallback(uri)) {
      debugPrint('[DeepLink] matched auth callback');

      // PKCE flow (supabase_flutter v2+ default): code in query params
      final code = uri.queryParameters['code'];
      if (code != null && code.isNotEmpty) {
        debugPrint('[DeepLink] PKCE code present, exchanging for session...');
        _handlePkceCallback(code);
        return;
      }

      // Legacy implicit flow: refresh_token in query params
      final refreshToken = uri.queryParameters['refresh_token'];
      if (refreshToken != null && refreshToken.isNotEmpty) {
        debugPrint('[DeepLink] refresh_token present, calling setSession...');
        _handleImplicitCallback(refreshToken);
        return;
      }

      // No tokens — just navigate to home (legacy "Open App" behavior)
      debugPrint('[DeepLink] no auth data, going to /');
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(routerProvider).go('/');
      });
      return;
    }

    debugPrint('[DeepLink] not auth callback, going to ${uri.path}');
    // Regular deep link (e.g. /listing/<id>)
    if (uri.path.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(routerProvider).go(uri.path);
      });
    }
  }

  /// Detects whether [uri] is an auth callback, handling both:
  /// - Custom URL scheme: smivo://auth/callback (host=auth, path=/callback)
  /// - Universal Link: https://smivo.io/auth/callback (path=/auth/callback)
  bool _isAuthCallback(Uri uri) {
    // Custom scheme: smivo://auth/callback
    if (uri.host == 'auth' && uri.path == '/callback') return true;
    // Universal Link: https://smivo.io/auth/callback
    if (uri.path == '/auth/callback') return true;
    return false;
  }

  /// PKCE flow: exchanges the one-time authorization code for a full session.
  /// Used by supabase_flutter v2+ (PKCE is the default auth flow).
  Future<void> _handlePkceCallback(String code) async {
    try {
      await Supabase.instance.client.auth.exchangeCodeForSession(code);
      debugPrint('[DeepLink] PKCE exchange succeeded — user logged in');
      // NOTE: exchangeCodeForSession triggers onAuthStateChange.
      // GoRouter's redirect will auto-navigate to home or profile setup.
    } catch (e, stack) {
      debugPrint('[DeepLink] PKCE exchange FAILED: $e');
      debugPrint('[DeepLink] stack: $stack');
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(routerProvider).go('/');
      });
    }
  }

  /// Implicit flow: restores session from a refresh token.
  /// Fallback for environments where PKCE is not used.
  Future<void> _handleImplicitCallback(String refreshToken) async {
    try {
      await Supabase.instance.client.auth.setSession(refreshToken);
      debugPrint('[DeepLink] setSession succeeded — user logged in');
    } catch (e, stack) {
      debugPrint('[DeepLink] setSession FAILED: $e');
      debugPrint('[DeepLink] stack: $stack');
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(routerProvider).go('/');
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
    final themeVariant = ref.watch(themeProvider);
    final isShakeFeedbackEnabled = ref.watch(shakeFeedbackProvider);

    final showFloating = ref.watch(showFloatingNavProvider);

    final app = MaterialApp.router(
      title: 'Smivo',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.buildTheme(themeVariant),
      routerConfig: router,
      builder: (context, child) {
        final content = child ?? const SizedBox.shrink();
        final width = MediaQuery.of(context).size.width;
        final isMobile = Breakpoints.isMobile(width);

        // NOTE: Only overlay on mobile when the user hasn't disabled it.
        if (!isMobile || !showFloating) return content;

        // NOTE: MaterialApp.builder is NOT re-invoked on route changes.
        // Wrap with ValueListenableBuilder so the FloatingQuickNav
        // reactively appears/disappears as the user navigates.
        return ValueListenableBuilder<RouteInformation>(
          valueListenable: router.routeInformationProvider,
          builder: (context, routeInfo, _) {
            final location = routeInfo.uri.path;
            if (_isShellOrExcludedRoute(location)) return content;

            return Stack(
              children: [content, const FloatingQuickNav()],
            );
          },
        );
      },
    );

    if (isShakeFeedbackEnabled) {
      return BetterFeedback(child: _ShakeWrapper(child: app));
    }

    return app;
  }

  /// Routes where the floating nav should NOT appear — either because
  /// they already have bottom navigation (shell tabs) or because showing
  /// a nav shortcut is inappropriate (auth / admin flows).
  static bool _isShellOrExcludedRoute(String path) {
    const excluded = {
      '/home',
      '/chats',
      '/orders',
      '/login',
      '/register',
      '/verify-email',
      '/forgot-password',
      '/profile-setup',
    };
    if (excluded.contains(path)) return true;
    // Admin routes all start with /admin
    if (path.startsWith('/admin')) return true;
    return false;
  }
}

class _ShakeWrapper extends ConsumerStatefulWidget {
  final Widget child;
  const _ShakeWrapper({required this.child});

  @override
  ConsumerState<_ShakeWrapper> createState() => _ShakeWrapperState();
}

class _ShakeWrapperState extends ConsumerState<_ShakeWrapper> {
  ShakeDetector? _detector;

  @override
  void initState() {
    super.initState();
    _detector = ShakeDetector.autoStart(onPhoneShake: _onShake);
  }

  /// Shows a SnackBar via GoRouter's navigator key.
  ///
  /// NOTE: We cannot use ScaffoldMessenger.of(context) here because
  /// _ShakeWrapper sits OUTSIDE MaterialApp (it wraps it). GoRouter's
  /// routerDelegate.navigatorKey.currentContext IS inside MaterialApp
  /// and therefore has a ScaffoldMessenger ancestor.
  void _showSnackBar(String message) {
    final navContext =
        ref.read(routerProvider).routerDelegate.navigatorKey.currentContext;
    if (navContext == null) return;
    ScaffoldMessenger.of(
      navContext,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  void _onShake(ShakeEvent event) {
    // Prevent multiple triggers if feedback panel is already visible.
    // Typing on the keyboard can sometimes cause micro-shakes that trigger
    // again while the panel is open, corrupting the transform matrix.
    if (BetterFeedback.of(context).isVisible) {
      return;
    }

    // Show feedback panel
    BetterFeedback.of(context).show((UserFeedback feedback) async {
      try {
        final authUser = ref.read(authStateProvider).value;
        if (authUser == null) {
          _showSnackBar('Please log in to submit feedback.');
          return;
        }

        // Compress the screenshot
        final compressedImage = await FlutterImageCompress.compressWithList(
          feedback.screenshot,
          minHeight: 1920,
          minWidth: 1080,
          quality: 70,
        );

        // Upload to storage
        final fileName = '${const Uuid().v4()}.jpg';
        final storageRepo = ref.read(storageRepositoryProvider);
        final url = await storageRepo.uploadFeedbackImage(
          userId: authUser.id,
          fileName: fileName,
          fileBytes: compressedImage,
        );

        // Submit feedback to database
        final feedbackRepo = ref.read(feedbackRepositoryProvider);
        await feedbackRepo.submitFeedback(
          userId: authUser.id,
          type: 'bug',
          title: 'Shake Feedback',
          description:
              feedback.text.isEmpty ? 'Screenshot attached' : feedback.text,
          screenshotUrl: url,
        );

        // Close the feedback panel after successful submission
        if (mounted) {
          BetterFeedback.of(context).hide();
        }

        _showSnackBar('Feedback submitted! Thank you 🙌');
      } catch (e) {
        debugPrint('Error submitting feedback: $e');
        _showSnackBar('Failed to submit feedback. Please try again.');
      }
    });
  }

  @override
  void dispose() {
    _detector?.stopListening();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

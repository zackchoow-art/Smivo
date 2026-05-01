import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/providers/push_notification_provider.dart';
import 'core/providers/theme_provider.dart';
import 'core/providers/shake_feedback_provider.dart';
import 'core/router/router.dart';
import 'core/theme/app_theme.dart';

import 'dart:async';
import 'package:app_links/app_links.dart';

import 'package:feedback/feedback.dart';
import 'package:shake/shake.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:smivo/data/repositories/storage_repository.dart';
import 'package:smivo/data/repositories/feedback_repository.dart';
import 'package:smivo/features/auth/providers/auth_provider.dart';
import 'package:uuid/uuid.dart';

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
    final isShakeFeedbackEnabled = ref.watch(shakeFeedbackNotifierProvider);

    final app = MaterialApp.router(
      title: 'Smivo',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.buildTheme(themeVariant),
      routerConfig: router,
    );

    if (isShakeFeedbackEnabled) {
      return BetterFeedback(
        child: _ShakeWrapper(child: app),
      );
    }

    return app;
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
    _detector = ShakeDetector.autoStart(
      onPhoneShake: _onShake,
    );
  }

  void _onShake(ShakeEvent event) {
    // Prevent multiple triggers if feedback panel is already visible.
    // Typing on the keyboard can sometimes cause micro-shakes that trigger this
    // again while the panel is open, corrupting the transform matrix (causing the app to be stuck shifted to bottom right).
    if (BetterFeedback.of(context).isVisible) {
      return;
    }

    // Show feedback panel
    BetterFeedback.of(context).show((UserFeedback feedback) async {
      try {
        final authUser = ref.read(authStateProvider).valueOrNull;
        if (authUser == null) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Please log in to submit feedback.')),
            );
          }
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
          description: feedback.text.isEmpty ? 'Screenshot attached' : feedback.text,
          screenshotUrl: url,
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Feedback submitted successfully! Thank you!')),
          );
        }
      } catch (e) {
        debugPrint('Error submitting feedback: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to submit feedback. Please try again.')),
          );
        }
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

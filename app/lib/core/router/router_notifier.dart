import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:smivo/features/auth/providers/auth_provider.dart';
import 'package:smivo/features/profile/providers/profile_provider.dart';
import 'package:smivo/core/router/app_routes.dart';

part 'router_notifier.g.dart';

/// Bridges Riverpod auth/profile state into GoRouter's redirect mechanism
/// WITHOUT recreating the GoRouter instance.
///
/// NOTE: This implements Listenable so GoRouter can subscribe to it via
/// refreshListenable. When auth or profile state changes, GoRouter calls
/// redirect() again — but the router object and navigation stack are
/// preserved. The old pattern (ref.watch inside the router provider) was
/// wrong because it caused GoRouter to be fully recreated on every auth
/// event, clearing the navigation stack and dropping the user to home.
@riverpod
class AppRouterNotifier extends _$AppRouterNotifier implements Listenable {
  /// The single callback GoRouter registers via addListener().
  VoidCallback? _routerListener;

  @override
  Future<void> build() async {
    // Watch both providers so this notifier rebuilds when either changes.
    // NOTE: We do NOT use the values here — they are read inside redirect()
    // which is called synchronously by GoRouter after we call the listener.
    ref.watch(authStateProvider);
    ref.watch(profileProvider);

    // Notify GoRouter to re-evaluate redirect() with fresh state.
    _routerListener?.call();
  }

  // ── Listenable implementation ──────────────────────────────────

  @override
  void addListener(VoidCallback listener) {
    _routerListener = listener;
  }

  @override
  void removeListener(VoidCallback listener) {
    if (_routerListener == listener) _routerListener = null;
  }

  // ── Redirect logic (previously inline in router.dart) ──────────

  /// Called by GoRouter every time this notifier fires or the current
  /// location changes. Returns a redirect path, or null to stay put.
  String? redirect(BuildContext context, GoRouterState state) {
    // Read current auth/profile state synchronously.
    final authStateValue = ref.read(authStateProvider);

    // NOTE: Guard against loading state — when auth is still resolving
    // (e.g. app just launched or mid sign-in/sign-out), return null to stay
    // put. The notifier will fire again once the state settles, triggering
    // a second redirect evaluation with the correct values.
    if (authStateValue.isLoading) return null;

    final user = authStateValue.value;
    final isLoggedIn = user != null;
    final isEmailVerified = user?.emailConfirmedAt != null;

    final profileValue = ref.read(profileProvider);
    final profile = profileValue.value;
    final needsOnboarding = profile != null && profile.displayName == null;

    final currentPath = state.matchedLocation;

    // ─── STATE 1: Fully Authenticated & Onboarded ───────────────
    if (isLoggedIn && isEmailVerified && !needsOnboarding) {
      if (currentPath == AppRoutes.splashPath ||
          currentPath == AppRoutes.loginPath ||
          currentPath == AppRoutes.registerPath ||
          currentPath == AppRoutes.profileSetupPath) {
        return AppRoutes.homePath;
      }
      return null;
    }

    // ─── STATE 2: Logged in & Verified but Needs Onboarding ─────
    if (isLoggedIn && isEmailVerified && needsOnboarding) {
      if (currentPath == AppRoutes.profileSetupPath) return null;
      return AppRoutes.profileSetupPath;
    }

    // ─── STATE 3: Logged in but NOT Verified ────────────────────
    if (isLoggedIn && !isEmailVerified) {
      if (currentPath == AppRoutes.emailVerificationPath ||
          currentPath == AppRoutes.loginPath) {
        return null;
      }
      final email = user.email ?? '';
      return '${AppRoutes.emailVerificationPath}?email=$email';
    }

    // ─── STATE 4: Guest (Not Logged In) ─────────────────────────
    if (!isLoggedIn) {
      if (_isPublicRoute(currentPath)) return null;
      final encodedPath = Uri.encodeComponent(currentPath);
      return '${AppRoutes.loginPath}?returnTo=$encodedPath';
    }

    return null;
  }
}

/// Routes that guests can access without authentication.
const _publicRoutePaths = {
  AppRoutes.homePath,
  AppRoutes.loginPath,
  AppRoutes.forgotPasswordPath,
  AppRoutes.registerPath,
  AppRoutes.emailVerificationPath,
};

bool _isPublicRoute(String path) {
  if (_publicRoutePaths.contains(path)) return true;
  // Listing detail (/listing/:id) is public for guest browsing.
  // /listing/create and /listing/:id/edit require auth.
  if (path.startsWith('/listing/') && path != '/listing/create') {
    if (!path.endsWith('/edit')) return true;
  }
  // Admin routes have their own auth flow.
  if (path.startsWith('/admin')) return true;
  return false;
}

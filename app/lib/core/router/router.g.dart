// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'router.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// GoRouter configuration with reactive auth redirect guard.
///
/// Handles four authentication/onboarding states:
/// 1. Guest: Access to home, listing details, login, and register.
/// 2. Unverified: Logged in but email not confirmed. Restricted to verification screen.
/// 3. Needs Onboarding: Logged in, verified, but display name is missing.
/// 4. Authenticated: Full access. Redirects away from auth screens to home.

@ProviderFor(router)
final routerProvider = RouterProvider._();

/// GoRouter configuration with reactive auth redirect guard.
///
/// Handles four authentication/onboarding states:
/// 1. Guest: Access to home, listing details, login, and register.
/// 2. Unverified: Logged in but email not confirmed. Restricted to verification screen.
/// 3. Needs Onboarding: Logged in, verified, but display name is missing.
/// 4. Authenticated: Full access. Redirects away from auth screens to home.

final class RouterProvider
    extends $FunctionalProvider<GoRouter, GoRouter, GoRouter>
    with $Provider<GoRouter> {
  /// GoRouter configuration with reactive auth redirect guard.
  ///
  /// Handles four authentication/onboarding states:
  /// 1. Guest: Access to home, listing details, login, and register.
  /// 2. Unverified: Logged in but email not confirmed. Restricted to verification screen.
  /// 3. Needs Onboarding: Logged in, verified, but display name is missing.
  /// 4. Authenticated: Full access. Redirects away from auth screens to home.
  RouterProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'routerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$routerHash();

  @$internal
  @override
  $ProviderElement<GoRouter> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  GoRouter create(Ref ref) {
    return router(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GoRouter value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GoRouter>(value),
    );
  }
}

String _$routerHash() => r'09c5201dddf341c84c47b8b1cb9151052a3a2eab';

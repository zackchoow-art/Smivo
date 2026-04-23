// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'router.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$routerHash() => r'5728a0ddac61db53d18ee052fd99aa131d17ce55';

/// GoRouter configuration with reactive auth redirect guard.
///
/// Handles four authentication/onboarding states:
/// 1. Guest: Access to home, listing details, login, and register.
/// 2. Unverified: Logged in but email not confirmed. Restricted to verification screen.
/// 3. Needs Onboarding: Logged in, verified, but display name is missing.
/// 4. Authenticated: Full access. Redirects away from auth screens to home.
///
/// Copied from [router].
@ProviderFor(router)
final routerProvider = AutoDisposeProvider<GoRouter>.internal(
  router,
  name: r'routerProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$routerHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef RouterRef = AutoDisposeProviderRef<GoRouter>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package

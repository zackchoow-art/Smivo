// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'router.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// GoRouter configuration.
///
/// NOTE: keepAlive: true is CRITICAL here. Without it, the router provider
/// can be garbage-collected and recreated, which destroys the navigation
/// stack and drops the user to the home screen.
///
/// Auth/profile state changes are handled via RouterNotifier (Listenable),
/// which triggers GoRouter.redirect() re-evaluation WITHOUT recreating the
/// GoRouter instance. This is the correct pattern for GoRouter + Riverpod.

@ProviderFor(router)
final routerProvider = RouterProvider._();

/// GoRouter configuration.
///
/// NOTE: keepAlive: true is CRITICAL here. Without it, the router provider
/// can be garbage-collected and recreated, which destroys the navigation
/// stack and drops the user to the home screen.
///
/// Auth/profile state changes are handled via RouterNotifier (Listenable),
/// which triggers GoRouter.redirect() re-evaluation WITHOUT recreating the
/// GoRouter instance. This is the correct pattern for GoRouter + Riverpod.

final class RouterProvider
    extends $FunctionalProvider<GoRouter, GoRouter, GoRouter>
    with $Provider<GoRouter> {
  /// GoRouter configuration.
  ///
  /// NOTE: keepAlive: true is CRITICAL here. Without it, the router provider
  /// can be garbage-collected and recreated, which destroys the navigation
  /// stack and drops the user to the home screen.
  ///
  /// Auth/profile state changes are handled via RouterNotifier (Listenable),
  /// which triggers GoRouter.redirect() re-evaluation WITHOUT recreating the
  /// GoRouter instance. This is the correct pattern for GoRouter + Riverpod.
  RouterProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'routerProvider',
        isAutoDispose: false,
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

String _$routerHash() => r'b9d6985c358aec68b3b0d8ce49d4a0d5d7b36907';

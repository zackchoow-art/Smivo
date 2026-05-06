// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'router_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Bridges Riverpod auth/profile state into GoRouter's redirect mechanism
/// WITHOUT recreating the GoRouter instance.
///
/// NOTE: This implements Listenable so GoRouter can subscribe to it via
/// refreshListenable. When auth or profile state changes, GoRouter calls
/// redirect() again — but the router object and navigation stack are
/// preserved. The old pattern (ref.watch inside the router provider) was
/// wrong because it caused GoRouter to be fully recreated on every auth
/// event, clearing the navigation stack and dropping the user to home.
// NOTE: keepAlive: true is CRITICAL — this notifier holds the single
// GoRouter listener (VoidCallback). If auto-disposed and recreated,
// _routerListener is reset to null, GoRouter loses the subscription,
// and redirect() is never called after sign-in / sign-out.

@ProviderFor(AppRouterNotifier)
final appRouterProvider = AppRouterNotifierProvider._();

/// Bridges Riverpod auth/profile state into GoRouter's redirect mechanism
/// WITHOUT recreating the GoRouter instance.
///
/// NOTE: This implements Listenable so GoRouter can subscribe to it via
/// refreshListenable. When auth or profile state changes, GoRouter calls
/// redirect() again — but the router object and navigation stack are
/// preserved. The old pattern (ref.watch inside the router provider) was
/// wrong because it caused GoRouter to be fully recreated on every auth
/// event, clearing the navigation stack and dropping the user to home.
// NOTE: keepAlive: true is CRITICAL — this notifier holds the single
// GoRouter listener (VoidCallback). If auto-disposed and recreated,
// _routerListener is reset to null, GoRouter loses the subscription,
// and redirect() is never called after sign-in / sign-out.
final class AppRouterNotifierProvider
    extends $NotifierProvider<AppRouterNotifier, void> {
  /// Bridges Riverpod auth/profile state into GoRouter's redirect mechanism
  /// WITHOUT recreating the GoRouter instance.
  ///
  /// NOTE: This implements Listenable so GoRouter can subscribe to it via
  /// refreshListenable. When auth or profile state changes, GoRouter calls
  /// redirect() again — but the router object and navigation stack are
  /// preserved. The old pattern (ref.watch inside the router provider) was
  /// wrong because it caused GoRouter to be fully recreated on every auth
  /// event, clearing the navigation stack and dropping the user to home.
  // NOTE: keepAlive: true is CRITICAL — this notifier holds the single
  // GoRouter listener (VoidCallback). If auto-disposed and recreated,
  // _routerListener is reset to null, GoRouter loses the subscription,
  // and redirect() is never called after sign-in / sign-out.
  AppRouterNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'appRouterProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$appRouterNotifierHash();

  @$internal
  @override
  AppRouterNotifier create() => AppRouterNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(void value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<void>(value),
    );
  }
}

String _$appRouterNotifierHash() => r'fc8f4c39546c7c6c5c1f66f2e922508d309c55fd';

/// Bridges Riverpod auth/profile state into GoRouter's redirect mechanism
/// WITHOUT recreating the GoRouter instance.
///
/// NOTE: This implements Listenable so GoRouter can subscribe to it via
/// refreshListenable. When auth or profile state changes, GoRouter calls
/// redirect() again — but the router object and navigation stack are
/// preserved. The old pattern (ref.watch inside the router provider) was
/// wrong because it caused GoRouter to be fully recreated on every auth
/// event, clearing the navigation stack and dropping the user to home.
// NOTE: keepAlive: true is CRITICAL — this notifier holds the single
// GoRouter listener (VoidCallback). If auto-disposed and recreated,
// _routerListener is reset to null, GoRouter loses the subscription,
// and redirect() is never called after sign-in / sign-out.

abstract class _$AppRouterNotifier extends $Notifier<void> {
  void build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<void, void>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<void, void>,
              void,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

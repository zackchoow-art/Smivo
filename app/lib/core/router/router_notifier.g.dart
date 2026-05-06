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
final class AppRouterNotifierProvider
    extends $AsyncNotifierProvider<AppRouterNotifier, void> {
  /// Bridges Riverpod auth/profile state into GoRouter's redirect mechanism
  /// WITHOUT recreating the GoRouter instance.
  ///
  /// NOTE: This implements Listenable so GoRouter can subscribe to it via
  /// refreshListenable. When auth or profile state changes, GoRouter calls
  /// redirect() again — but the router object and navigation stack are
  /// preserved. The old pattern (ref.watch inside the router provider) was
  /// wrong because it caused GoRouter to be fully recreated on every auth
  /// event, clearing the navigation stack and dropping the user to home.
  AppRouterNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'appRouterProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$appRouterNotifierHash();

  @$internal
  @override
  AppRouterNotifier create() => AppRouterNotifier();
}

String _$appRouterNotifierHash() => r'26b7b4627a5974e146ffd2d5f50990dbc4f6bfe6';

/// Bridges Riverpod auth/profile state into GoRouter's redirect mechanism
/// WITHOUT recreating the GoRouter instance.
///
/// NOTE: This implements Listenable so GoRouter can subscribe to it via
/// refreshListenable. When auth or profile state changes, GoRouter calls
/// redirect() again — but the router object and navigation stack are
/// preserved. The old pattern (ref.watch inside the router provider) was
/// wrong because it caused GoRouter to be fully recreated on every auth
/// event, clearing the navigation stack and dropping the user to home.

abstract class _$AppRouterNotifier extends $AsyncNotifier<void> {
  FutureOr<void> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<void>, void>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<void>, void>,
              AsyncValue<void>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

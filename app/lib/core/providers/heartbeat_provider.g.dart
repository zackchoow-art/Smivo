// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'heartbeat_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Sends heartbeat every 5 minutes while the app is in foreground.
/// keepAlive: true — lives for the entire app session.
///
/// Uses AppLifecycleListener (Flutter 3.13+) to pause heartbeat
/// when app goes to background and resume when returning.

@ProviderFor(HeartbeatManager)
final heartbeatManagerProvider = HeartbeatManagerProvider._();

/// Sends heartbeat every 5 minutes while the app is in foreground.
/// keepAlive: true — lives for the entire app session.
///
/// Uses AppLifecycleListener (Flutter 3.13+) to pause heartbeat
/// when app goes to background and resume when returning.
final class HeartbeatManagerProvider
    extends $NotifierProvider<HeartbeatManager, void> {
  /// Sends heartbeat every 5 minutes while the app is in foreground.
  /// keepAlive: true — lives for the entire app session.
  ///
  /// Uses AppLifecycleListener (Flutter 3.13+) to pause heartbeat
  /// when app goes to background and resume when returning.
  HeartbeatManagerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'heartbeatManagerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$heartbeatManagerHash();

  @$internal
  @override
  HeartbeatManager create() => HeartbeatManager();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(void value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<void>(value),
    );
  }
}

String _$heartbeatManagerHash() => r'ba43e036a497eb357b5cf578374448adf568307e';

/// Sends heartbeat every 5 minutes while the app is in foreground.
/// keepAlive: true — lives for the entire app session.
///
/// Uses AppLifecycleListener (Flutter 3.13+) to pause heartbeat
/// when app goes to background and resume when returning.

abstract class _$HeartbeatManager extends $Notifier<void> {
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

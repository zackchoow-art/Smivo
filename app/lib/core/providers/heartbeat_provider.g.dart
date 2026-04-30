// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'heartbeat_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$heartbeatManagerHash() => r'26dbb9aa65280165c8635ba6c05438a207ef8b64';

/// Sends heartbeat every 5 minutes while the app is in foreground.
/// keepAlive: true — lives for the entire app session.
///
/// Uses AppLifecycleListener (Flutter 3.13+) to pause heartbeat
/// when app goes to background and resume when returning.
///
/// Copied from [HeartbeatManager].
@ProviderFor(HeartbeatManager)
final heartbeatManagerProvider =
    NotifierProvider<HeartbeatManager, void>.internal(
      HeartbeatManager.new,
      name: r'heartbeatManagerProvider',
      debugGetCreateSourceHash:
          const bool.fromEnvironment('dart.vm.product')
              ? null
              : _$heartbeatManagerHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$HeartbeatManager = Notifier<void>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package

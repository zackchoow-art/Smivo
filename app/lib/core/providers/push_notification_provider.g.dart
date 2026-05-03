// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'push_notification_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Manages OneSignal push notification lifecycle:
/// - Requests permission on first login
/// - Stores player ID in user_profiles
/// - Handles login/logout identity
/// - Listens for notification opened events

@ProviderFor(PushNotificationManager)
final pushNotificationManagerProvider = PushNotificationManagerProvider._();

/// Manages OneSignal push notification lifecycle:
/// - Requests permission on first login
/// - Stores player ID in user_profiles
/// - Handles login/logout identity
/// - Listens for notification opened events
final class PushNotificationManagerProvider
    extends $AsyncNotifierProvider<PushNotificationManager, void> {
  /// Manages OneSignal push notification lifecycle:
  /// - Requests permission on first login
  /// - Stores player ID in user_profiles
  /// - Handles login/logout identity
  /// - Listens for notification opened events
  PushNotificationManagerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'pushNotificationManagerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$pushNotificationManagerHash();

  @$internal
  @override
  PushNotificationManager create() => PushNotificationManager();
}

String _$pushNotificationManagerHash() =>
    r'912648ce1a3eeb59ba252b3191b4543ef030e762';

/// Manages OneSignal push notification lifecycle:
/// - Requests permission on first login
/// - Stores player ID in user_profiles
/// - Handles login/logout identity
/// - Listens for notification opened events

abstract class _$PushNotificationManager extends $AsyncNotifier<void> {
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

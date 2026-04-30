// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'push_notification_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$pushNotificationManagerHash() =>
    r'e78ca82069cfab0ead4b53f06a550e04b0ba194d';

/// Manages OneSignal push notification lifecycle:
/// - Requests permission on first login
/// - Stores player ID in user_profiles
/// - Handles login/logout identity
/// - Listens for notification opened events
///
/// Copied from [PushNotificationManager].
@ProviderFor(PushNotificationManager)
final pushNotificationManagerProvider =
    AutoDisposeAsyncNotifierProvider<PushNotificationManager, void>.internal(
      PushNotificationManager.new,
      name: r'pushNotificationManagerProvider',
      debugGetCreateSourceHash:
          const bool.fromEnvironment('dart.vm.product')
              ? null
              : _$pushNotificationManagerHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$PushNotificationManager = AutoDisposeAsyncNotifier<void>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Fetches the user's notification list and subscribes to new ones
/// in real-time. Refreshes itself when new notifications arrive.

@ProviderFor(NotificationList)
final notificationListProvider = NotificationListProvider._();

/// Fetches the user's notification list and subscribes to new ones
/// in real-time. Refreshes itself when new notifications arrive.
final class NotificationListProvider
    extends $AsyncNotifierProvider<NotificationList, List<AppNotification>> {
  /// Fetches the user's notification list and subscribes to new ones
  /// in real-time. Refreshes itself when new notifications arrive.
  NotificationListProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'notificationListProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$notificationListHash();

  @$internal
  @override
  NotificationList create() => NotificationList();
}

String _$notificationListHash() => r'36278f487547e16d96c9b833fd07b8b7f819df5e';

/// Fetches the user's notification list and subscribes to new ones
/// in real-time. Refreshes itself when new notifications arrive.

abstract class _$NotificationList
    extends $AsyncNotifier<List<AppNotification>> {
  FutureOr<List<AppNotification>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref
            as $Ref<AsyncValue<List<AppNotification>>, List<AppNotification>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<List<AppNotification>>,
                List<AppNotification>
              >,
              AsyncValue<List<AppNotification>>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

/// Total unread notification count for the current user.
/// Used by the home screen notification icon badge.

@ProviderFor(totalUnreadNotifications)
final totalUnreadNotificationsProvider = TotalUnreadNotificationsProvider._();

/// Total unread notification count for the current user.
/// Used by the home screen notification icon badge.

final class TotalUnreadNotificationsProvider
    extends $FunctionalProvider<AsyncValue<int>, int, FutureOr<int>>
    with $FutureModifier<int>, $FutureProvider<int> {
  /// Total unread notification count for the current user.
  /// Used by the home screen notification icon badge.
  TotalUnreadNotificationsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'totalUnreadNotificationsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$totalUnreadNotificationsHash();

  @$internal
  @override
  $FutureProviderElement<int> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<int> create(Ref ref) {
    return totalUnreadNotifications(ref);
  }
}

String _$totalUnreadNotificationsHash() =>
    r'04748ed885ca43dd074e909200a4c5cfabae4869';

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$totalUnreadNotificationsHash() =>
    r'04748ed885ca43dd074e909200a4c5cfabae4869';

/// Total unread notification count for the current user.
/// Used by the home screen notification icon badge.
///
/// Copied from [totalUnreadNotifications].
@ProviderFor(totalUnreadNotifications)
final totalUnreadNotificationsProvider =
    AutoDisposeFutureProvider<int>.internal(
      totalUnreadNotifications,
      name: r'totalUnreadNotificationsProvider',
      debugGetCreateSourceHash:
          const bool.fromEnvironment('dart.vm.product')
              ? null
              : _$totalUnreadNotificationsHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef TotalUnreadNotificationsRef = AutoDisposeFutureProviderRef<int>;
String _$notificationListHash() => r'85b3518390c49c00a425c08aa07711af3169e1cd';

/// Fetches the user's notification list and subscribes to new ones
/// in real-time. Refreshes itself when new notifications arrive.
///
/// Copied from [NotificationList].
@ProviderFor(NotificationList)
final notificationListProvider = AutoDisposeAsyncNotifierProvider<
  NotificationList,
  List<AppNotification>
>.internal(
  NotificationList.new,
  name: r'notificationListProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$notificationListHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$NotificationList = AutoDisposeAsyncNotifier<List<AppNotification>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package

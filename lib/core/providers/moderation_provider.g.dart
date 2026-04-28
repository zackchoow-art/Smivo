// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'moderation_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$blockedUsersHash() => r'70d22129b840540f47ca772359c738e389e4741f';

/// See also [BlockedUsers].
@ProviderFor(BlockedUsers)
final blockedUsersProvider =
    AutoDisposeAsyncNotifierProvider<BlockedUsers, List<String>>.internal(
      BlockedUsers.new,
      name: r'blockedUsersProvider',
      debugGetCreateSourceHash:
          const bool.fromEnvironment('dart.vm.product')
              ? null
              : _$blockedUsersHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$BlockedUsers = AutoDisposeAsyncNotifier<List<String>>;
String _$blockedUsersListHash() => r'2bf41aab8d046ddffff79d53ac53e14d76ce64ef';

/// See also [BlockedUsersList].
@ProviderFor(BlockedUsersList)
final blockedUsersListProvider = AutoDisposeAsyncNotifierProvider<
  BlockedUsersList,
  List<UserProfile>
>.internal(
  BlockedUsersList.new,
  name: r'blockedUsersListProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$blockedUsersListHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$BlockedUsersList = AutoDisposeAsyncNotifier<List<UserProfile>>;
String _$moderationActionsHash() => r'e618d21353bd531e3eed288ed8148a13479d5f01';

/// See also [ModerationActions].
@ProviderFor(ModerationActions)
final moderationActionsProvider =
    AsyncNotifierProvider<ModerationActions, void>.internal(
      ModerationActions.new,
      name: r'moderationActionsProvider',
      debugGetCreateSourceHash:
          const bool.fromEnvironment('dart.vm.product')
              ? null
              : _$moderationActionsHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$ModerationActions = AsyncNotifier<void>;
String _$userReportsHash() => r'42ca467a3cd5b22b6a5f474097d8e662d6f09928';

/// See also [UserReports].
@ProviderFor(UserReports)
final userReportsProvider =
    AutoDisposeAsyncNotifierProvider<UserReports, List<ContentReport>>.internal(
      UserReports.new,
      name: r'userReportsProvider',
      debugGetCreateSourceHash:
          const bool.fromEnvironment('dart.vm.product')
              ? null
              : _$userReportsHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$UserReports = AutoDisposeAsyncNotifier<List<ContentReport>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package

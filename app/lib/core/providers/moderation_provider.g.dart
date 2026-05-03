// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'moderation_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(BlockedUsers)
final blockedUsersProvider = BlockedUsersProvider._();

final class BlockedUsersProvider
    extends $AsyncNotifierProvider<BlockedUsers, List<String>> {
  BlockedUsersProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'blockedUsersProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$blockedUsersHash();

  @$internal
  @override
  BlockedUsers create() => BlockedUsers();
}

String _$blockedUsersHash() => r'813fbbc345ca19a36eec5fc9b63b8351b3653431';

abstract class _$BlockedUsers extends $AsyncNotifier<List<String>> {
  FutureOr<List<String>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<List<String>>, List<String>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<String>>, List<String>>,
              AsyncValue<List<String>>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

@ProviderFor(BlockedUsersList)
final blockedUsersListProvider = BlockedUsersListProvider._();

final class BlockedUsersListProvider
    extends $AsyncNotifierProvider<BlockedUsersList, List<UserProfile>> {
  BlockedUsersListProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'blockedUsersListProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$blockedUsersListHash();

  @$internal
  @override
  BlockedUsersList create() => BlockedUsersList();
}

String _$blockedUsersListHash() => r'f37ae5be13fd9b6acb6aa2e1f277679b6f7dd4c2';

abstract class _$BlockedUsersList extends $AsyncNotifier<List<UserProfile>> {
  FutureOr<List<UserProfile>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref as $Ref<AsyncValue<List<UserProfile>>, List<UserProfile>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<UserProfile>>, List<UserProfile>>,
              AsyncValue<List<UserProfile>>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

@ProviderFor(ModerationActions)
final moderationActionsProvider = ModerationActionsProvider._();

final class ModerationActionsProvider
    extends $AsyncNotifierProvider<ModerationActions, void> {
  ModerationActionsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'moderationActionsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$moderationActionsHash();

  @$internal
  @override
  ModerationActions create() => ModerationActions();
}

String _$moderationActionsHash() => r'1f57ee6bbd9115cbb4861d3cf2ea6ce292cac64a';

abstract class _$ModerationActions extends $AsyncNotifier<void> {
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

@ProviderFor(UserReports)
final userReportsProvider = UserReportsProvider._();

final class UserReportsProvider
    extends $AsyncNotifierProvider<UserReports, List<ContentReport>> {
  UserReportsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'userReportsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$userReportsHash();

  @$internal
  @override
  UserReports create() => UserReports();
}

String _$userReportsHash() => r'b6081dd177650fc26f58a868a3ff33e1c111f31b';

abstract class _$UserReports extends $AsyncNotifier<List<ContentReport>> {
  FutureOr<List<ContentReport>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref as $Ref<AsyncValue<List<ContentReport>>, List<ContentReport>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<ContentReport>>, List<ContentReport>>,
              AsyncValue<List<ContentReport>>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

/// Provides a list of moderation actions (warn/restrict) that were applied
/// to the current user as the *reported* party.
///
/// NOTE: Dismissed reports are filtered out by the RLS policy, so this list
/// only contains records the user genuinely needs to be aware of.

@ProviderFor(UserPenalties)
final userPenaltiesProvider = UserPenaltiesProvider._();

/// Provides a list of moderation actions (warn/restrict) that were applied
/// to the current user as the *reported* party.
///
/// NOTE: Dismissed reports are filtered out by the RLS policy, so this list
/// only contains records the user genuinely needs to be aware of.
final class UserPenaltiesProvider
    extends $AsyncNotifierProvider<UserPenalties, List<ContentReport>> {
  /// Provides a list of moderation actions (warn/restrict) that were applied
  /// to the current user as the *reported* party.
  ///
  /// NOTE: Dismissed reports are filtered out by the RLS policy, so this list
  /// only contains records the user genuinely needs to be aware of.
  UserPenaltiesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'userPenaltiesProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$userPenaltiesHash();

  @$internal
  @override
  UserPenalties create() => UserPenalties();
}

String _$userPenaltiesHash() => r'5e05051401f8c85de743d8a6be1c57850fa395e1';

/// Provides a list of moderation actions (warn/restrict) that were applied
/// to the current user as the *reported* party.
///
/// NOTE: Dismissed reports are filtered out by the RLS policy, so this list
/// only contains records the user genuinely needs to be aware of.

abstract class _$UserPenalties extends $AsyncNotifier<List<ContentReport>> {
  FutureOr<List<ContentReport>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref as $Ref<AsyncValue<List<ContentReport>>, List<ContentReport>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<ContentReport>>, List<ContentReport>>,
              AsyncValue<List<ContentReport>>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

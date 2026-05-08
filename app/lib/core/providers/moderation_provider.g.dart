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

/// IDs of users who have blocked the current user.
///
/// Fetched via a SECURITY DEFINER RPC because RLS only exposes
/// blocks the user has *sent*, not blocks *received*.

@ProviderFor(BlockedByUsers)
final blockedByUsersProvider = BlockedByUsersProvider._();

/// IDs of users who have blocked the current user.
///
/// Fetched via a SECURITY DEFINER RPC because RLS only exposes
/// blocks the user has *sent*, not blocks *received*.
final class BlockedByUsersProvider
    extends $AsyncNotifierProvider<BlockedByUsers, List<String>> {
  /// IDs of users who have blocked the current user.
  ///
  /// Fetched via a SECURITY DEFINER RPC because RLS only exposes
  /// blocks the user has *sent*, not blocks *received*.
  BlockedByUsersProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'blockedByUsersProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$blockedByUsersHash();

  @$internal
  @override
  BlockedByUsers create() => BlockedByUsers();
}

String _$blockedByUsersHash() => r'ed1630062569ee84ae250fe480f8783c3c204462';

/// IDs of users who have blocked the current user.
///
/// Fetched via a SECURITY DEFINER RPC because RLS only exposes
/// blocks the user has *sent*, not blocks *received*.

abstract class _$BlockedByUsers extends $AsyncNotifier<List<String>> {
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

/// IDs to exclude from the home feed: only users the current user has blocked.
///
/// NOTE: We deliberately do NOT include "users who blocked me" here.
/// Bidirectional feed filtering required an extra SECURITY DEFINER RPC on
/// every home feed load, which was resource-intensive and unstable.
/// Instead, the block is enforced at order-placement time via the
/// [isBlockedBySellerProvider] which calls [check_order_eligibility].

@ProviderFor(allBlockedUserIds)
final allBlockedUserIdsProvider = AllBlockedUserIdsProvider._();

/// IDs to exclude from the home feed: only users the current user has blocked.
///
/// NOTE: We deliberately do NOT include "users who blocked me" here.
/// Bidirectional feed filtering required an extra SECURITY DEFINER RPC on
/// every home feed load, which was resource-intensive and unstable.
/// Instead, the block is enforced at order-placement time via the
/// [isBlockedBySellerProvider] which calls [check_order_eligibility].

final class AllBlockedUserIdsProvider
    extends $FunctionalProvider<List<String>, List<String>, List<String>>
    with $Provider<List<String>> {
  /// IDs to exclude from the home feed: only users the current user has blocked.
  ///
  /// NOTE: We deliberately do NOT include "users who blocked me" here.
  /// Bidirectional feed filtering required an extra SECURITY DEFINER RPC on
  /// every home feed load, which was resource-intensive and unstable.
  /// Instead, the block is enforced at order-placement time via the
  /// [isBlockedBySellerProvider] which calls [check_order_eligibility].
  AllBlockedUserIdsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'allBlockedUserIdsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$allBlockedUserIdsHash();

  @$internal
  @override
  $ProviderElement<List<String>> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  List<String> create(Ref ref) {
    return allBlockedUserIds(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<String> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<String>>(value),
    );
  }
}

String _$allBlockedUserIdsHash() => r'b7ee5d15c03ced64dbae960da8e8e598fa9fce5d';

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

String _$moderationActionsHash() => r'f4f4fd2b68db8b0e0192e99edecc6fbe0858a0f5';

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

/// Set of image URLs that have been flagged by the AI moderation system.
///
/// Loaded once at session start from backend_moderation_logs where result='fail'.
/// Used by [ModerationAwareImage] to decide whether to apply blur.
///
/// NOTE: keepAlive: true — this set must persist for the entire session so
/// the blur is consistent across page navigations. It is NOT per-user data;
/// it loads all flagged images visible to the current user via RLS.

@ProviderFor(FlaggedImageUrls)
final flaggedImageUrlsProvider = FlaggedImageUrlsProvider._();

/// Set of image URLs that have been flagged by the AI moderation system.
///
/// Loaded once at session start from backend_moderation_logs where result='fail'.
/// Used by [ModerationAwareImage] to decide whether to apply blur.
///
/// NOTE: keepAlive: true — this set must persist for the entire session so
/// the blur is consistent across page navigations. It is NOT per-user data;
/// it loads all flagged images visible to the current user via RLS.
final class FlaggedImageUrlsProvider
    extends $AsyncNotifierProvider<FlaggedImageUrls, Set<String>> {
  /// Set of image URLs that have been flagged by the AI moderation system.
  ///
  /// Loaded once at session start from backend_moderation_logs where result='fail'.
  /// Used by [ModerationAwareImage] to decide whether to apply blur.
  ///
  /// NOTE: keepAlive: true — this set must persist for the entire session so
  /// the blur is consistent across page navigations. It is NOT per-user data;
  /// it loads all flagged images visible to the current user via RLS.
  FlaggedImageUrlsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'flaggedImageUrlsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$flaggedImageUrlsHash();

  @$internal
  @override
  FlaggedImageUrls create() => FlaggedImageUrls();
}

String _$flaggedImageUrlsHash() => r'fb718238a460abd481dffbf224ead87d7d2dfe95';

/// Set of image URLs that have been flagged by the AI moderation system.
///
/// Loaded once at session start from backend_moderation_logs where result='fail'.
/// Used by [ModerationAwareImage] to decide whether to apply blur.
///
/// NOTE: keepAlive: true — this set must persist for the entire session so
/// the blur is consistent across page navigations. It is NOT per-user data;
/// it loads all flagged images visible to the current user via RLS.

abstract class _$FlaggedImageUrls extends $AsyncNotifier<Set<String>> {
  FutureOr<Set<String>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<Set<String>>, Set<String>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<Set<String>>, Set<String>>,
              AsyncValue<Set<String>>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

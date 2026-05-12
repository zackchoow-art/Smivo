// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'carpool_members_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Fetches the member list for a trip (with user profiles).

@ProviderFor(CarpoolTripMembers)
final carpoolTripMembersProvider = CarpoolTripMembersFamily._();

/// Fetches the member list for a trip (with user profiles).
final class CarpoolTripMembersProvider
    extends $AsyncNotifierProvider<CarpoolTripMembers, List<CarpoolMember>> {
  /// Fetches the member list for a trip (with user profiles).
  CarpoolTripMembersProvider._({
    required CarpoolTripMembersFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'carpoolTripMembersProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$carpoolTripMembersHash();

  @override
  String toString() {
    return r'carpoolTripMembersProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  CarpoolTripMembers create() => CarpoolTripMembers();

  @override
  bool operator ==(Object other) {
    return other is CarpoolTripMembersProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$carpoolTripMembersHash() =>
    r'1d7a05e864568336d8104d15d26c1169ec6b7534';

/// Fetches the member list for a trip (with user profiles).

final class CarpoolTripMembersFamily extends $Family
    with
        $ClassFamilyOverride<
          CarpoolTripMembers,
          AsyncValue<List<CarpoolMember>>,
          List<CarpoolMember>,
          FutureOr<List<CarpoolMember>>,
          String
        > {
  CarpoolTripMembersFamily._()
    : super(
        retry: null,
        name: r'carpoolTripMembersProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Fetches the member list for a trip (with user profiles).

  CarpoolTripMembersProvider call(String tripId) =>
      CarpoolTripMembersProvider._(argument: tripId, from: this);

  @override
  String toString() => r'carpoolTripMembersProvider';
}

/// Fetches the member list for a trip (with user profiles).

abstract class _$CarpoolTripMembers
    extends $AsyncNotifier<List<CarpoolMember>> {
  late final _$args = ref.$arg as String;
  String get tripId => _$args;

  FutureOr<List<CarpoolMember>> build(String tripId);
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref as $Ref<AsyncValue<List<CarpoolMember>>, List<CarpoolMember>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<CarpoolMember>>, List<CarpoolMember>>,
              AsyncValue<List<CarpoolMember>>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, () => build(_$args));
  }
}

/// Handles the join/leave/approve/reject flow for carpool memberships.
///
/// This provider is the single entry point for all member mutation actions.
/// It coordinates with the trip detail and member list providers to keep
/// the UI in sync after each operation.

@ProviderFor(CarpoolMemberActions)
final carpoolMemberActionsProvider = CarpoolMemberActionsProvider._();

/// Handles the join/leave/approve/reject flow for carpool memberships.
///
/// This provider is the single entry point for all member mutation actions.
/// It coordinates with the trip detail and member list providers to keep
/// the UI in sync after each operation.
final class CarpoolMemberActionsProvider
    extends $AsyncNotifierProvider<CarpoolMemberActions, void> {
  /// Handles the join/leave/approve/reject flow for carpool memberships.
  ///
  /// This provider is the single entry point for all member mutation actions.
  /// It coordinates with the trip detail and member list providers to keep
  /// the UI in sync after each operation.
  CarpoolMemberActionsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'carpoolMemberActionsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$carpoolMemberActionsHash();

  @$internal
  @override
  CarpoolMemberActions create() => CarpoolMemberActions();
}

String _$carpoolMemberActionsHash() =>
    r'c9de8e91824df41ed187cd604d0d03101eec45d5';

/// Handles the join/leave/approve/reject flow for carpool memberships.
///
/// This provider is the single entry point for all member mutation actions.
/// It coordinates with the trip detail and member list providers to keep
/// the UI in sync after each operation.

abstract class _$CarpoolMemberActions extends $AsyncNotifier<void> {
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

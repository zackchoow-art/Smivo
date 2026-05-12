// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'carpool_proposals_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Manages the list of proposals for a carpool trip.
///
/// Provides CRUD operations and vote casting. On mutation success,
/// the provider invalidates itself to refetch the latest state.

@ProviderFor(TripProposals)
final tripProposalsProvider = TripProposalsFamily._();

/// Manages the list of proposals for a carpool trip.
///
/// Provides CRUD operations and vote casting. On mutation success,
/// the provider invalidates itself to refetch the latest state.
final class TripProposalsProvider
    extends $AsyncNotifierProvider<TripProposals, List<CarpoolProposal>> {
  /// Manages the list of proposals for a carpool trip.
  ///
  /// Provides CRUD operations and vote casting. On mutation success,
  /// the provider invalidates itself to refetch the latest state.
  TripProposalsProvider._({
    required TripProposalsFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'tripProposalsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$tripProposalsHash();

  @override
  String toString() {
    return r'tripProposalsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  TripProposals create() => TripProposals();

  @override
  bool operator ==(Object other) {
    return other is TripProposalsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$tripProposalsHash() => r'ba92f4e1c99072e0b969beb5b1c2d94fe99a7860';

/// Manages the list of proposals for a carpool trip.
///
/// Provides CRUD operations and vote casting. On mutation success,
/// the provider invalidates itself to refetch the latest state.

final class TripProposalsFamily extends $Family
    with
        $ClassFamilyOverride<
          TripProposals,
          AsyncValue<List<CarpoolProposal>>,
          List<CarpoolProposal>,
          FutureOr<List<CarpoolProposal>>,
          String
        > {
  TripProposalsFamily._()
    : super(
        retry: null,
        name: r'tripProposalsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Manages the list of proposals for a carpool trip.
  ///
  /// Provides CRUD operations and vote casting. On mutation success,
  /// the provider invalidates itself to refetch the latest state.

  TripProposalsProvider call(String tripId) =>
      TripProposalsProvider._(argument: tripId, from: this);

  @override
  String toString() => r'tripProposalsProvider';
}

/// Manages the list of proposals for a carpool trip.
///
/// Provides CRUD operations and vote casting. On mutation success,
/// the provider invalidates itself to refetch the latest state.

abstract class _$TripProposals extends $AsyncNotifier<List<CarpoolProposal>> {
  late final _$args = ref.$arg as String;
  String get tripId => _$args;

  FutureOr<List<CarpoolProposal>> build(String tripId);
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref
            as $Ref<AsyncValue<List<CarpoolProposal>>, List<CarpoolProposal>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<List<CarpoolProposal>>,
                List<CarpoolProposal>
              >,
              AsyncValue<List<CarpoolProposal>>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, () => build(_$args));
  }
}

/// Handles casting a vote on a proposal via RPC.
///
/// The RPC atomically checks for duplicate votes, inserts the vote,
/// increments current_votes, and auto-resolves the proposal if
/// the required threshold is reached.

@ProviderFor(CastVote)
final castVoteProvider = CastVoteProvider._();

/// Handles casting a vote on a proposal via RPC.
///
/// The RPC atomically checks for duplicate votes, inserts the vote,
/// increments current_votes, and auto-resolves the proposal if
/// the required threshold is reached.
final class CastVoteProvider extends $AsyncNotifierProvider<CastVote, void> {
  /// Handles casting a vote on a proposal via RPC.
  ///
  /// The RPC atomically checks for duplicate votes, inserts the vote,
  /// increments current_votes, and auto-resolves the proposal if
  /// the required threshold is reached.
  CastVoteProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'castVoteProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$castVoteHash();

  @$internal
  @override
  CastVote create() => CastVote();
}

String _$castVoteHash() => r'1a1bd1f1d7e7a5630cd215559be38e07b24bf4f1';

/// Handles casting a vote on a proposal via RPC.
///
/// The RPC atomically checks for duplicate votes, inserts the vote,
/// increments current_votes, and auto-resolves the proposal if
/// the required threshold is reached.

abstract class _$CastVote extends $AsyncNotifier<void> {
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

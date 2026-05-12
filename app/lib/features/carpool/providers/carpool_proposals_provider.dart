import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:smivo/core/providers/supabase_provider.dart';
import 'package:smivo/data/models/carpool_proposal.dart';
import 'package:smivo/data/repositories/carpool_repository.dart';

part 'carpool_proposals_provider.g.dart';

/// Manages the list of proposals for a carpool trip.
///
/// Provides CRUD operations and vote casting. On mutation success,
/// the provider invalidates itself to refetch the latest state.
@riverpod
class TripProposals extends _$TripProposals {
  @override
  Future<List<CarpoolProposal>> build(String tripId) async {
    final repo = ref.watch(carpoolRepositoryProvider);
    return repo.fetchProposals(tripId);
  }

  /// Creates a new proposal and refreshes the list.
  Future<void> createProposal({
    required String proposalType,
    required int requiredVotes,
    String? oldValue,
    String? newValue,
    String? targetUserId,
    DateTime? expiresAt,
  }) async {
    final client = ref.read(supabaseClientProvider);
    final userId = client.auth.currentUser?.id;
    if (userId == null) return;

    final repo = ref.read(carpoolRepositoryProvider);
    try {
      await repo.createProposal(
        tripId: tripId,
        proposerId: userId,
        proposalType: proposalType,
        requiredVotes: requiredVotes,
        oldValue: oldValue,
        newValue: newValue,
        targetUserId: targetUserId,
        expiresAt: expiresAt,
      );
      ref.invalidateSelf();
    } catch (e) {
      debugPrint('Failed to create proposal: $e');
      rethrow;
    }
  }
}

/// Handles casting a vote on a proposal via RPC.
///
/// The RPC atomically checks for duplicate votes, inserts the vote,
/// increments current_votes, and auto-resolves the proposal if
/// the required threshold is reached.
@riverpod
class CastVote extends _$CastVote {
  @override
  FutureOr<void> build() {}

  /// Casts a vote ('approve' or 'reject') on the given proposal.
  Future<void> castVote({
    required String proposalId,
    required String vote,
    String? tripId,
  }) async {
    final client = ref.read(supabaseClientProvider);
    final userId = client.auth.currentUser?.id;
    if (userId == null) return;

    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await ref.read(carpoolRepositoryProvider).castVote(
            proposalId,
            userId,
            vote,
          );
      // Invalidate the proposals list so it refetches with updated vote counts
      if (tripId != null) {
        ref.invalidate(tripProposalsProvider(tripId));
      }
    });
  }
}

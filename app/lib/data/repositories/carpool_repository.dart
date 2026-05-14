import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:smivo/core/constants/app_constants.dart';
import 'package:smivo/core/exceptions/app_exception.dart';
import 'package:smivo/core/providers/supabase_provider.dart';
import 'package:smivo/data/models/carpool_member.dart';
import 'package:smivo/data/models/carpool_proposal.dart';
import 'package:smivo/data/models/carpool_review.dart';
import 'package:smivo/data/models/carpool_trip.dart';

part 'carpool_repository.g.dart';

/// Handles all Supabase operations for carpool trips, members, and proposals.
///
/// All methods catch [PostgrestException] and rethrow as [DatabaseException]
/// to prevent Supabase internals from leaking into the provider layer.
class CarpoolRepository {
  const CarpoolRepository(this._client);

  final SupabaseClient _client;

  // ── Trip queries ───────────────────────────────────────────────────────────

  /// Fetches all active trips for [schoolId] with creator profile joined.
  Future<List<CarpoolTrip>> fetchActiveTrips(String schoolId) async {
    try {
      final data = await _client
          .from(AppConstants.tableCarpoolTrips)
          .select('*, creator:user_profiles!creator_id(*)')
          .eq('school_id', schoolId)
          .eq('status', 'active')
          .order('departure_time', ascending: true);
      return data.map((json) => CarpoolTrip.fromJson(json)).toList();
    } on PostgrestException catch (e) {
      throw DatabaseException(e.message, e);
    }
  }

  /// Fetches a single trip by [tripId] with creator and members joined.
  ///
  /// Members include their user profiles for the detail page roster.
  Future<CarpoolTrip> fetchTripDetail(String tripId) async {
    try {
      final data = await _client
          .from(AppConstants.tableCarpoolTrips)
          .select('''
            *,
            creator:user_profiles!creator_id(*),
            members:carpool_members(*, user:user_profiles!user_id(*))
          ''')
          .eq('id', tripId)
          .single();
      return CarpoolTrip.fromJson(data);
    } on PostgrestException catch (e) {
      throw DatabaseException(e.message, e);
    }
  }

  /// Fetches all trips created by or joined by [userId].
  ///
  /// NOTE: Uses the carpool_members join to include trips where the user
  /// is a member but not the creator, so both roles are covered.
  Future<List<CarpoolTrip>> fetchMyTrips(String userId) async {
    try {
      final data = await _client
          .from(AppConstants.tableCarpoolTrips)
          .select('''
            *,
            creator:user_profiles!creator_id(*),
            members:carpool_members!inner(*, user:user_profiles!user_id(*))
          ''')
          .eq('members.user_id', userId)
          .order('departure_time', ascending: true);
      return data.map((json) {
        try {
          return CarpoolTrip.fromJson(json);
        } catch (e) {
          print('Error parsing trip json: $e');
          print('JSON: $json');
          rethrow;
        }
      }).toList();
    } on PostgrestException catch (e) {
      throw DatabaseException(e.message, e);
    }
  }

  /// Creates a new carpool trip and returns the persisted record.
  Future<CarpoolTrip> createTrip({
    required String creatorId,
    required String schoolId,
    required String role,
    required String departureAddress,
    required String destinationAddress,
    required DateTime departureTime,
    required int totalSeats,
    double? departureLat,
    double? departureLng,
    String? departurePlaceId,
    double? destinationLat,
    double? destinationLng,
    String? destinationPlaceId,
    DateTime? estimatedArrivalTime,
    String? luggageLimit,
    String approvalMode = 'manual',
    DateTime? closingTime,
    String? note,
    double? estimatedTotalPrice,
    String? departureDescription,
    String? destinationDescription,
  }) async {
    try {
      final data = await _client
          .from(AppConstants.tableCarpoolTrips)
          .insert({
            'creator_id': creatorId,
            'school_id': schoolId,
            'role': role,
            'departure_address': departureAddress,
            'departure_lat': departureLat,
            'departure_lng': departureLng,
            'departure_place_id': departurePlaceId,
            'destination_address': destinationAddress,
            'destination_lat': destinationLat,
            'destination_lng': destinationLng,
            'destination_place_id': destinationPlaceId,
            'departure_time': departureTime.toUtc().toIso8601String(),
            'estimated_arrival_time':
                estimatedArrivalTime?.toUtc().toIso8601String(),
            'total_seats': totalSeats,
            'available_seats': totalSeats,
            'luggage_limit': luggageLimit,
            'approval_mode': approvalMode,
            'closing_time': closingTime?.toUtc().toIso8601String(),
            'note': note,
            if (estimatedTotalPrice != null) 'estimated_total_price': estimatedTotalPrice,
            if (departureDescription != null) 'departure_description': departureDescription,
            if (destinationDescription != null) 'destination_description': destinationDescription,
          })
          .select()
          .single();
      return CarpoolTrip.fromJson(data);
    } on PostgrestException catch (e) {
      throw DatabaseException(e.message, e);
    }
  }

  /// Updates specific fields of a trip identified by [tripId].
  Future<void> updateTrip(
    String tripId,
    Map<String, dynamic> updates,
  ) async {
    try {
      await _client
          .from(AppConstants.tableCarpoolTrips)
          .update(updates)
          .eq('id', tripId);
    } on PostgrestException catch (e) {
      throw DatabaseException(e.message, e);
    }
  }

  /// Sets the trip status to 'cancelled'.
  Future<void> cancelTrip(String tripId) async {
    try {
      await _client
          .from(AppConstants.tableCarpoolTrips)
          .update({'status': 'cancelled'})
          .eq('id', tripId);
    } on PostgrestException catch (e) {
      throw DatabaseException(e.message, e);
    }
  }

  /// Acknowledges and accepts trip changes, clearing the snapshot.
  Future<void> acceptTripChanges(String tripId) async {
    try {
      await _client.rpc(
        'accept_carpool_trip_changes',
        params: {'p_trip_id': tripId},
      );
    } on PostgrestException catch (e) {
      throw DatabaseException(e.message, e);
    }
  }

  // ── Member queries ─────────────────────────────────────────────────────────

  /// Fetches all members of [tripId] with user profiles joined.
  Future<List<CarpoolMember>> fetchTripMembers(String tripId) async {
    try {
      final data = await _client
          .from(AppConstants.tableCarpoolMembers)
          .select('*, user:user_profiles!user_id(*)')
          .eq('trip_id', tripId)
          .order('created_at', ascending: true);
      return data.map((json) => CarpoolMember.fromJson(json)).toList();
    } on PostgrestException catch (e) {
      throw DatabaseException(e.message, e);
    }
  }

  /// Submits a join request for [userId] to [tripId] via RPC.
  ///
  /// NOTE: The `join_carpool_trip` RPC returns a jsonb result with
  /// {success, status, member_id, error} — not a full CarpoolMember row.
  /// The provider layer should re-fetch trip detail after a successful join.
  Future<Map<String, dynamic>> requestJoinTrip(
    String tripId,
    String userId,
  ) async {
    try {
      final data = await _client.rpc(
        'join_carpool_trip',
        params: {'p_trip_id': tripId, 'p_user_id': userId},
      );
      final result = data as Map<String, dynamic>;
      if (result['success'] != true) {
        throw DatabaseException(
          result['error'] as String? ?? 'Failed to join trip',
          null,
        );
      }
      return result;
    } on PostgrestException catch (e) {
      throw DatabaseException(e.message, e);
    }
  }

  /// Approves a join request via RPC (handles seat decrement + group chat add).
  ///
  /// NOTE: We use the `accept_carpool_member` RPC instead of a direct UPDATE
  /// because the RPC atomically: approves member, decrements available_seats,
  /// adds the user to group_chat_members, and sends a system welcome message.
  Future<void> approveMember(String memberId) async {
    try {
      final data = await _client.rpc(
        'accept_carpool_member',
        params: {'p_member_id': memberId},
      );
      final result = data as Map<String, dynamic>;
      if (result['success'] != true) {
        throw DatabaseException(
          result['error'] as String? ?? 'Failed to approve member',
          null,
        );
      }
    } on PostgrestException catch (e) {
      throw DatabaseException(e.message, e);
    }
  }

  /// Confirms a trip via RPC.
  Future<void> confirmTrip(String tripId) async {
    try {
      await _client.rpc('confirm_carpool_trip', params: {'p_trip_id': tripId});
    } on PostgrestException catch (e) {
      throw DatabaseException(e.message, e);
    }
  }

  /// Rejects a join request by directly updating member status.
  ///
  /// NOTE: Rejection is a simple status update — no seat or group chat
  /// changes needed, so we skip the RPC overhead.
  Future<void> rejectMember(String memberId) async {
    try {
      await _client
          .from(AppConstants.tableCarpoolMembers)
          .update({'status': 'rejected'})
          .eq('id', memberId);
    } on PostgrestException catch (e) {
      throw DatabaseException(e.message, e);
    }
  }

  /// Removes [userId] from [tripId] via RPC.
  ///
  /// NOTE: The RPC handles seat increment and group chat membership
  /// removal atomically, keeping trip state consistent.
  Future<void> leaveTrip(String tripId, String userId) async {
    try {
      await _client.rpc(
        'leave_carpool_trip',
        params: {'p_trip_id': tripId, 'p_user_id': userId},
      );
    } on PostgrestException catch (e) {
      throw DatabaseException(e.message, e);
    }
  }

  // ── Proposal queries ───────────────────────────────────────────────────────

  /// Creates a group change proposal and returns the persisted record.
  Future<CarpoolProposal> createProposal({
    required String tripId,
    required String proposerId,
    required String proposalType,
    required int requiredVotes,
    String? oldValue,
    String? newValue,
    String? targetUserId,
    DateTime? expiresAt,
  }) async {
    try {
      final data = await _client
          .from(AppConstants.tableCarpoolProposals)
          .insert({
            'trip_id': tripId,
            'proposer_id': proposerId,
            'proposal_type': proposalType,
            'old_value': oldValue,
            'new_value': newValue,
            'target_user_id': targetUserId,
            'required_votes': requiredVotes,
            'expires_at': expiresAt?.toUtc().toIso8601String(),
          })
          .select()
          .single();
      return CarpoolProposal.fromJson(data);
    } on PostgrestException catch (e) {
      throw DatabaseException(e.message, e);
    }
  }

  /// Fetches all proposals for [tripId], ordered by creation time.
  Future<List<CarpoolProposal>> fetchProposals(String tripId) async {
    try {
      final data = await _client
          .from(AppConstants.tableCarpoolProposals)
          .select()
          .eq('trip_id', tripId)
          .order('created_at', ascending: false);
      return data.map((json) => CarpoolProposal.fromJson(json)).toList();
    } on PostgrestException catch (e) {
      throw DatabaseException(e.message, e);
    }
  }

  /// Casts [voterId]'s vote on [proposalId] via RPC.
  ///
  /// NOTE: The `cast_carpool_vote` RPC checks for duplicate votes and
  /// resolves the proposal if [requiredVotes] is reached, all atomically.
  Future<void> castVote(
    String proposalId,
    String voterId,
    String vote,
  ) async {
    try {
      await _client.rpc(
        'cast_carpool_vote',
        params: {
          'p_proposal_id': proposalId,
          'p_voter_id': voterId,
          'p_vote': vote,
        },
      );
    } on PostgrestException catch (e) {
      throw DatabaseException(e.message, e);
    }
  }

  // ── Review queries ─────────────────────────────────────────────────────────

  /// Submits a batch of reviews for all fellow members after trip completion.
  ///
  /// NOTE: Uses a batch insert for efficiency. The DB unique constraint on
  /// (trip_id, reviewer_id, reviewee_id) prevents duplicate submissions.
  Future<void> submitReviews(List<Map<String, dynamic>> reviews) async {
    try {
      await _client
          .from(AppConstants.tableCarpoolReviews)
          .insert(reviews);
    } on PostgrestException catch (e) {
      throw DatabaseException(e.message, e);
    }
  }

  /// Fetches all reviews for [tripId] with reviewer and reviewee profiles.
  Future<List<CarpoolReview>> fetchTripReviews(String tripId) async {
    try {
      final data = await _client
          .from(AppConstants.tableCarpoolReviews)
          .select(
            '*, reviewer:user_profiles!reviewer_id(*), '
            'reviewee:user_profiles!reviewee_id(*)',
          )
          .eq('trip_id', tripId)
          .order('created_at', ascending: true);
      return data.map((json) => CarpoolReview.fromJson(json)).toList();
    } on PostgrestException catch (e) {
      throw DatabaseException(e.message, e);
    }
  }

  /// Fetches the average carpool rating received by [userId].
  ///
  /// NOTE: Computed client-side to avoid requiring a DB view or RPC.
  /// Returns 0.0 if the user has no reviews yet.
  Future<double> fetchUserAverageRating(String userId) async {
    try {
      final data = await _client
          .from(AppConstants.tableCarpoolReviews)
          .select('rating')
          .eq('reviewee_id', userId);
      if (data.isEmpty) return 0.0;
      final total =
          data.fold<int>(0, (sum, row) => sum + (row['rating'] as int));
      return total / data.length;
    } on PostgrestException catch (e) {
      throw DatabaseException(e.message, e);
    }
  }

  // ── Lifecycle status updates ───────────────────────────────────────────────

  /// Marks a trip as departed (creator confirms everyone is aboard).
  Future<void> markDeparted(String tripId) async {
    await updateTrip(tripId, {'status': 'departed'});
  }

  /// Marks a trip as arrived (creator confirms destination reached).
  Future<void> markArrived(String tripId) async {
    await updateTrip(tripId, {'status': 'arrived'});
  }

  /// Marks a trip as completed after review window closes.
  Future<void> markCompleted(String tripId) async {
    await updateTrip(tripId, {'status': 'completed'});
  }

  // ── Cost settlement ───────────────────────────────────────────────────────

  /// Records the actual total cost entered by the creator after arrival.
  ///
  /// NOTE: Only the trip creator should call this — RLS on carpool_trips
  /// restricts UPDATE to the creator_id. settled_at is set server-side
  /// to avoid client clock drift.
  Future<void> settleTripCost(String tripId, double actualTotalCost) async {
    try {
      await _client
          .from(AppConstants.tableCarpoolTrips)
          .update({
            'actual_total_cost': actualTotalCost,
            'settled_at': DateTime.now().toUtc().toIso8601String(),
          })
          .eq('id', tripId);
    } on PostgrestException catch (e) {
      throw DatabaseException(e.message, e);
    }
  }
}

@riverpod
CarpoolRepository carpoolRepository(Ref ref) =>
    CarpoolRepository(ref.watch(supabaseClientProvider));

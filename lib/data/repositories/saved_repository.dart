import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:smivo/core/constants/app_constants.dart';
import 'package:smivo/core/exceptions/app_exception.dart';
import 'package:smivo/core/providers/supabase_provider.dart';
import 'package:smivo/data/models/saved_listing.dart';

part 'saved_repository.g.dart';

/// Handles save/unsave operations for user-bookmarked listings.
class SavedRepository {
  const SavedRepository(this._client);

  final SupabaseClient _client;

  /// Fetches all saved listings for a user.
  Future<List<SavedListing>> fetchSavedListings(
    String userId,
  ) async {
    try {
      final data = await _client
          .from(AppConstants.tableSavedListings)
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);
      return data
          .map((json) => SavedListing.fromJson(json))
          .toList();
    } on PostgrestException catch (e) {
      throw DatabaseException(e.message, e);
    }
  }

  /// Saves a listing for the user.
  Future<SavedListing> saveListing({
    required String userId,
    required String listingId,
  }) async {
    try {
      final data = await _client
          .from(AppConstants.tableSavedListings)
          .insert({
            'user_id': userId,
            'listing_id': listingId,
          })
          .select()
          .single();
      return SavedListing.fromJson(data);
    } on PostgrestException catch (e) {
      throw DatabaseException(e.message, e);
    }
  }

  /// Removes a saved listing.
  Future<void> unsaveListing({
    required String userId,
    required String listingId,
  }) async {
    try {
      await _client
          .from(AppConstants.tableSavedListings)
          .delete()
          .eq('user_id', userId)
          .eq('listing_id', listingId);
    } on PostgrestException catch (e) {
      throw DatabaseException(e.message, e);
    }
  }

  /// Checks if a listing is saved by the user.
  Future<bool> isListingSaved({
    required String userId,
    required String listingId,
  }) async {
    try {
      final data = await _client
          .from(AppConstants.tableSavedListings)
          .select('id')
          .eq('user_id', userId)
          .eq('listing_id', listingId)
          .maybeSingle();
      return data != null;
    } on PostgrestException catch (e) {
      throw DatabaseException(e.message, e);
    }
  }

  /// Fetches all users who saved a specific listing (for seller stats).
  /// Returns a list of SavedListing records.
  Future<List<SavedListing>> fetchSavedByListing(String listingId) async {
    try {
      final data = await _client
          .from(AppConstants.tableSavedListings)
          .select('*, user:user_profiles!user_id(*)')
          .eq('listing_id', listingId)
          .order('created_at', ascending: false);
      return data.map((json) => SavedListing.fromJson(json)).toList();
    } on PostgrestException catch (e) {
      throw DatabaseException(e.message, e);
    }
  }
}

@riverpod
SavedRepository savedRepository(Ref ref) =>
    SavedRepository(ref.watch(supabaseClientProvider));

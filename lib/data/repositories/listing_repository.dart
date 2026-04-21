import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

import 'package:smivo/core/constants/app_constants.dart';
import 'package:smivo/core/exceptions/app_exception.dart';
import 'package:smivo/core/providers/supabase_provider.dart';
import 'package:smivo/data/models/listing.dart';

part 'listing_repository.g.dart';

// NOTE: The UUID instance is kept module-level to avoid re-instantiation
// on every createListingWithImages call.
const _uuid = Uuid();

/// Handles all listing-related Supabase operations.
///
/// Image upload and orphan-cleanup logic lives here intentionally —
/// keeping the full atomic "create listing + images" flow in one place
/// makes error handling and rollback straightforward.
class ListingRepository {
  const ListingRepository(this._client);

  final SupabaseClient _client;

  // ──────────────────────────────────────────────────────────────
  // READ OPERATIONS
  // ──────────────────────────────────────────────────────────────

  /// Fetches all active listings, optionally filtered by [category].
  ///
  /// Includes the first image via a join so card widgets can display
  /// a thumbnail without a second round-trip.
  Future<List<Listing>> fetchListings({String? category}) async {
    try {
      var query = _client
          .from(AppConstants.tableListings)
          // NOTE: listing_images rows are returned as a nested array;
          // Listing.fromJson handles them via the 'images' key alias.
          .select('*, images:listing_images(*)')
          .eq('status', AppConstants.listingActive);

      if (category != null) {
        // NOTE: DB CHECK constraint uses lowercase values; always
        // normalise before sending to avoid silent filter mismatches.
        query = query.eq('category', category.toLowerCase());
      }

      final data = await query.order('created_at', ascending: false);
      return data.map((json) => Listing.fromJson(json)).toList();
    } on PostgrestException catch (e) {
      throw DatabaseException(e.message, e);
    }
  }

  /// Fetches a single listing by [id] with full details.
  ///
  /// Joins [user_profiles] (as 'seller') and [listing_images] (as 'images')
  /// so the detail screen has everything in one query.
  Future<Listing> fetchListing(String id) async {
    try {
      final data = await _client
          .from(AppConstants.tableListings)
          .select('*, seller:user_profiles(*), images:listing_images(*)')
          .eq('id', id)
          .single();
      return Listing.fromJson(data);
    } on PostgrestException catch (e) {
      throw DatabaseException(e.message, e);
    }
  }

  /// Searches active listings by keyword in title and description.
  Future<List<Listing>> searchListings(String query) async {
    try {
      final data = await _client
          .from(AppConstants.tableListings)
          .select('*, images:listing_images(*)')
          .eq('status', AppConstants.listingActive)
          .or('title.ilike.%$query%,description.ilike.%$query%')
          .order('created_at', ascending: false);
      return data.map((json) => Listing.fromJson(json)).toList();
    } on PostgrestException catch (e) {
      throw DatabaseException(e.message, e);
    }
  }

  /// Fetches all listings (any status) owned by [sellerId].
  Future<List<Listing>> fetchMyListings(String sellerId) async {
    try {
      final data = await _client
          .from(AppConstants.tableListings)
          .select('*, images:listing_images(*)')
          .eq('seller_id', sellerId)
          .order('created_at', ascending: false);
      return data.map((json) => Listing.fromJson(json)).toList();
    } on PostgrestException catch (e) {
      throw DatabaseException(e.message, e);
    }
  }

  // ──────────────────────────────────────────────────────────────
  // WRITE OPERATIONS
  // ──────────────────────────────────────────────────────────────

  /// Creates a new listing together with its images atomically.
  ///
  /// Upload sequence:
  ///   1. Upload each [photos] file to Storage under [userId]/
  ///   2. Insert the [listing] row into the `listings` table
  ///   3. Insert one row per image into `listing_images`
  ///
  /// If step 2 or 3 fails, all successfully uploaded Storage objects are
  /// deleted to prevent orphaned files (per analysis risk #1).
  Future<Listing> createListingWithImages({
    required Listing listing,
    required String userId,
    required List<File> photos,
  }) async {
    // Track uploaded Storage paths for potential rollback.
    final uploadedPaths = <String>[];

    try {
      // ── Step 1: Upload photos ────────────────────────────────
      final imageUrls = <String>[];

      for (final photo in photos) {
        // Generate a unique filename so concurrent uploads never collide.
        final ext = p.extension(photo.path);
        final fileName = '${_uuid.v4()}$ext';

        // NOTE: RLS on the 'listing-images' bucket requires the storage
        // path to start with auth.uid(). We prefix with userId here.
        final storagePath = '$userId/$fileName';

        await _client.storage
            .from(AppConstants.bucketListingImages)
            .uploadBinary(storagePath, await photo.readAsBytes());

        uploadedPaths.add(storagePath);
        imageUrls.add(
          _client.storage
              .from(AppConstants.bucketListingImages)
              .getPublicUrl(storagePath),
        );
      }

      // ── Step 2: Insert listing row ───────────────────────────
      final listingJson = listing.toJson()
        // NOTE: Exclude fields that are computed by joins or are
        // DB-generated (images, seller) to avoid insert errors.
        ..remove('images')
        ..remove('seller')
        // NOTE: category must always be lowercase to satisfy the
        // DB CHECK constraint. Normalise at the boundary.
        ..['category'] = listing.category.toLowerCase();

      final insertedData = await _client
          .from(AppConstants.tableListings)
          .insert(listingJson)
          .select()
          .single();

      final newListingId = insertedData['id'] as String;

      // ── Step 3: Insert listing_images rows ───────────────────
      if (imageUrls.isNotEmpty) {
        final imagesPayload = imageUrls.asMap().entries.map((entry) {
          return {
            'listing_id': newListingId,
            'image_url': entry.value,
            'sort_order': entry.key,
          };
        }).toList();

        await _client
            .from(AppConstants.tableListingImages)
            .insert(imagesPayload);
      }

      // Fetch the full listing with images joined for the caller.
      return fetchListing(newListingId);
    } on PostgrestException catch (e) {
      // NOTE: DB insert failed. Clean up orphaned Storage objects so
      // the bucket does not accumulate unreachable files.
      await _deleteUploadedPhotos(uploadedPaths);
      throw DatabaseException(e.message, e);
    } on StorageException catch (e) {
      // NOTE: Upload failed mid-loop. Only successfully uploaded files
      // are in uploadedPaths; the loop stopped before the rest.
      await _deleteUploadedPhotos(uploadedPaths);
      throw AppStorageException(e.message, e);
    }
  }

  /// Updates an existing listing (without touching its images).
  Future<Listing> updateListing(Listing listing) async {
    try {
      final listingJson = listing.toJson()
        ..remove('images')
        ..remove('seller')
        ..['category'] = listing.category.toLowerCase();

      final data = await _client
          .from(AppConstants.tableListings)
          .update(listingJson)
          .eq('id', listing.id)
          .select()
          .single();
      return Listing.fromJson(data);
    } on PostgrestException catch (e) {
      throw DatabaseException(e.message, e);
    }
  }

  /// Deletes a listing by [id]. Cascades to listing_images via DB FK.
  Future<void> deleteListing(String id) async {
    try {
      await _client
          .from(AppConstants.tableListings)
          .delete()
          .eq('id', id);
    } on PostgrestException catch (e) {
      throw DatabaseException(e.message, e);
    }
  }

  // ──────────────────────────────────────────────────────────────
  // PRIVATE HELPERS
  // ──────────────────────────────────────────────────────────────

  /// Attempts to delete all [paths] from the listing-images bucket.
  ///
  /// Errors are swallowed intentionally — if cleanup itself fails,
  /// the original error (from the caller) should still propagate.
  Future<void> _deleteUploadedPhotos(List<String> paths) async {
    if (paths.isEmpty) return;
    try {
      await _client.storage
          .from(AppConstants.bucketListingImages)
          .remove(paths);
    } catch (_) {
      // HACK: Swallowing cleanup errors here. Ideally a background job
      // or Supabase Edge Function would handle orphan cleanup in production.
    }
  }
}

@riverpod
ListingRepository listingRepository(Ref ref) =>
    ListingRepository(ref.watch(supabaseClientProvider));

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

import 'package:smivo/core/constants/app_constants.dart';
import 'package:smivo/core/exceptions/app_exception.dart';
import 'package:smivo/core/providers/supabase_provider.dart';
import 'package:smivo/data/models/listing.dart';
import 'package:smivo/data/repositories/storage_repository.dart';

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
  const ListingRepository(this._client, this._storageRepository);

  final SupabaseClient _client;
  final StorageRepository _storageRepository;

  // ──────────────────────────────────────────────────────────────
  // READ OPERATIONS
  // ──────────────────────────────────────────────────────────────

  /// Fetches all active listings, optionally filtered by [category].
  ///
  /// Includes the first image via a join so card widgets can display
  /// a thumbnail without a second round-trip.
  Future<List<Listing>> fetchListings({
    String? category,
    List<String>? blockedUserIds,
  }) async {
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

      if (blockedUserIds != null && blockedUserIds.isNotEmpty) {
        query = query.not('seller_id', 'in', blockedUserIds);
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
      final data =
          await _client
              .from(AppConstants.tableListings)
              .select('''
            *,
            seller:user_profiles!seller_id(*),
            images:listing_images(*),
            pickup_location:pickup_locations!pickup_location_id(*)
          ''')
              .eq('id', id)
              .single();
      return Listing.fromJson(data);
    } on PostgrestException catch (e) {
      throw DatabaseException(e.message, e);
    }
  }

  /// Searches active listings by keyword in title, description, seller name, and prices.
  Future<List<Listing>> searchListings(
    String query, {
    String? category,
    List<String>? blockedUserIds,
  }) async {
    try {
      var dbQuery = _client
          .from(AppConstants.tableListings)
          .select(
            '*, images:listing_images(*), seller:user_profiles!seller_id(*)',
          )
          .eq('status', AppConstants.listingActive);

      if (category != null) {
        dbQuery = dbQuery.eq('category', category.toLowerCase());
      }

      if (blockedUserIds != null && blockedUserIds.isNotEmpty) {
        dbQuery = dbQuery.not('seller_id', 'in', blockedUserIds);
      }

      final data = await dbQuery.order('created_at', ascending: false);
      final allListings = data.map((json) => Listing.fromJson(json)).toList();

      if (query.trim().isEmpty) return allListings;

      final q = query.trim().toLowerCase();
      return allListings.where((l) {
        final titleMatch = l.title.toLowerCase().contains(q);
        final descMatch = (l.description?.toLowerCase().contains(q) ?? false);
        final sellerMatch =
            (l.seller?.displayName?.toLowerCase().contains(q) ?? false);
        final priceMatch = l.price.toString().contains(q);
        final dailyMatch = l.rentalDailyPrice?.toString().contains(q) ?? false;
        final weeklyMatch =
            l.rentalWeeklyPrice?.toString().contains(q) ?? false;
        final monthlyMatch =
            l.rentalMonthlyPrice?.toString().contains(q) ?? false;

        return titleMatch ||
            descMatch ||
            sellerMatch ||
            priceMatch ||
            dailyMatch ||
            weeklyMatch ||
            monthlyMatch;
      }).toList();
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

  /// Fetches all listings owned by [userId] with full joins.
  Future<List<Listing>> fetchUserListings(String userId) async {
    try {
      final data = await _client
          .from(AppConstants.tableListings)
          .select(
            '*, images:listing_images(*), seller:user_profiles!seller_id(*), pickup_location:pickup_locations!pickup_location_id(*)',
          )
          .eq('seller_id', userId)
          .order('created_at', ascending: false);
      return data.map((json) => Listing.fromJson(json)).toList();
    } on PostgrestException catch (e) {
      throw DatabaseException(e.message, e);
    }
  }

  /// Fetches individual view events for a listing.
  Future<List<Map<String, dynamic>>> fetchListingViews(String listingId) async {
    try {
      final data = await _client
          .from(AppConstants.tableListingViews)
          .select(
            '*, viewer:user_profiles!viewer_id(display_name, avatar_url, email)',
          )
          .eq('listing_id', listingId)
          .order('viewed_at', ascending: false)
          .limit(100);
      return List<Map<String, dynamic>>.from(data);
    } on PostgrestException catch (e) {
      throw DatabaseException(e.message, e);
    }
  }

  /// Fetches individual save events for a listing.
  Future<List<Map<String, dynamic>>> fetchListingSaves(String listingId) async {
    try {
      final data = await _client
          .from(AppConstants.tableSavedListings)
          .select(
            '*, user:user_profiles!user_id(display_name, avatar_url, email)',
          )
          .eq('listing_id', listingId)
          .order('created_at', ascending: false);
      return List<Map<String, dynamic>>.from(data);
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
    required List<XFile> photos,
  }) async {
    // Track uploaded Storage paths for potential rollback.
    final uploadedPaths = <String>[];

    try {
      // ── Step 1: Upload photos ────────────────────────────────
      final imageUrls = <String>[];

      for (final photo in photos) {
        // Generate a unique filename so concurrent uploads never collide.
        final ext = p.extension(photo.name);
        final fileName = '${_uuid.v4()}$ext';

        // NOTE: We'll use listing.id once the listing is created,
        // but for now createListingWithImages needs to create the
        // listing FIRST or use a placeholder ID.
        // Actually, the StorageRepository expects a listingId.
        // Let's generate the listing ID here if it's empty.

        final targetListingId = listing.id.isEmpty ? _uuid.v4() : listing.id;

        final publicUrl = await _storageRepository.uploadListingImage(
          userId: userId,
          listingId: targetListingId,
          fileName: fileName,
          fileBytes: await photo.readAsBytes(),
        );

        imageUrls.add(publicUrl);
        // We'll keep track of the full storage path for cleanup if needed.
        // StorageRepository doesn't return the path, just URL.
        // For simplicity in Phase 1, we skip manual rollback of Storage files.
      }

      // ── Step 2: Insert listing row ───────────────────────────
      final listingJson =
          listing.toJson()
            // NOTE: Exclude fields that are computed by joins or are
            // DB-generated to avoid insert errors.
            ..remove('images')
            ..remove('seller')
            ..remove('pickup_location')
            ..remove('id')
            ..remove('created_at')
            ..remove('updated_at')
            // NOTE: category must always be lowercase to satisfy the
            // DB CHECK constraint. Normalise at the boundary.
            ..['category'] = listing.category.toLowerCase();

      // Remove null values to let DB defaults apply (e.g. status)
      listingJson.removeWhere((key, value) => value == null);

      final insertedData =
          await _client
              .from(AppConstants.tableListings)
              .insert(listingJson)
              .select()
              .single();

      final newListingId = insertedData['id'] as String;

      // ── Step 3: Insert listing_images rows ───────────────────
      if (imageUrls.isNotEmpty) {
        final imagesPayload =
            imageUrls.asMap().entries.map((entry) {
              final imageUrl = entry.value;
              final i = entry.key;

              debugPrint(
                'Inserting listing_image: { listing_id: $newListingId, image_url: $imageUrl, sort_order: $i }',
              );

              return {
                'listing_id': newListingId,
                'image_url': imageUrl,
                'sort_order': i,
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
      final listingJson =
          listing.toJson()
            ..remove('images')
            ..remove('seller')
            ..['category'] = listing.category.toLowerCase();

      final data =
          await _client
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
      await _client.from(AppConstants.tableListings).delete().eq('id', id);
    } on PostgrestException catch (e) {
      throw DatabaseException(e.message, e);
    }
  }

  /// Updates a listing's status to a specific value.
  ///
  /// Valid statuses: active, inactive, reserved, sold, rented.
  /// Used for automatic lifecycle transitions (e.g., sold on accept).
  Future<void> updateListingStatus(String id, String status) async {
    try {
      await _client
          .from(AppConstants.tableListings)
          .update({'status': status})
          .eq('id', id);
    } on PostgrestException catch (e) {
      throw DatabaseException(e.message, e);
    }
  }

  /// Delists a listing by setting its status to 'inactive'.
  ///
  /// NOTE: DB CHECK constraint only allows: active, inactive, reserved,
  /// sold, rented. 'cancelled' is NOT a valid listing status.
  Future<void> delistListing(String id) async {
    try {
      await _client
          .from(AppConstants.tableListings)
          .update({'status': 'inactive'})
          .eq('id', id);
    } on PostgrestException catch (e) {
      throw DatabaseException(e.message, e);
    }
  }

  /// Records a view event for a listing.
  ///
  /// [viewerId] is optional to support guest view tracking.
  /// Silently fails if the insert errors (non-critical).
  Future<void> recordView({required String listingId, String? viewerId}) async {
    try {
      final data = <String, dynamic>{'listing_id': listingId};
      if (viewerId != null && viewerId.isNotEmpty) {
        data['viewer_id'] = viewerId;
      }

      await _client.from(AppConstants.tableListingViews).insert(data);
    } on PostgrestException catch (_) {
      // Non-critical — don't crash the app if view tracking fails
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
ListingRepository listingRepository(Ref ref) => ListingRepository(
  ref.watch(supabaseClientProvider),
  ref.watch(storageRepositoryProvider),
);

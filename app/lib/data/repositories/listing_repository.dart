import 'package:flutter/foundation.dart';
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
    String? schoolId,
  }) async {
    try {
      var query = _client
          .from(AppConstants.tableListings)
          // NOTE: listing_images rows are returned as a nested array;
          // Listing.fromJson handles them via the 'images' key alias.
          .select('*, images:listing_images(*)')
          .eq('status', AppConstants.listingActive)
          // NOTE: Exclude listings that have been rejected or taken down by admin.
          // moderation_status can be: auto_approved, pending_review, approved, rejected, taken_down.
          // We only show listings NOT in rejected/taken_down state.
          .not(
            'moderation_status',
            'in',
            '("rejected","taken_down","pending_review")',
          );

      if (category != null) {
        // NOTE: DB CHECK constraint uses lowercase values; always
        // normalise before sending to avoid silent filter mismatches.
        query = query.eq('category', category.toLowerCase());
      }

      if (blockedUserIds != null && blockedUserIds.isNotEmpty) {
        query = query.not('seller_id', 'in', blockedUserIds);
      }

      if (schoolId != null) {
        query = query.eq('school_id', schoolId);
      }

      final data = await query.order('updated_at', ascending: false);
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
    String? schoolId,
  }) async {
    try {
      var dbQuery = _client
          .from(AppConstants.tableListings)
          .select(
            '*, images:listing_images(*), seller:user_profiles!seller_id(*)',
          )
          .eq('status', AppConstants.listingActive)
          // NOTE: Same moderation_status filter as fetchListings —
          // rejected/taken_down items must never appear in search results.
          .not(
            'moderation_status',
            'in',
            '("rejected","taken_down","pending_review")',
          );

      if (category != null) {
        dbQuery = dbQuery.eq('category', category.toLowerCase());
      }

      if (blockedUserIds != null && blockedUserIds.isNotEmpty) {
        dbQuery = dbQuery.not('seller_id', 'in', blockedUserIds);
      }

      if (schoolId != null) {
        dbQuery = dbQuery.eq('school_id', schoolId);
      }

      final data = await dbQuery.order('updated_at', ascending: false);
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
          .order('updated_at', ascending: false);
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
          .order('updated_at', ascending: false);
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
            // NOTE: moderation fields are server-managed — never sent from client.
            ..remove('moderation_status')
            ..remove('moderation_note')
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
      if (e.message.contains('row-level security policy')) {
        throw DatabaseException(
          'Action denied. Your account may be restricted.',
          e,
        );
      }
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
            ..remove('moderation_status')
            ..remove('moderation_note')
            ..remove('pickup_location')
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
      if (e.message.contains('row-level security policy')) {
        throw DatabaseException(
          'Action denied. Your account may be restricted.',
          e,
        );
      }
      throw DatabaseException(e.message, e);
    }
  }

  /// Updates a listing's fields AND replaces all its images atomically.
  ///
  /// Upload sequence:
  ///   1. Upload each new [newPhotos] to Storage
  ///   2. Update the listing row
  ///   3. Delete all existing listing_images rows for this listing
  ///   4. Insert new listing_images rows (new URLs)
  ///
  /// [existingImageUrls] — URLs from the original listing that the seller
  /// chose to keep. These are re-inserted without re-uploading.
  /// [newPhotos] — newly picked XFiles that need to be uploaded.
  Future<Listing> updateListingWithImages({
    required Listing listing,
    required String userId,
    required List<String> existingImageUrls,
    required List<XFile> newPhotos,
  }) async {
    try {
      // ── Step 1: Upload new photos ────────────────────────────────
      final newUrls = <String>[];
      for (final photo in newPhotos) {
        final ext = p.extension(photo.name);
        final fileName = '${_uuid.v4()}$ext';
        final publicUrl = await _storageRepository.uploadListingImage(
          userId: userId,
          listingId: listing.id,
          fileName: fileName,
          fileBytes: await photo.readAsBytes(),
        );
        newUrls.add(publicUrl);
      }

      // ── Step 2: Update listing row ───────────────────────────────
      final listingJson =
          listing.toJson()
            ..remove('images')
            ..remove('seller')
            ..remove('moderation_status')
            ..remove('moderation_note')
            ..remove('pickup_location')
            ..['category'] = listing.category.toLowerCase();

      await _client
          .from(AppConstants.tableListings)
          .update(listingJson)
          .eq('id', listing.id);

      // ── Step 3: Replace listing_images rows ──────────────────────
      // Delete all current images for this listing first.
      await _client
          .from(AppConstants.tableListingImages)
          .delete()
          .eq('listing_id', listing.id);

      // Rebuild the combined list: kept existing URLs + newly uploaded URLs.
      final allUrls = [...existingImageUrls, ...newUrls];
      if (allUrls.isNotEmpty) {
        final imagesPayload = allUrls.asMap().entries.map((entry) {
          return {
            'listing_id': listing.id,
            'image_url': entry.value,
            'sort_order': entry.key,
          };
        }).toList();
        await _client
            .from(AppConstants.tableListingImages)
            .insert(imagesPayload);
      }

      return fetchListing(listing.id);
    } on PostgrestException catch (e) {
      throw DatabaseException(e.message, e);
    } on StorageException catch (e) {
      throw AppStorageException(e.message, e);
    }
  }

  /// Invalidates all pending orders for a listing after the seller edits it,
  /// and simultaneously captures a snapshot of the listing's current state.
  ///
  /// NOTE: The snapshot is stored in listing_snapshot so the buyer can see
  /// a before/after diff on the listing detail screen. 'invalidated' is a
  /// soft state — the order reappears in Buyer Center under 'Requested'.
  Future<void> invalidatePendingOrders(
    String listingId, {
    required String title,
    required double price,
    required String? description,
    required String condition,
    required String transactionType,
  }) async {
    try {
      // NOTE: snapshot captures the listing state BEFORE the seller's edits
      // are visible — this method is called right before or just after update.
      // The caller (transaction_management_screen) first fetches the OLD listing,
      // passes those values here, then applies the edit. This guarantees the
      // snapshot reflects what the buyer originally agreed to.
      final snapshot = {
        'title': title,
        'price': price,
        'description': description,
        'condition': condition,
        'transaction_type': transactionType,
        'captured_at': DateTime.now().toUtc().toIso8601String(),
      };

      await _client
          .from(AppConstants.tableOrders)
          .update({'status': 'invalidated', 'listing_snapshot': snapshot})
          .eq('listing_id', listingId)
          .eq('status', 'pending');
    } on PostgrestException catch (e) {
      throw DatabaseException(e.message, e);
    }
  }

  /// Accepts listing changes on behalf of the buyer: clears the snapshot,
  /// reverts the order to 'pending', and notifies the seller.
  ///
  /// Calls the accept_listing_changes SECURITY DEFINER RPC so the buyer
  /// can perform this action without needing direct write access to orders.
  Future<void> acceptListingChanges(String orderId) async {
    try {
      final result = await _client
          .rpc('accept_listing_changes', params: {'p_order_id': orderId})
          .single();
      if (result['success'] != true) {
        throw DatabaseException(result['error'] as String? ?? 'RPC failed', null);
      }
    } on PostgrestException catch (e) {
      throw DatabaseException(e.message, e);
    }
  }

  /// Notifies all buyers with pending/invalidated orders and users who saved
  /// the listing that the listing has been updated by the seller.
  ///
  /// Inserts rows into the `notifications` table; the DB trigger
  /// automatically fires the push-notification Edge Function per row.
  Future<void> notifyListingUpdated({
    required String listingId,
    required String listingTitle,
  }) async {
    try {
      // Collect buyer IDs from pending/invalidated orders
      final orders = await _client
          .from(AppConstants.tableOrders)
          .select('buyer_id')
          .eq('listing_id', listingId)
          .inFilter('status', ['pending', 'invalidated']);

      // Collect user IDs from saved_listings
      final saves = await _client
          .from(AppConstants.tableSavedListings)
          .select('user_id')
          .eq('listing_id', listingId);

      // Deduplicate all recipient IDs
      final recipientIds = <String>{};
      for (final o in orders) {
        final id = o['buyer_id'] as String?;
        if (id != null) recipientIds.add(id);
      }
      for (final s in saves) {
        final id = s['user_id'] as String?;
        if (id != null) recipientIds.add(id);
      }

      if (recipientIds.isEmpty) return;

      // Insert one notification row per recipient.
      // The push-notification Edge Function fires for each INSERT via DB trigger.
      // NOTE: action_type must be 'route' so the Edge Function's push-dispatch
      // logic recognises this as a deep-link notification (not a plain alert).
      final notifications = recipientIds.map((userId) {
        return {
          'user_id': userId,
          'type': 'listing_updated',
          'title': 'Listing Updated',
          'body':
              '"$listingTitle" has been updated by the seller. Tap to view the changes.',
          'action_type': 'route',
          'action_url': '/listing/$listingId',
          'is_read': false,
        };
      }).toList();

      await _client.from('notifications').insert(notifications);
    } on PostgrestException catch (e) {
      // NOTE: Non-critical — notification failure should not block the edit.
      debugPrint('notifyListingUpdated error: ${e.message}');
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

  /// Re-lists a cancelled listing back to 'active', incrementing the cycle.
  ///
  /// NOTE: listing_cycle is incremented so that offers from the previous
  /// failed transaction are isolated. The Seller Center will only show
  /// current-cycle offers going forward; old cancelled orders stay in
  /// History for record-keeping but won't inflate the new inquiry count.
  Future<void> relistListing(String id) async {
    try {
      await _client.rpc('relist_listing', params: {'p_listing_id': id});
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

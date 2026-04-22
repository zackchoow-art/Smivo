import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:smivo/core/utils/image_upload_service.dart';
import 'package:smivo/data/models/listing.dart';
import 'package:smivo/data/repositories/listing_repository.dart';
import 'package:smivo/features/auth/providers/auth_provider.dart';
import 'package:smivo/features/home/providers/home_provider.dart';

part 'create_listing_provider.g.dart';

// State for the form mode ('sale' or 'rent')
@riverpod
class ListingFormMode extends _$ListingFormMode {
  @override
  String build({required String initialMode}) {
    return initialMode;
  }

  void setMode(String mode) {
    state = mode;
  }
}

// State for the selected cropped photos (max 5)
@riverpod
class ListingPhotos extends _$ListingPhotos {
  @override
  List<XFile> build() => [];

  Future<void> addPhoto(BuildContext context) async {
    if (state.length >= 5) return;

    final service = ImageUploadService();
    final xFile = await service.pickAndCropImage(context);

    if (xFile != null) {
      state = [...state, xFile];
    }
  }

  void removePhoto(int index) {
    final newState = List<XFile>.from(state);
    newState.removeAt(index);
    state = newState;
  }

  void clear() {
    state = [];
  }
}

// State for Category Selection
@riverpod
class SelectedListingCategory extends _$SelectedListingCategory {
  @override
  String? build() => null;

  void setCategory(String category) {
    state = category;
  }

  void clear() {
    state = null;
  }
}

/// Handles the async submission of the create listing form.
///
/// Reads photo paths from ListingPhotos, reads form fields 
/// as parameters, uploads photos + creates the listing + 
/// creates listing_images records — all via the repository's 
/// atomic createListingWithImages method.
@riverpod
class CreateListingAction extends _$CreateListingAction {
  @override
  AsyncValue<Listing?> build() => const AsyncValue.data(null);

  /// Submits the form. On success returns the created Listing.
  /// The current photo paths from ListingPhotos are bundled in.
  Future<Listing> submit({
    required String title,
    required String description,
    required String category,
    required String transactionType,
    required String schoolId,
    double? price,
    double? dailyRate,
    double? weeklyRate,
    double? monthlyRate,
    double? depositAmount,
    String? pickupLocationId,
    bool allowPickupChange = false,
    bool isPinned = false,
    int? pinnedDays,
  }) async {
    state = const AsyncValue.loading();
    try {
      final user = ref.read(authStateProvider).valueOrNull;
      if (user == null) {
        throw StateError('You must be logged in to post a listing');
      }

      // Basic validation
      if (title.trim().isEmpty) {
        throw ArgumentError('Title is required');
      }
      if (description.trim().isEmpty) {
        throw ArgumentError('Description is required');
      }
      if (category.trim().isEmpty) {
        throw ArgumentError('Category is required');
      }
      if (schoolId.isEmpty) {
        throw ArgumentError('School ID is required');
      }
      if (transactionType == 'sale' && (price == null || price <= 0)) {
        throw ArgumentError('Sale price is required');
      }
      if (transactionType == 'rental') {
        final hasAnyRate = 
            (dailyRate != null && dailyRate > 0) ||
            (weeklyRate != null && weeklyRate > 0) ||
            (monthlyRate != null && monthlyRate > 0);
        if (!hasAnyRate) {
          throw ArgumentError('At least one rental rate is required');
        }
      }

      // TODO(images): Re-enable this check once image upload
      // is restored. Currently bypassed for testing the listing
      // creation flow end-to-end without photos.
      // final photoPaths = ref.read(listingPhotosProvider);
      // if (photoPaths.isEmpty) {
      //   throw ArgumentError('At least one photo is required');
      // }
      final photoFiles = ref.read(listingPhotosProvider);

      // Build draft Listing — database generates id, timestamps
      final now = DateTime.now();
      final draft = Listing(
        id: '',
        sellerId: user.id,
        schoolId: schoolId,
        pickupLocationId: pickupLocationId,
        allowPickupChange: allowPickupChange,
        title: title.trim(),
        description: description.trim(),
        category: category.toLowerCase(),
        transactionType: transactionType,
        // For rentals, we use the first available rate as the 'price' column 
        // to support sorting/display on feed.
        price: transactionType == 'sale' ? price! : (dailyRate ?? weeklyRate ?? monthlyRate!),
        rentalDailyPrice: dailyRate,
        rentalWeeklyPrice: weeklyRate,
        rentalMonthlyPrice: monthlyRate,
        // NOTE: depositAmount is not currently in the DB schema/Listing model. 
        isPinned: isPinned,
        pinnedDays: pinnedDays,
        status: 'active',
        createdAt: now,
        updatedAt: now,
      );

      final created = await ref
          .read(listingRepositoryProvider)
          .createListingWithImages(
            listing: draft,
            userId: user.id,
            photos: photoFiles,
          );

      // Invalidate home listings so the new item appears
      ref.invalidate(homeListingsProvider);
      
      // Clear form state for next time
      ref.read(listingPhotosProvider.notifier).clear();
      ref.read(selectedListingCategoryProvider.notifier).clear();
      
      state = AsyncValue.data(created);
      return created;
    } catch (e, st) {
      debugPrint('=== CreateListingAction.submit FAILED ===');
      debugPrint('Error: $e');
      debugPrint('Type: ${e.runtimeType}');
      debugPrint('Stack:');
      debugPrint(st.toString());
      debugPrint('=== END ===');

      state = AsyncValue.error(e, st);
      rethrow;
    }
  }
}

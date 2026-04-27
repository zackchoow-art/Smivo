import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:smivo/data/models/saved_listing.dart';
import 'package:smivo/data/repositories/saved_repository.dart';
import 'package:smivo/features/auth/providers/auth_provider.dart';

part 'saved_listing_provider.g.dart';

/// Checks if a specific listing is saved by the current user.
@riverpod
Future<bool> isListingSaved(Ref ref, String listingId) async {
  final user = ref.watch(authStateProvider).valueOrNull;
  if (user == null) return false;
  
  final repo = ref.watch(savedRepositoryProvider);
  return repo.isListingSaved(userId: user.id, listingId: listingId);
}

/// Fetches the current user's saved listings including listing details.
@riverpod
Future<List<SavedListing>> mySavedListings(Ref ref) async {
  final user = ref.watch(authStateProvider).valueOrNull;
  if (user == null) return [];
  
  final repo = ref.watch(savedRepositoryProvider);
  return repo.fetchMySavedListingsWithDetails(user.id);
}

/// Mutation provider for save/unsave actions.
@riverpod
class SavedListingActions extends _$SavedListingActions {
  @override
  AsyncValue<void> build() => const AsyncValue.data(null);

  /// Toggle save state for a listing.
  Future<void> toggleSave(String listingId) async {
    state = const AsyncValue.loading();
    try {
      final user = ref.read(authStateProvider).valueOrNull;
      if (user == null) throw StateError('Must be logged in');

      final repo = ref.read(savedRepositoryProvider);
      final isSaved = await repo.isListingSaved(
        userId: user.id,
        listingId: listingId,
      );

      if (isSaved) {
        await repo.unsaveListing(userId: user.id, listingId: listingId);
      } else {
        await repo.saveListing(userId: user.id, listingId: listingId);
      }

      // Invalidate the check provider so UI updates
      ref.invalidate(isListingSavedProvider(listingId));
      ref.invalidate(mySavedListingsProvider);
      
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:smivo/core/providers/supabase_provider.dart';
import 'package:smivo/data/models/listing.dart';
import 'package:smivo/data/repositories/listing_repository.dart';

part 'home_provider.g.dart';

/// State for the selected category chip.
/// 
/// Defaults to 'All', which maps to fetching listings from all categories.
@riverpod
class SelectedCategory extends _$SelectedCategory {
  @override
  String build() => 'All';

  void setCategory(String category) {
    state = category;
  }
}

/// State for the search query entered in the Home search bar.
@riverpod
class SearchQuery extends _$SearchQuery {
  @override
  String build() => '';

  void setQuery(String query) {
    state = query;
  }
}

/// Main provider for listings on the Home Screen.
/// 
/// Reactive to both [selectedCategoryProvider] and [searchQueryProvider].
/// Uses [ListingRepository] to fetch data from Supabase.
@riverpod
class HomeListings extends _$HomeListings {
  RealtimeChannel? _channel;
  bool _isDisposed = false;

  @override
  Future<List<Listing>> build() async {
    // Only subscribe once per Notifier instance lifecycle
    if (_channel == null) {
      _subscribe();
      ref.onDispose(() {
        _isDisposed = true;
        _channel?.unsubscribe();
        _channel = null;
      });
    }

    final category = ref.watch(selectedCategoryProvider);
    final query = ref.watch(searchQueryProvider);
    final repository = ref.watch(listingRepositoryProvider);

    // Fetch from repository based on current filters.
    if (query.trim().isNotEmpty) {
      return repository.searchListings(
        query.trim(),
        category: category == 'All' ? null : category,
      );
    } else {
      // Normal feed fetch (all or specific category).
      return repository.fetchListings(
        category: category == 'All' ? null : category,
      );
    }
  }

  void _subscribe() {
    final client = ref.read(supabaseClientProvider);
    _channel = client
        .channel('home_listings')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'listings',
          callback: (payload) {
            // Safety check: don't invalidate if we're disposed or disposing
            if (!_isDisposed) {
              ref.invalidateSelf();
            }
          },
        )
        .subscribe();
  }
}

/// Extension to provide easy access to a display image for the UI.
/// 
/// Prioritizes the first image from the listing's images list (populated via joins).
/// Falls back to a generic marketplace placeholder if no images exist.
extension ListingDisplayImage on Listing {
  String? get displayImageUrl {
    if (images.isNotEmpty) {
      return images.first.imageUrl;
    }
    return null;
  }
}

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'home_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// State for the selected category chip.
///
/// Defaults to 'All', which maps to fetching listings from all categories.

@ProviderFor(SelectedCategory)
final selectedCategoryProvider = SelectedCategoryProvider._();

/// State for the selected category chip.
///
/// Defaults to 'All', which maps to fetching listings from all categories.
final class SelectedCategoryProvider
    extends $NotifierProvider<SelectedCategory, String> {
  /// State for the selected category chip.
  ///
  /// Defaults to 'All', which maps to fetching listings from all categories.
  SelectedCategoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'selectedCategoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$selectedCategoryHash();

  @$internal
  @override
  SelectedCategory create() => SelectedCategory();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String>(value),
    );
  }
}

String _$selectedCategoryHash() => r'1d06cb3e38d4f4e5cfb0f45fc3e662b37b6b2e30';

/// State for the selected category chip.
///
/// Defaults to 'All', which maps to fetching listings from all categories.

abstract class _$SelectedCategory extends $Notifier<String> {
  String build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<String, String>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<String, String>,
              String,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

/// State for the search query entered in the Home search bar.

@ProviderFor(SearchQuery)
final searchQueryProvider = SearchQueryProvider._();

/// State for the search query entered in the Home search bar.
final class SearchQueryProvider extends $NotifierProvider<SearchQuery, String> {
  /// State for the search query entered in the Home search bar.
  SearchQueryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'searchQueryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$searchQueryHash();

  @$internal
  @override
  SearchQuery create() => SearchQuery();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String>(value),
    );
  }
}

String _$searchQueryHash() => r'2c146927785523a0ddf51b23b777a9be4afdc092';

/// State for the search query entered in the Home search bar.

abstract class _$SearchQuery extends $Notifier<String> {
  String build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<String, String>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<String, String>,
              String,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

/// Main provider for listings on the Home Screen.
///
/// Reactive to both [selectedCategoryProvider] and [searchQueryProvider].
/// Uses [ListingRepository] to fetch data from Supabase.

@ProviderFor(HomeListings)
final homeListingsProvider = HomeListingsProvider._();

/// Main provider for listings on the Home Screen.
///
/// Reactive to both [selectedCategoryProvider] and [searchQueryProvider].
/// Uses [ListingRepository] to fetch data from Supabase.
final class HomeListingsProvider
    extends $AsyncNotifierProvider<HomeListings, List<Listing>> {
  /// Main provider for listings on the Home Screen.
  ///
  /// Reactive to both [selectedCategoryProvider] and [searchQueryProvider].
  /// Uses [ListingRepository] to fetch data from Supabase.
  HomeListingsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'homeListingsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$homeListingsHash();

  @$internal
  @override
  HomeListings create() => HomeListings();
}

String _$homeListingsHash() => r'317c0164aaafcd9c01ee039000e42724f4734ce0';

/// Main provider for listings on the Home Screen.
///
/// Reactive to both [selectedCategoryProvider] and [searchQueryProvider].
/// Uses [ListingRepository] to fetch data from Supabase.

abstract class _$HomeListings extends $AsyncNotifier<List<Listing>> {
  FutureOr<List<Listing>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<List<Listing>>, List<Listing>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<Listing>>, List<Listing>>,
              AsyncValue<List<Listing>>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

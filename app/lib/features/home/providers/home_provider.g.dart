// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'home_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$selectedCategoryHash() => r'1d06cb3e38d4f4e5cfb0f45fc3e662b37b6b2e30';

/// State for the selected category chip.
///
/// Defaults to 'All', which maps to fetching listings from all categories.
///
/// Copied from [SelectedCategory].
@ProviderFor(SelectedCategory)
final selectedCategoryProvider =
    AutoDisposeNotifierProvider<SelectedCategory, String>.internal(
      SelectedCategory.new,
      name: r'selectedCategoryProvider',
      debugGetCreateSourceHash:
          const bool.fromEnvironment('dart.vm.product')
              ? null
              : _$selectedCategoryHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$SelectedCategory = AutoDisposeNotifier<String>;
String _$searchQueryHash() => r'2c146927785523a0ddf51b23b777a9be4afdc092';

/// State for the search query entered in the Home search bar.
///
/// Copied from [SearchQuery].
@ProviderFor(SearchQuery)
final searchQueryProvider =
    AutoDisposeNotifierProvider<SearchQuery, String>.internal(
      SearchQuery.new,
      name: r'searchQueryProvider',
      debugGetCreateSourceHash:
          const bool.fromEnvironment('dart.vm.product')
              ? null
              : _$searchQueryHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$SearchQuery = AutoDisposeNotifier<String>;
String _$homeListingsHash() => r'041c236b2dfb50e825614b3497d0243b16bf673a';

/// Main provider for listings on the Home Screen.
///
/// Reactive to both [selectedCategoryProvider] and [searchQueryProvider].
/// Uses [ListingRepository] to fetch data from Supabase.
///
/// Copied from [HomeListings].
@ProviderFor(HomeListings)
final homeListingsProvider =
    AutoDisposeAsyncNotifierProvider<HomeListings, List<Listing>>.internal(
      HomeListings.new,
      name: r'homeListingsProvider',
      debugGetCreateSourceHash:
          const bool.fromEnvironment('dart.vm.product')
              ? null
              : _$homeListingsHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$HomeListings = AutoDisposeAsyncNotifier<List<Listing>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package

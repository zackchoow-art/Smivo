// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'listing_detail_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$listingDetailHash() => r'42b0367f6acab7400e64321c4a9f606ad0b02f9e';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

/// Fetches a single listing with all joined details (images, seller) from Supabase.
///
/// Takes a listing [id] as a parameter.
///
/// Copied from [listingDetail].
@ProviderFor(listingDetail)
const listingDetailProvider = ListingDetailFamily();

/// Fetches a single listing with all joined details (images, seller) from Supabase.
///
/// Takes a listing [id] as a parameter.
///
/// Copied from [listingDetail].
class ListingDetailFamily extends Family<AsyncValue<Listing>> {
  /// Fetches a single listing with all joined details (images, seller) from Supabase.
  ///
  /// Takes a listing [id] as a parameter.
  ///
  /// Copied from [listingDetail].
  const ListingDetailFamily();

  /// Fetches a single listing with all joined details (images, seller) from Supabase.
  ///
  /// Takes a listing [id] as a parameter.
  ///
  /// Copied from [listingDetail].
  ListingDetailProvider call(String id) {
    return ListingDetailProvider(id);
  }

  @override
  ListingDetailProvider getProviderOverride(
    covariant ListingDetailProvider provider,
  ) {
    return call(provider.id);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'listingDetailProvider';
}

/// Fetches a single listing with all joined details (images, seller) from Supabase.
///
/// Takes a listing [id] as a parameter.
///
/// Copied from [listingDetail].
class ListingDetailProvider extends AutoDisposeFutureProvider<Listing> {
  /// Fetches a single listing with all joined details (images, seller) from Supabase.
  ///
  /// Takes a listing [id] as a parameter.
  ///
  /// Copied from [listingDetail].
  ListingDetailProvider(String id)
    : this._internal(
        (ref) => listingDetail(ref as ListingDetailRef, id),
        from: listingDetailProvider,
        name: r'listingDetailProvider',
        debugGetCreateSourceHash:
            const bool.fromEnvironment('dart.vm.product')
                ? null
                : _$listingDetailHash,
        dependencies: ListingDetailFamily._dependencies,
        allTransitiveDependencies:
            ListingDetailFamily._allTransitiveDependencies,
        id: id,
      );

  ListingDetailProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.id,
  }) : super.internal();

  final String id;

  @override
  Override overrideWith(
    FutureOr<Listing> Function(ListingDetailRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: ListingDetailProvider._internal(
        (ref) => create(ref as ListingDetailRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        id: id,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<Listing> createElement() {
    return _ListingDetailProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ListingDetailProvider && other.id == id;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, id.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin ListingDetailRef on AutoDisposeFutureProviderRef<Listing> {
  /// The parameter `id` of this provider.
  String get id;
}

class _ListingDetailProviderElement
    extends AutoDisposeFutureProviderElement<Listing>
    with ListingDetailRef {
  _ListingDetailProviderElement(super.provider);

  @override
  String get id => (origin as ListingDetailProvider).id;
}

String _$selectedRentalRateHash() =>
    r'0c444cb1063da1555318c40dcba4f21ce0ae31fd';

/// State for the selected rental rate (DAY, WEEK, MONTH).
///
/// Defaults to 'MONTH' as per the primary design.
///
/// Copied from [SelectedRentalRate].
@ProviderFor(SelectedRentalRate)
final selectedRentalRateProvider =
    AutoDisposeNotifierProvider<SelectedRentalRate, String>.internal(
      SelectedRentalRate.new,
      name: r'selectedRentalRateProvider',
      debugGetCreateSourceHash:
          const bool.fromEnvironment('dart.vm.product')
              ? null
              : _$selectedRentalRateHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$SelectedRentalRate = AutoDisposeNotifier<String>;
String _$rentalDurationHash() => r'62604c48adfb3516ef753d97c78d83a7d454efba';

/// State for the rental duration stepper (e.g., number of months).
///
/// Copied from [RentalDuration].
@ProviderFor(RentalDuration)
final rentalDurationProvider =
    AutoDisposeNotifierProvider<RentalDuration, int>.internal(
      RentalDuration.new,
      name: r'rentalDurationProvider',
      debugGetCreateSourceHash:
          const bool.fromEnvironment('dart.vm.product')
              ? null
              : _$rentalDurationHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$RentalDuration = AutoDisposeNotifier<int>;
String _$rentalStartDateHash() => r'd67d0d05098bab1c0ee6b6be17e2bf1a3e257658';

/// State for the selected rental start date.
///
/// Copied from [RentalStartDate].
@ProviderFor(RentalStartDate)
final rentalStartDateProvider =
    AutoDisposeNotifierProvider<RentalStartDate, DateTime>.internal(
      RentalStartDate.new,
      name: r'rentalStartDateProvider',
      debugGetCreateSourceHash:
          const bool.fromEnvironment('dart.vm.product')
              ? null
              : _$rentalStartDateHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$RentalStartDate = AutoDisposeNotifier<DateTime>;
String _$rentalEndDateHash() => r'76e9032b9f4ae8d55d573e3b2db5759a2cb49271';

/// State for the selected rental end date.
///
/// Copied from [RentalEndDate].
@ProviderFor(RentalEndDate)
final rentalEndDateProvider =
    AutoDisposeNotifierProvider<RentalEndDate, DateTime>.internal(
      RentalEndDate.new,
      name: r'rentalEndDateProvider',
      debugGetCreateSourceHash:
          const bool.fromEnvironment('dart.vm.product')
              ? null
              : _$rentalEndDateHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$RentalEndDate = AutoDisposeNotifier<DateTime>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package

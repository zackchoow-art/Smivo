// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transaction_stats_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$listingOrdersHash() => r'de7c408505fc611e8bec58cccfa650b347f0f9c8';

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

/// Fetches all orders for a specific listing.
///
/// Copied from [listingOrders].
@ProviderFor(listingOrders)
const listingOrdersProvider = ListingOrdersFamily();

/// Fetches all orders for a specific listing.
///
/// Copied from [listingOrders].
class ListingOrdersFamily extends Family<AsyncValue<List<Order>>> {
  /// Fetches all orders for a specific listing.
  ///
  /// Copied from [listingOrders].
  const ListingOrdersFamily();

  /// Fetches all orders for a specific listing.
  ///
  /// Copied from [listingOrders].
  ListingOrdersProvider call(String listingId) {
    return ListingOrdersProvider(listingId);
  }

  @override
  ListingOrdersProvider getProviderOverride(
    covariant ListingOrdersProvider provider,
  ) {
    return call(provider.listingId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'listingOrdersProvider';
}

/// Fetches all orders for a specific listing.
///
/// Copied from [listingOrders].
class ListingOrdersProvider extends AutoDisposeFutureProvider<List<Order>> {
  /// Fetches all orders for a specific listing.
  ///
  /// Copied from [listingOrders].
  ListingOrdersProvider(String listingId)
    : this._internal(
        (ref) => listingOrders(ref as ListingOrdersRef, listingId),
        from: listingOrdersProvider,
        name: r'listingOrdersProvider',
        debugGetCreateSourceHash:
            const bool.fromEnvironment('dart.vm.product')
                ? null
                : _$listingOrdersHash,
        dependencies: ListingOrdersFamily._dependencies,
        allTransitiveDependencies:
            ListingOrdersFamily._allTransitiveDependencies,
        listingId: listingId,
      );

  ListingOrdersProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.listingId,
  }) : super.internal();

  final String listingId;

  @override
  Override overrideWith(
    FutureOr<List<Order>> Function(ListingOrdersRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: ListingOrdersProvider._internal(
        (ref) => create(ref as ListingOrdersRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        listingId: listingId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<Order>> createElement() {
    return _ListingOrdersProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ListingOrdersProvider && other.listingId == listingId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, listingId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin ListingOrdersRef on AutoDisposeFutureProviderRef<List<Order>> {
  /// The parameter `listingId` of this provider.
  String get listingId;
}

class _ListingOrdersProviderElement
    extends AutoDisposeFutureProviderElement<List<Order>>
    with ListingOrdersRef {
  _ListingOrdersProviderElement(super.provider);

  @override
  String get listingId => (origin as ListingOrdersProvider).listingId;
}

String _$listingSavesHash() => r'c6984b4f9bec26f7f54326c79034c8b7082eaa29';

/// Fetches all saves for a specific listing.
///
/// Copied from [listingSaves].
@ProviderFor(listingSaves)
const listingSavesProvider = ListingSavesFamily();

/// Fetches all saves for a specific listing.
///
/// Copied from [listingSaves].
class ListingSavesFamily extends Family<AsyncValue<List<SavedListing>>> {
  /// Fetches all saves for a specific listing.
  ///
  /// Copied from [listingSaves].
  const ListingSavesFamily();

  /// Fetches all saves for a specific listing.
  ///
  /// Copied from [listingSaves].
  ListingSavesProvider call(String listingId) {
    return ListingSavesProvider(listingId);
  }

  @override
  ListingSavesProvider getProviderOverride(
    covariant ListingSavesProvider provider,
  ) {
    return call(provider.listingId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'listingSavesProvider';
}

/// Fetches all saves for a specific listing.
///
/// Copied from [listingSaves].
class ListingSavesProvider
    extends AutoDisposeFutureProvider<List<SavedListing>> {
  /// Fetches all saves for a specific listing.
  ///
  /// Copied from [listingSaves].
  ListingSavesProvider(String listingId)
    : this._internal(
        (ref) => listingSaves(ref as ListingSavesRef, listingId),
        from: listingSavesProvider,
        name: r'listingSavesProvider',
        debugGetCreateSourceHash:
            const bool.fromEnvironment('dart.vm.product')
                ? null
                : _$listingSavesHash,
        dependencies: ListingSavesFamily._dependencies,
        allTransitiveDependencies:
            ListingSavesFamily._allTransitiveDependencies,
        listingId: listingId,
      );

  ListingSavesProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.listingId,
  }) : super.internal();

  final String listingId;

  @override
  Override overrideWith(
    FutureOr<List<SavedListing>> Function(ListingSavesRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: ListingSavesProvider._internal(
        (ref) => create(ref as ListingSavesRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        listingId: listingId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<SavedListing>> createElement() {
    return _ListingSavesProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ListingSavesProvider && other.listingId == listingId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, listingId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin ListingSavesRef on AutoDisposeFutureProviderRef<List<SavedListing>> {
  /// The parameter `listingId` of this provider.
  String get listingId;
}

class _ListingSavesProviderElement
    extends AutoDisposeFutureProviderElement<List<SavedListing>>
    with ListingSavesRef {
  _ListingSavesProviderElement(super.provider);

  @override
  String get listingId => (origin as ListingSavesProvider).listingId;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package

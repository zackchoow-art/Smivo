// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transaction_stats_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$listingOrdersHash() => r'064286f0aa8dc4ca8ba22106d08e0a7763839aa0';

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

abstract class _$ListingOrders
    extends BuildlessAutoDisposeAsyncNotifier<List<Order>> {
  late final String listingId;

  FutureOr<List<Order>> build(String listingId);
}

/// Fetches all orders for a specific listing with realtime updates.
///
/// Copied from [ListingOrders].
@ProviderFor(ListingOrders)
const listingOrdersProvider = ListingOrdersFamily();

/// Fetches all orders for a specific listing with realtime updates.
///
/// Copied from [ListingOrders].
class ListingOrdersFamily extends Family<AsyncValue<List<Order>>> {
  /// Fetches all orders for a specific listing with realtime updates.
  ///
  /// Copied from [ListingOrders].
  const ListingOrdersFamily();

  /// Fetches all orders for a specific listing with realtime updates.
  ///
  /// Copied from [ListingOrders].
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

/// Fetches all orders for a specific listing with realtime updates.
///
/// Copied from [ListingOrders].
class ListingOrdersProvider
    extends AutoDisposeAsyncNotifierProviderImpl<ListingOrders, List<Order>> {
  /// Fetches all orders for a specific listing with realtime updates.
  ///
  /// Copied from [ListingOrders].
  ListingOrdersProvider(String listingId)
    : this._internal(
        () => ListingOrders()..listingId = listingId,
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
  FutureOr<List<Order>> runNotifierBuild(covariant ListingOrders notifier) {
    return notifier.build(listingId);
  }

  @override
  Override overrideWith(ListingOrders Function() create) {
    return ProviderOverride(
      origin: this,
      override: ListingOrdersProvider._internal(
        () => create()..listingId = listingId,
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
  AutoDisposeAsyncNotifierProviderElement<ListingOrders, List<Order>>
  createElement() {
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
mixin ListingOrdersRef on AutoDisposeAsyncNotifierProviderRef<List<Order>> {
  /// The parameter `listingId` of this provider.
  String get listingId;
}

class _ListingOrdersProviderElement
    extends AutoDisposeAsyncNotifierProviderElement<ListingOrders, List<Order>>
    with ListingOrdersRef {
  _ListingOrdersProviderElement(super.provider);

  @override
  String get listingId => (origin as ListingOrdersProvider).listingId;
}

String _$listingSavesHash() => r'223400792a3d0f6d3bfba5101983fad763d4df89';

abstract class _$ListingSaves
    extends BuildlessAutoDisposeAsyncNotifier<List<SavedListing>> {
  late final String listingId;

  FutureOr<List<SavedListing>> build(String listingId);
}

/// Fetches all saves for a specific listing with realtime updates.
///
/// Copied from [ListingSaves].
@ProviderFor(ListingSaves)
const listingSavesProvider = ListingSavesFamily();

/// Fetches all saves for a specific listing with realtime updates.
///
/// Copied from [ListingSaves].
class ListingSavesFamily extends Family<AsyncValue<List<SavedListing>>> {
  /// Fetches all saves for a specific listing with realtime updates.
  ///
  /// Copied from [ListingSaves].
  const ListingSavesFamily();

  /// Fetches all saves for a specific listing with realtime updates.
  ///
  /// Copied from [ListingSaves].
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

/// Fetches all saves for a specific listing with realtime updates.
///
/// Copied from [ListingSaves].
class ListingSavesProvider
    extends
        AutoDisposeAsyncNotifierProviderImpl<ListingSaves, List<SavedListing>> {
  /// Fetches all saves for a specific listing with realtime updates.
  ///
  /// Copied from [ListingSaves].
  ListingSavesProvider(String listingId)
    : this._internal(
        () => ListingSaves()..listingId = listingId,
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
  FutureOr<List<SavedListing>> runNotifierBuild(
    covariant ListingSaves notifier,
  ) {
    return notifier.build(listingId);
  }

  @override
  Override overrideWith(ListingSaves Function() create) {
    return ProviderOverride(
      origin: this,
      override: ListingSavesProvider._internal(
        () => create()..listingId = listingId,
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
  AutoDisposeAsyncNotifierProviderElement<ListingSaves, List<SavedListing>>
  createElement() {
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
mixin ListingSavesRef
    on AutoDisposeAsyncNotifierProviderRef<List<SavedListing>> {
  /// The parameter `listingId` of this provider.
  String get listingId;
}

class _ListingSavesProviderElement
    extends
        AutoDisposeAsyncNotifierProviderElement<
          ListingSaves,
          List<SavedListing>
        >
    with ListingSavesRef {
  _ListingSavesProviderElement(super.provider);

  @override
  String get listingId => (origin as ListingSavesProvider).listingId;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package

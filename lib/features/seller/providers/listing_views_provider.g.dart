// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'listing_views_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$listingViewsHash() => r'ab7f8725e70e5783772087008f9914cb86dbadf8';

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

/// See also [listingViews].
@ProviderFor(listingViews)
const listingViewsProvider = ListingViewsFamily();

/// See also [listingViews].
class ListingViewsFamily extends Family<AsyncValue<List<ListingView>>> {
  /// See also [listingViews].
  const ListingViewsFamily();

  /// See also [listingViews].
  ListingViewsProvider call(String listingId) {
    return ListingViewsProvider(listingId);
  }

  @override
  ListingViewsProvider getProviderOverride(
    covariant ListingViewsProvider provider,
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
  String? get name => r'listingViewsProvider';
}

/// See also [listingViews].
class ListingViewsProvider
    extends AutoDisposeFutureProvider<List<ListingView>> {
  /// See also [listingViews].
  ListingViewsProvider(String listingId)
    : this._internal(
        (ref) => listingViews(ref as ListingViewsRef, listingId),
        from: listingViewsProvider,
        name: r'listingViewsProvider',
        debugGetCreateSourceHash:
            const bool.fromEnvironment('dart.vm.product')
                ? null
                : _$listingViewsHash,
        dependencies: ListingViewsFamily._dependencies,
        allTransitiveDependencies:
            ListingViewsFamily._allTransitiveDependencies,
        listingId: listingId,
      );

  ListingViewsProvider._internal(
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
    FutureOr<List<ListingView>> Function(ListingViewsRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: ListingViewsProvider._internal(
        (ref) => create(ref as ListingViewsRef),
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
  AutoDisposeFutureProviderElement<List<ListingView>> createElement() {
    return _ListingViewsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ListingViewsProvider && other.listingId == listingId;
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
mixin ListingViewsRef on AutoDisposeFutureProviderRef<List<ListingView>> {
  /// The parameter `listingId` of this provider.
  String get listingId;
}

class _ListingViewsProviderElement
    extends AutoDisposeFutureProviderElement<List<ListingView>>
    with ListingViewsRef {
  _ListingViewsProviderElement(super.provider);

  @override
  String get listingId => (origin as ListingViewsProvider).listingId;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package

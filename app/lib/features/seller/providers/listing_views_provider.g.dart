// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'listing_views_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$listingViewsHash() => r'7ff7db1ee6d5b95c505186bf74ca722e0146107b';

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

abstract class _$ListingViews
    extends BuildlessAutoDisposeAsyncNotifier<List<ListingView>> {
  late final String listingId;

  FutureOr<List<ListingView>> build(String listingId);
}

/// See also [ListingViews].
@ProviderFor(ListingViews)
const listingViewsProvider = ListingViewsFamily();

/// See also [ListingViews].
class ListingViewsFamily extends Family<AsyncValue<List<ListingView>>> {
  /// See also [ListingViews].
  const ListingViewsFamily();

  /// See also [ListingViews].
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

/// See also [ListingViews].
class ListingViewsProvider
    extends
        AutoDisposeAsyncNotifierProviderImpl<ListingViews, List<ListingView>> {
  /// See also [ListingViews].
  ListingViewsProvider(String listingId)
    : this._internal(
        () => ListingViews()..listingId = listingId,
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
  FutureOr<List<ListingView>> runNotifierBuild(
    covariant ListingViews notifier,
  ) {
    return notifier.build(listingId);
  }

  @override
  Override overrideWith(ListingViews Function() create) {
    return ProviderOverride(
      origin: this,
      override: ListingViewsProvider._internal(
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
  AutoDisposeAsyncNotifierProviderElement<ListingViews, List<ListingView>>
  createElement() {
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
mixin ListingViewsRef
    on AutoDisposeAsyncNotifierProviderRef<List<ListingView>> {
  /// The parameter `listingId` of this provider.
  String get listingId;
}

class _ListingViewsProviderElement
    extends
        AutoDisposeAsyncNotifierProviderElement<ListingViews, List<ListingView>>
    with ListingViewsRef {
  _ListingViewsProviderElement(super.provider);

  @override
  String get listingId => (origin as ListingViewsProvider).listingId;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package

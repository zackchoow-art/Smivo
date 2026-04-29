// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'saved_listing_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$isListingSavedHash() => r'fa3426fd949f780cf5cb7d30635b255d60262da3';

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

/// Checks if a specific listing is saved by the current user.
///
/// Copied from [isListingSaved].
@ProviderFor(isListingSaved)
const isListingSavedProvider = IsListingSavedFamily();

/// Checks if a specific listing is saved by the current user.
///
/// Copied from [isListingSaved].
class IsListingSavedFamily extends Family<AsyncValue<bool>> {
  /// Checks if a specific listing is saved by the current user.
  ///
  /// Copied from [isListingSaved].
  const IsListingSavedFamily();

  /// Checks if a specific listing is saved by the current user.
  ///
  /// Copied from [isListingSaved].
  IsListingSavedProvider call(String listingId) {
    return IsListingSavedProvider(listingId);
  }

  @override
  IsListingSavedProvider getProviderOverride(
    covariant IsListingSavedProvider provider,
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
  String? get name => r'isListingSavedProvider';
}

/// Checks if a specific listing is saved by the current user.
///
/// Copied from [isListingSaved].
class IsListingSavedProvider extends AutoDisposeFutureProvider<bool> {
  /// Checks if a specific listing is saved by the current user.
  ///
  /// Copied from [isListingSaved].
  IsListingSavedProvider(String listingId)
    : this._internal(
        (ref) => isListingSaved(ref as IsListingSavedRef, listingId),
        from: isListingSavedProvider,
        name: r'isListingSavedProvider',
        debugGetCreateSourceHash:
            const bool.fromEnvironment('dart.vm.product')
                ? null
                : _$isListingSavedHash,
        dependencies: IsListingSavedFamily._dependencies,
        allTransitiveDependencies:
            IsListingSavedFamily._allTransitiveDependencies,
        listingId: listingId,
      );

  IsListingSavedProvider._internal(
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
    FutureOr<bool> Function(IsListingSavedRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: IsListingSavedProvider._internal(
        (ref) => create(ref as IsListingSavedRef),
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
  AutoDisposeFutureProviderElement<bool> createElement() {
    return _IsListingSavedProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is IsListingSavedProvider && other.listingId == listingId;
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
mixin IsListingSavedRef on AutoDisposeFutureProviderRef<bool> {
  /// The parameter `listingId` of this provider.
  String get listingId;
}

class _IsListingSavedProviderElement
    extends AutoDisposeFutureProviderElement<bool>
    with IsListingSavedRef {
  _IsListingSavedProviderElement(super.provider);

  @override
  String get listingId => (origin as IsListingSavedProvider).listingId;
}

String _$mySavedListingsHash() => r'0e1bbdf9599a8863079eb63e6f6a13ad65b06e2c';

/// Fetches the current user's saved listings including listing details.
///
/// Copied from [mySavedListings].
@ProviderFor(mySavedListings)
final mySavedListingsProvider =
    AutoDisposeFutureProvider<List<SavedListing>>.internal(
      mySavedListings,
      name: r'mySavedListingsProvider',
      debugGetCreateSourceHash:
          const bool.fromEnvironment('dart.vm.product')
              ? null
              : _$mySavedListingsHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef MySavedListingsRef = AutoDisposeFutureProviderRef<List<SavedListing>>;
String _$savedListingActionsHash() =>
    r'05564341bbec3522b7a4601a53f01fb74767c7c5';

/// Mutation provider for save/unsave actions.
///
/// Copied from [SavedListingActions].
@ProviderFor(SavedListingActions)
final savedListingActionsProvider =
    AutoDisposeNotifierProvider<SavedListingActions, AsyncValue<void>>.internal(
      SavedListingActions.new,
      name: r'savedListingActionsProvider',
      debugGetCreateSourceHash:
          const bool.fromEnvironment('dart.vm.product')
              ? null
              : _$savedListingActionsHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$SavedListingActions = AutoDisposeNotifier<AsyncValue<void>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package

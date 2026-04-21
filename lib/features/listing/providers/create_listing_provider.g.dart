// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_listing_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$listingFormModeHash() => r'63ea35fa8d3c5579e57cdd2c4e07dc6ecec963f5';

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

abstract class _$ListingFormMode extends BuildlessAutoDisposeNotifier<String> {
  late final String initialMode;

  String build({required String initialMode});
}

/// See also [ListingFormMode].
@ProviderFor(ListingFormMode)
const listingFormModeProvider = ListingFormModeFamily();

/// See also [ListingFormMode].
class ListingFormModeFamily extends Family<String> {
  /// See also [ListingFormMode].
  const ListingFormModeFamily();

  /// See also [ListingFormMode].
  ListingFormModeProvider call({required String initialMode}) {
    return ListingFormModeProvider(initialMode: initialMode);
  }

  @override
  ListingFormModeProvider getProviderOverride(
    covariant ListingFormModeProvider provider,
  ) {
    return call(initialMode: provider.initialMode);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'listingFormModeProvider';
}

/// See also [ListingFormMode].
class ListingFormModeProvider
    extends AutoDisposeNotifierProviderImpl<ListingFormMode, String> {
  /// See also [ListingFormMode].
  ListingFormModeProvider({required String initialMode})
    : this._internal(
        () => ListingFormMode()..initialMode = initialMode,
        from: listingFormModeProvider,
        name: r'listingFormModeProvider',
        debugGetCreateSourceHash:
            const bool.fromEnvironment('dart.vm.product')
                ? null
                : _$listingFormModeHash,
        dependencies: ListingFormModeFamily._dependencies,
        allTransitiveDependencies:
            ListingFormModeFamily._allTransitiveDependencies,
        initialMode: initialMode,
      );

  ListingFormModeProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.initialMode,
  }) : super.internal();

  final String initialMode;

  @override
  String runNotifierBuild(covariant ListingFormMode notifier) {
    return notifier.build(initialMode: initialMode);
  }

  @override
  Override overrideWith(ListingFormMode Function() create) {
    return ProviderOverride(
      origin: this,
      override: ListingFormModeProvider._internal(
        () => create()..initialMode = initialMode,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        initialMode: initialMode,
      ),
    );
  }

  @override
  AutoDisposeNotifierProviderElement<ListingFormMode, String> createElement() {
    return _ListingFormModeProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ListingFormModeProvider && other.initialMode == initialMode;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, initialMode.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin ListingFormModeRef on AutoDisposeNotifierProviderRef<String> {
  /// The parameter `initialMode` of this provider.
  String get initialMode;
}

class _ListingFormModeProviderElement
    extends AutoDisposeNotifierProviderElement<ListingFormMode, String>
    with ListingFormModeRef {
  _ListingFormModeProviderElement(super.provider);

  @override
  String get initialMode => (origin as ListingFormModeProvider).initialMode;
}

String _$listingPhotosHash() => r'88bf68b0abfa15b7bcf0f9e4705c6de61a83b063';

/// See also [ListingPhotos].
@ProviderFor(ListingPhotos)
final listingPhotosProvider =
    AutoDisposeNotifierProvider<ListingPhotos, List<String>>.internal(
      ListingPhotos.new,
      name: r'listingPhotosProvider',
      debugGetCreateSourceHash:
          const bool.fromEnvironment('dart.vm.product')
              ? null
              : _$listingPhotosHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$ListingPhotos = AutoDisposeNotifier<List<String>>;
String _$selectedListingCategoryHash() =>
    r'771c909b7ca555cca4da43a2c777990185bdcdd0';

/// See also [SelectedListingCategory].
@ProviderFor(SelectedListingCategory)
final selectedListingCategoryProvider =
    AutoDisposeNotifierProvider<SelectedListingCategory, String?>.internal(
      SelectedListingCategory.new,
      name: r'selectedListingCategoryProvider',
      debugGetCreateSourceHash:
          const bool.fromEnvironment('dart.vm.product')
              ? null
              : _$selectedListingCategoryHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$SelectedListingCategory = AutoDisposeNotifier<String?>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package

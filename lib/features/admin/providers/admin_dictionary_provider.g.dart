// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_dictionary_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$adminDictionariesHash() => r'e944933d0126b22896cf3741948026b13c9240ce';

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

/// Fetches all system dictionary entries, optionally filtered by type.
///
/// Copied from [adminDictionaries].
@ProviderFor(adminDictionaries)
const adminDictionariesProvider = AdminDictionariesFamily();

/// Fetches all system dictionary entries, optionally filtered by type.
///
/// Copied from [adminDictionaries].
class AdminDictionariesFamily
    extends Family<AsyncValue<List<SystemDictionary>>> {
  /// Fetches all system dictionary entries, optionally filtered by type.
  ///
  /// Copied from [adminDictionaries].
  const AdminDictionariesFamily();

  /// Fetches all system dictionary entries, optionally filtered by type.
  ///
  /// Copied from [adminDictionaries].
  AdminDictionariesProvider call({String? dictType}) {
    return AdminDictionariesProvider(dictType: dictType);
  }

  @override
  AdminDictionariesProvider getProviderOverride(
    covariant AdminDictionariesProvider provider,
  ) {
    return call(dictType: provider.dictType);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'adminDictionariesProvider';
}

/// Fetches all system dictionary entries, optionally filtered by type.
///
/// Copied from [adminDictionaries].
class AdminDictionariesProvider
    extends AutoDisposeFutureProvider<List<SystemDictionary>> {
  /// Fetches all system dictionary entries, optionally filtered by type.
  ///
  /// Copied from [adminDictionaries].
  AdminDictionariesProvider({String? dictType})
    : this._internal(
        (ref) =>
            adminDictionaries(ref as AdminDictionariesRef, dictType: dictType),
        from: adminDictionariesProvider,
        name: r'adminDictionariesProvider',
        debugGetCreateSourceHash:
            const bool.fromEnvironment('dart.vm.product')
                ? null
                : _$adminDictionariesHash,
        dependencies: AdminDictionariesFamily._dependencies,
        allTransitiveDependencies:
            AdminDictionariesFamily._allTransitiveDependencies,
        dictType: dictType,
      );

  AdminDictionariesProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.dictType,
  }) : super.internal();

  final String? dictType;

  @override
  Override overrideWith(
    FutureOr<List<SystemDictionary>> Function(AdminDictionariesRef provider)
    create,
  ) {
    return ProviderOverride(
      origin: this,
      override: AdminDictionariesProvider._internal(
        (ref) => create(ref as AdminDictionariesRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        dictType: dictType,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<SystemDictionary>> createElement() {
    return _AdminDictionariesProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is AdminDictionariesProvider && other.dictType == dictType;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, dictType.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin AdminDictionariesRef
    on AutoDisposeFutureProviderRef<List<SystemDictionary>> {
  /// The parameter `dictType` of this provider.
  String? get dictType;
}

class _AdminDictionariesProviderElement
    extends AutoDisposeFutureProviderElement<List<SystemDictionary>>
    with AdminDictionariesRef {
  _AdminDictionariesProviderElement(super.provider);

  @override
  String? get dictType => (origin as AdminDictionariesProvider).dictType;
}

String _$adminDictTypesHash() => r'b4921f2d9675ae6e0ba5012e23be88ec2afffcf3';

/// Fetches distinct dict_type values for the filter dropdown.
///
/// Copied from [adminDictTypes].
@ProviderFor(adminDictTypes)
final adminDictTypesProvider = AutoDisposeFutureProvider<List<String>>.internal(
  adminDictTypes,
  name: r'adminDictTypesProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$adminDictTypesHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AdminDictTypesRef = AutoDisposeFutureProviderRef<List<String>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package

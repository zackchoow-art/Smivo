// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_categories_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$adminSchoolCategoriesHash() =>
    r'3764de7bfc6789fa4dede6390efc64884a7cfe62';

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

/// Fetches categories for a given school.
///
/// Copied from [adminSchoolCategories].
@ProviderFor(adminSchoolCategories)
const adminSchoolCategoriesProvider = AdminSchoolCategoriesFamily();

/// Fetches categories for a given school.
///
/// Copied from [adminSchoolCategories].
class AdminSchoolCategoriesFamily
    extends Family<AsyncValue<List<SchoolCategory>>> {
  /// Fetches categories for a given school.
  ///
  /// Copied from [adminSchoolCategories].
  const AdminSchoolCategoriesFamily();

  /// Fetches categories for a given school.
  ///
  /// Copied from [adminSchoolCategories].
  AdminSchoolCategoriesProvider call(String schoolId) {
    return AdminSchoolCategoriesProvider(schoolId);
  }

  @override
  AdminSchoolCategoriesProvider getProviderOverride(
    covariant AdminSchoolCategoriesProvider provider,
  ) {
    return call(provider.schoolId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'adminSchoolCategoriesProvider';
}

/// Fetches categories for a given school.
///
/// Copied from [adminSchoolCategories].
class AdminSchoolCategoriesProvider
    extends AutoDisposeFutureProvider<List<SchoolCategory>> {
  /// Fetches categories for a given school.
  ///
  /// Copied from [adminSchoolCategories].
  AdminSchoolCategoriesProvider(String schoolId)
    : this._internal(
        (ref) =>
            adminSchoolCategories(ref as AdminSchoolCategoriesRef, schoolId),
        from: adminSchoolCategoriesProvider,
        name: r'adminSchoolCategoriesProvider',
        debugGetCreateSourceHash:
            const bool.fromEnvironment('dart.vm.product')
                ? null
                : _$adminSchoolCategoriesHash,
        dependencies: AdminSchoolCategoriesFamily._dependencies,
        allTransitiveDependencies:
            AdminSchoolCategoriesFamily._allTransitiveDependencies,
        schoolId: schoolId,
      );

  AdminSchoolCategoriesProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.schoolId,
  }) : super.internal();

  final String schoolId;

  @override
  Override overrideWith(
    FutureOr<List<SchoolCategory>> Function(AdminSchoolCategoriesRef provider)
    create,
  ) {
    return ProviderOverride(
      origin: this,
      override: AdminSchoolCategoriesProvider._internal(
        (ref) => create(ref as AdminSchoolCategoriesRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        schoolId: schoolId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<SchoolCategory>> createElement() {
    return _AdminSchoolCategoriesProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is AdminSchoolCategoriesProvider && other.schoolId == schoolId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, schoolId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin AdminSchoolCategoriesRef
    on AutoDisposeFutureProviderRef<List<SchoolCategory>> {
  /// The parameter `schoolId` of this provider.
  String get schoolId;
}

class _AdminSchoolCategoriesProviderElement
    extends AutoDisposeFutureProviderElement<List<SchoolCategory>>
    with AdminSchoolCategoriesRef {
  _AdminSchoolCategoriesProviderElement(super.provider);

  @override
  String get schoolId => (origin as AdminSchoolCategoriesProvider).schoolId;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package

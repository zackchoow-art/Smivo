// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_pickup_locations_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$adminSchoolPickupLocationsHash() =>
    r'd64bcfec29c68eb053590dce41c4345411e8528d';

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

/// Fetches pickup locations for a specific school.
///
/// Copied from [adminSchoolPickupLocations].
@ProviderFor(adminSchoolPickupLocations)
const adminSchoolPickupLocationsProvider = AdminSchoolPickupLocationsFamily();

/// Fetches pickup locations for a specific school.
///
/// Copied from [adminSchoolPickupLocations].
class AdminSchoolPickupLocationsFamily
    extends Family<AsyncValue<List<PickupLocation>>> {
  /// Fetches pickup locations for a specific school.
  ///
  /// Copied from [adminSchoolPickupLocations].
  const AdminSchoolPickupLocationsFamily();

  /// Fetches pickup locations for a specific school.
  ///
  /// Copied from [adminSchoolPickupLocations].
  AdminSchoolPickupLocationsProvider call(String schoolId) {
    return AdminSchoolPickupLocationsProvider(schoolId);
  }

  @override
  AdminSchoolPickupLocationsProvider getProviderOverride(
    covariant AdminSchoolPickupLocationsProvider provider,
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
  String? get name => r'adminSchoolPickupLocationsProvider';
}

/// Fetches pickup locations for a specific school.
///
/// Copied from [adminSchoolPickupLocations].
class AdminSchoolPickupLocationsProvider
    extends AutoDisposeFutureProvider<List<PickupLocation>> {
  /// Fetches pickup locations for a specific school.
  ///
  /// Copied from [adminSchoolPickupLocations].
  AdminSchoolPickupLocationsProvider(String schoolId)
    : this._internal(
        (ref) => adminSchoolPickupLocations(
          ref as AdminSchoolPickupLocationsRef,
          schoolId,
        ),
        from: adminSchoolPickupLocationsProvider,
        name: r'adminSchoolPickupLocationsProvider',
        debugGetCreateSourceHash:
            const bool.fromEnvironment('dart.vm.product')
                ? null
                : _$adminSchoolPickupLocationsHash,
        dependencies: AdminSchoolPickupLocationsFamily._dependencies,
        allTransitiveDependencies:
            AdminSchoolPickupLocationsFamily._allTransitiveDependencies,
        schoolId: schoolId,
      );

  AdminSchoolPickupLocationsProvider._internal(
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
    FutureOr<List<PickupLocation>> Function(
      AdminSchoolPickupLocationsRef provider,
    )
    create,
  ) {
    return ProviderOverride(
      origin: this,
      override: AdminSchoolPickupLocationsProvider._internal(
        (ref) => create(ref as AdminSchoolPickupLocationsRef),
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
  AutoDisposeFutureProviderElement<List<PickupLocation>> createElement() {
    return _AdminSchoolPickupLocationsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is AdminSchoolPickupLocationsProvider &&
        other.schoolId == schoolId;
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
mixin AdminSchoolPickupLocationsRef
    on AutoDisposeFutureProviderRef<List<PickupLocation>> {
  /// The parameter `schoolId` of this provider.
  String get schoolId;
}

class _AdminSchoolPickupLocationsProviderElement
    extends AutoDisposeFutureProviderElement<List<PickupLocation>>
    with AdminSchoolPickupLocationsRef {
  _AdminSchoolPickupLocationsProviderElement(super.provider);

  @override
  String get schoolId =>
      (origin as AdminSchoolPickupLocationsProvider).schoolId;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package

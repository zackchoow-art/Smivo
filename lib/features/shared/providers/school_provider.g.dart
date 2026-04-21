// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'school_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$activeSchoolsHash() => r'526dba87ee33bd72db185c3bb368e9c938f02703';

/// Fetches all active schools.
/// Used for displaying school lists (e.g. future registration dropdown).
///
/// Copied from [activeSchools].
@ProviderFor(activeSchools)
final activeSchoolsProvider = AutoDisposeFutureProvider<List<School>>.internal(
  activeSchools,
  name: r'activeSchoolsProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$activeSchoolsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ActiveSchoolsRef = AutoDisposeFutureProviderRef<List<School>>;
String _$pickupLocationsForSchoolHash() =>
    r'7c1c205e7fe49cfb0d55251ae424946922dc5408';

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
/// Copied from [pickupLocationsForSchool].
@ProviderFor(pickupLocationsForSchool)
const pickupLocationsForSchoolProvider = PickupLocationsForSchoolFamily();

/// Fetches pickup locations for a specific school.
///
/// Copied from [pickupLocationsForSchool].
class PickupLocationsForSchoolFamily
    extends Family<AsyncValue<List<PickupLocation>>> {
  /// Fetches pickup locations for a specific school.
  ///
  /// Copied from [pickupLocationsForSchool].
  const PickupLocationsForSchoolFamily();

  /// Fetches pickup locations for a specific school.
  ///
  /// Copied from [pickupLocationsForSchool].
  PickupLocationsForSchoolProvider call(String schoolId) {
    return PickupLocationsForSchoolProvider(schoolId);
  }

  @override
  PickupLocationsForSchoolProvider getProviderOverride(
    covariant PickupLocationsForSchoolProvider provider,
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
  String? get name => r'pickupLocationsForSchoolProvider';
}

/// Fetches pickup locations for a specific school.
///
/// Copied from [pickupLocationsForSchool].
class PickupLocationsForSchoolProvider
    extends AutoDisposeFutureProvider<List<PickupLocation>> {
  /// Fetches pickup locations for a specific school.
  ///
  /// Copied from [pickupLocationsForSchool].
  PickupLocationsForSchoolProvider(String schoolId)
    : this._internal(
        (ref) => pickupLocationsForSchool(
          ref as PickupLocationsForSchoolRef,
          schoolId,
        ),
        from: pickupLocationsForSchoolProvider,
        name: r'pickupLocationsForSchoolProvider',
        debugGetCreateSourceHash:
            const bool.fromEnvironment('dart.vm.product')
                ? null
                : _$pickupLocationsForSchoolHash,
        dependencies: PickupLocationsForSchoolFamily._dependencies,
        allTransitiveDependencies:
            PickupLocationsForSchoolFamily._allTransitiveDependencies,
        schoolId: schoolId,
      );

  PickupLocationsForSchoolProvider._internal(
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
      PickupLocationsForSchoolRef provider,
    )
    create,
  ) {
    return ProviderOverride(
      origin: this,
      override: PickupLocationsForSchoolProvider._internal(
        (ref) => create(ref as PickupLocationsForSchoolRef),
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
    return _PickupLocationsForSchoolProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is PickupLocationsForSchoolProvider &&
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
mixin PickupLocationsForSchoolRef
    on AutoDisposeFutureProviderRef<List<PickupLocation>> {
  /// The parameter `schoolId` of this provider.
  String get schoolId;
}

class _PickupLocationsForSchoolProviderElement
    extends AutoDisposeFutureProviderElement<List<PickupLocation>>
    with PickupLocationsForSchoolRef {
  _PickupLocationsForSchoolProviderElement(super.provider);

  @override
  String get schoolId => (origin as PickupLocationsForSchoolProvider).schoolId;
}

String _$myPickupLocationsHash() => r'c866f116466b236643bff0ca2ec3735fe0101ec3';

/// Convenience provider: pickup locations for the CURRENT
/// user's school. Returns empty list if not logged in.
///
/// Copied from [myPickupLocations].
@ProviderFor(myPickupLocations)
final myPickupLocationsProvider =
    AutoDisposeFutureProvider<List<PickupLocation>>.internal(
      myPickupLocations,
      name: r'myPickupLocationsProvider',
      debugGetCreateSourceHash:
          const bool.fromEnvironment('dart.vm.product')
              ? null
              : _$myPickupLocationsHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef MyPickupLocationsRef =
    AutoDisposeFutureProviderRef<List<PickupLocation>>;
String _$mySchoolHash() => r'd99f0c6771aaaf3ca772bbe01378b4e27b2769a7';

/// Convenience provider: the CURRENT user's school object.
/// Returns null if not logged in.
///
/// Copied from [mySchool].
@ProviderFor(mySchool)
final mySchoolProvider = AutoDisposeFutureProvider<School?>.internal(
  mySchool,
  name: r'mySchoolProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$mySchoolHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef MySchoolRef = AutoDisposeFutureProviderRef<School?>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package

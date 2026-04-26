// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_conditions_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$adminSchoolConditionsHash() =>
    r'c196d493b80f8f0266732675632ad1e14049b21a';

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

/// Fetches conditions for a given school.
///
/// Copied from [adminSchoolConditions].
@ProviderFor(adminSchoolConditions)
const adminSchoolConditionsProvider = AdminSchoolConditionsFamily();

/// Fetches conditions for a given school.
///
/// Copied from [adminSchoolConditions].
class AdminSchoolConditionsFamily
    extends Family<AsyncValue<List<SchoolCondition>>> {
  /// Fetches conditions for a given school.
  ///
  /// Copied from [adminSchoolConditions].
  const AdminSchoolConditionsFamily();

  /// Fetches conditions for a given school.
  ///
  /// Copied from [adminSchoolConditions].
  AdminSchoolConditionsProvider call(String schoolId) {
    return AdminSchoolConditionsProvider(schoolId);
  }

  @override
  AdminSchoolConditionsProvider getProviderOverride(
    covariant AdminSchoolConditionsProvider provider,
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
  String? get name => r'adminSchoolConditionsProvider';
}

/// Fetches conditions for a given school.
///
/// Copied from [adminSchoolConditions].
class AdminSchoolConditionsProvider
    extends AutoDisposeFutureProvider<List<SchoolCondition>> {
  /// Fetches conditions for a given school.
  ///
  /// Copied from [adminSchoolConditions].
  AdminSchoolConditionsProvider(String schoolId)
    : this._internal(
        (ref) =>
            adminSchoolConditions(ref as AdminSchoolConditionsRef, schoolId),
        from: adminSchoolConditionsProvider,
        name: r'adminSchoolConditionsProvider',
        debugGetCreateSourceHash:
            const bool.fromEnvironment('dart.vm.product')
                ? null
                : _$adminSchoolConditionsHash,
        dependencies: AdminSchoolConditionsFamily._dependencies,
        allTransitiveDependencies:
            AdminSchoolConditionsFamily._allTransitiveDependencies,
        schoolId: schoolId,
      );

  AdminSchoolConditionsProvider._internal(
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
    FutureOr<List<SchoolCondition>> Function(AdminSchoolConditionsRef provider)
    create,
  ) {
    return ProviderOverride(
      origin: this,
      override: AdminSchoolConditionsProvider._internal(
        (ref) => create(ref as AdminSchoolConditionsRef),
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
  AutoDisposeFutureProviderElement<List<SchoolCondition>> createElement() {
    return _AdminSchoolConditionsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is AdminSchoolConditionsProvider && other.schoolId == schoolId;
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
mixin AdminSchoolConditionsRef
    on AutoDisposeFutureProviderRef<List<SchoolCondition>> {
  /// The parameter `schoolId` of this provider.
  String get schoolId;
}

class _AdminSchoolConditionsProviderElement
    extends AutoDisposeFutureProviderElement<List<SchoolCondition>>
    with AdminSchoolConditionsRef {
  _AdminSchoolConditionsProviderElement(super.provider);

  @override
  String get schoolId => (origin as AdminSchoolConditionsProvider).schoolId;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package

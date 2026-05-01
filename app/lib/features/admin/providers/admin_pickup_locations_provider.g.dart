// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_pickup_locations_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Fetches pickup locations for a specific school.

@ProviderFor(adminSchoolPickupLocations)
final adminSchoolPickupLocationsProvider = AdminSchoolPickupLocationsFamily._();

/// Fetches pickup locations for a specific school.

final class AdminSchoolPickupLocationsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<PickupLocation>>,
          List<PickupLocation>,
          FutureOr<List<PickupLocation>>
        >
    with
        $FutureModifier<List<PickupLocation>>,
        $FutureProvider<List<PickupLocation>> {
  /// Fetches pickup locations for a specific school.
  AdminSchoolPickupLocationsProvider._({
    required AdminSchoolPickupLocationsFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'adminSchoolPickupLocationsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$adminSchoolPickupLocationsHash();

  @override
  String toString() {
    return r'adminSchoolPickupLocationsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<PickupLocation>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<PickupLocation>> create(Ref ref) {
    final argument = this.argument as String;
    return adminSchoolPickupLocations(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is AdminSchoolPickupLocationsProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$adminSchoolPickupLocationsHash() =>
    r'd64bcfec29c68eb053590dce41c4345411e8528d';

/// Fetches pickup locations for a specific school.

final class AdminSchoolPickupLocationsFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<PickupLocation>>, String> {
  AdminSchoolPickupLocationsFamily._()
    : super(
        retry: null,
        name: r'adminSchoolPickupLocationsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Fetches pickup locations for a specific school.

  AdminSchoolPickupLocationsProvider call(String schoolId) =>
      AdminSchoolPickupLocationsProvider._(argument: schoolId, from: this);

  @override
  String toString() => r'adminSchoolPickupLocationsProvider';
}

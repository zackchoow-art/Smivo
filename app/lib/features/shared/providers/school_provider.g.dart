// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'school_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Fetches all active schools.
/// Used for displaying school lists (e.g. future registration dropdown).

@ProviderFor(activeSchools)
final activeSchoolsProvider = ActiveSchoolsProvider._();

/// Fetches all active schools.
/// Used for displaying school lists (e.g. future registration dropdown).

final class ActiveSchoolsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<School>>,
          List<School>,
          FutureOr<List<School>>
        >
    with $FutureModifier<List<School>>, $FutureProvider<List<School>> {
  /// Fetches all active schools.
  /// Used for displaying school lists (e.g. future registration dropdown).
  ActiveSchoolsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'activeSchoolsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$activeSchoolsHash();

  @$internal
  @override
  $FutureProviderElement<List<School>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<School>> create(Ref ref) {
    return activeSchools(ref);
  }
}

String _$activeSchoolsHash() => r'526dba87ee33bd72db185c3bb368e9c938f02703';

/// Fetches pickup locations for a specific school.

@ProviderFor(pickupLocationsForSchool)
final pickupLocationsForSchoolProvider = PickupLocationsForSchoolFamily._();

/// Fetches pickup locations for a specific school.

final class PickupLocationsForSchoolProvider
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
  PickupLocationsForSchoolProvider._({
    required PickupLocationsForSchoolFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'pickupLocationsForSchoolProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$pickupLocationsForSchoolHash();

  @override
  String toString() {
    return r'pickupLocationsForSchoolProvider'
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
    return pickupLocationsForSchool(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is PickupLocationsForSchoolProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$pickupLocationsForSchoolHash() =>
    r'7c1c205e7fe49cfb0d55251ae424946922dc5408';

/// Fetches pickup locations for a specific school.

final class PickupLocationsForSchoolFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<PickupLocation>>, String> {
  PickupLocationsForSchoolFamily._()
    : super(
        retry: null,
        name: r'pickupLocationsForSchoolProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Fetches pickup locations for a specific school.

  PickupLocationsForSchoolProvider call(String schoolId) =>
      PickupLocationsForSchoolProvider._(argument: schoolId, from: this);

  @override
  String toString() => r'pickupLocationsForSchoolProvider';
}

/// Convenience provider: pickup locations for the CURRENT
/// user's school. Returns empty list if not logged in.

@ProviderFor(myPickupLocations)
final myPickupLocationsProvider = MyPickupLocationsProvider._();

/// Convenience provider: pickup locations for the CURRENT
/// user's school. Returns empty list if not logged in.

final class MyPickupLocationsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<PickupLocation>>,
          List<PickupLocation>,
          FutureOr<List<PickupLocation>>
        >
    with
        $FutureModifier<List<PickupLocation>>,
        $FutureProvider<List<PickupLocation>> {
  /// Convenience provider: pickup locations for the CURRENT
  /// user's school. Returns empty list if not logged in.
  MyPickupLocationsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'myPickupLocationsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$myPickupLocationsHash();

  @$internal
  @override
  $FutureProviderElement<List<PickupLocation>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<PickupLocation>> create(Ref ref) {
    return myPickupLocations(ref);
  }
}

String _$myPickupLocationsHash() => r'6306aed946c2b8615afde8738480f98166aac75b';

/// Convenience provider: the CURRENT user's school object.
/// Returns null if not logged in.

@ProviderFor(mySchool)
final mySchoolProvider = MySchoolProvider._();

/// Convenience provider: the CURRENT user's school object.
/// Returns null if not logged in.

final class MySchoolProvider
    extends $FunctionalProvider<AsyncValue<School?>, School?, FutureOr<School?>>
    with $FutureModifier<School?>, $FutureProvider<School?> {
  /// Convenience provider: the CURRENT user's school object.
  /// Returns null if not logged in.
  MySchoolProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'mySchoolProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$mySchoolHash();

  @$internal
  @override
  $FutureProviderElement<School?> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<School?> create(Ref ref) {
    return mySchool(ref);
  }
}

String _$mySchoolHash() => r'2b71607c74f146dd62f7c063bd98b686d1339ee1';

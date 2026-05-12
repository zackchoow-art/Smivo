// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'carpool_trips_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Fetches active carpool trips for a given school.
///
/// Used by the carpool discovery list to show available trips.
/// Automatically refetches when invalidated after a trip is created/cancelled.

@ProviderFor(ActiveCarpoolTrips)
final activeCarpoolTripsProvider = ActiveCarpoolTripsFamily._();

/// Fetches active carpool trips for a given school.
///
/// Used by the carpool discovery list to show available trips.
/// Automatically refetches when invalidated after a trip is created/cancelled.
final class ActiveCarpoolTripsProvider
    extends $AsyncNotifierProvider<ActiveCarpoolTrips, List<CarpoolTrip>> {
  /// Fetches active carpool trips for a given school.
  ///
  /// Used by the carpool discovery list to show available trips.
  /// Automatically refetches when invalidated after a trip is created/cancelled.
  ActiveCarpoolTripsProvider._({
    required ActiveCarpoolTripsFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'activeCarpoolTripsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$activeCarpoolTripsHash();

  @override
  String toString() {
    return r'activeCarpoolTripsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  ActiveCarpoolTrips create() => ActiveCarpoolTrips();

  @override
  bool operator ==(Object other) {
    return other is ActiveCarpoolTripsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$activeCarpoolTripsHash() =>
    r'2c7570be4de25dda6db6a4f9b70bb450faa04268';

/// Fetches active carpool trips for a given school.
///
/// Used by the carpool discovery list to show available trips.
/// Automatically refetches when invalidated after a trip is created/cancelled.

final class ActiveCarpoolTripsFamily extends $Family
    with
        $ClassFamilyOverride<
          ActiveCarpoolTrips,
          AsyncValue<List<CarpoolTrip>>,
          List<CarpoolTrip>,
          FutureOr<List<CarpoolTrip>>,
          String
        > {
  ActiveCarpoolTripsFamily._()
    : super(
        retry: null,
        name: r'activeCarpoolTripsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Fetches active carpool trips for a given school.
  ///
  /// Used by the carpool discovery list to show available trips.
  /// Automatically refetches when invalidated after a trip is created/cancelled.

  ActiveCarpoolTripsProvider call(String schoolId) =>
      ActiveCarpoolTripsProvider._(argument: schoolId, from: this);

  @override
  String toString() => r'activeCarpoolTripsProvider';
}

/// Fetches active carpool trips for a given school.
///
/// Used by the carpool discovery list to show available trips.
/// Automatically refetches when invalidated after a trip is created/cancelled.

abstract class _$ActiveCarpoolTrips extends $AsyncNotifier<List<CarpoolTrip>> {
  late final _$args = ref.$arg as String;
  String get schoolId => _$args;

  FutureOr<List<CarpoolTrip>> build(String schoolId);
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref as $Ref<AsyncValue<List<CarpoolTrip>>, List<CarpoolTrip>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<CarpoolTrip>>, List<CarpoolTrip>>,
              AsyncValue<List<CarpoolTrip>>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, () => build(_$args));
  }
}

/// Fetches all trips the current user has created or joined.

@ProviderFor(MyCarpoolTrips)
final myCarpoolTripsProvider = MyCarpoolTripsProvider._();

/// Fetches all trips the current user has created or joined.
final class MyCarpoolTripsProvider
    extends $AsyncNotifierProvider<MyCarpoolTrips, List<CarpoolTrip>> {
  /// Fetches all trips the current user has created or joined.
  MyCarpoolTripsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'myCarpoolTripsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$myCarpoolTripsHash();

  @$internal
  @override
  MyCarpoolTrips create() => MyCarpoolTrips();
}

String _$myCarpoolTripsHash() => r'38ef3c942b46a63e6ccf23c39bf16d2e1e13ee66';

/// Fetches all trips the current user has created or joined.

abstract class _$MyCarpoolTrips extends $AsyncNotifier<List<CarpoolTrip>> {
  FutureOr<List<CarpoolTrip>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref as $Ref<AsyncValue<List<CarpoolTrip>>, List<CarpoolTrip>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<CarpoolTrip>>, List<CarpoolTrip>>,
              AsyncValue<List<CarpoolTrip>>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

/// Fetches a single trip with full details (creator + members).

@ProviderFor(CarpoolTripDetail)
final carpoolTripDetailProvider = CarpoolTripDetailFamily._();

/// Fetches a single trip with full details (creator + members).
final class CarpoolTripDetailProvider
    extends $AsyncNotifierProvider<CarpoolTripDetail, CarpoolTrip> {
  /// Fetches a single trip with full details (creator + members).
  CarpoolTripDetailProvider._({
    required CarpoolTripDetailFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'carpoolTripDetailProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$carpoolTripDetailHash();

  @override
  String toString() {
    return r'carpoolTripDetailProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  CarpoolTripDetail create() => CarpoolTripDetail();

  @override
  bool operator ==(Object other) {
    return other is CarpoolTripDetailProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$carpoolTripDetailHash() => r'85656b49542cfe0e3a17eacd1bb5b174324e6457';

/// Fetches a single trip with full details (creator + members).

final class CarpoolTripDetailFamily extends $Family
    with
        $ClassFamilyOverride<
          CarpoolTripDetail,
          AsyncValue<CarpoolTrip>,
          CarpoolTrip,
          FutureOr<CarpoolTrip>,
          String
        > {
  CarpoolTripDetailFamily._()
    : super(
        retry: null,
        name: r'carpoolTripDetailProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Fetches a single trip with full details (creator + members).

  CarpoolTripDetailProvider call(String tripId) =>
      CarpoolTripDetailProvider._(argument: tripId, from: this);

  @override
  String toString() => r'carpoolTripDetailProvider';
}

/// Fetches a single trip with full details (creator + members).

abstract class _$CarpoolTripDetail extends $AsyncNotifier<CarpoolTrip> {
  late final _$args = ref.$arg as String;
  String get tripId => _$args;

  FutureOr<CarpoolTrip> build(String tripId);
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<CarpoolTrip>, CarpoolTrip>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<CarpoolTrip>, CarpoolTrip>,
              AsyncValue<CarpoolTrip>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, () => build(_$args));
  }
}

/// Handles creating a new carpool trip.
///
/// Returns the created trip on success. The provider layer handles
/// converting location picker data into the format expected by the repo.

@ProviderFor(CreateCarpoolTrip)
final createCarpoolTripProvider = CreateCarpoolTripProvider._();

/// Handles creating a new carpool trip.
///
/// Returns the created trip on success. The provider layer handles
/// converting location picker data into the format expected by the repo.
final class CreateCarpoolTripProvider
    extends $AsyncNotifierProvider<CreateCarpoolTrip, void> {
  /// Handles creating a new carpool trip.
  ///
  /// Returns the created trip on success. The provider layer handles
  /// converting location picker data into the format expected by the repo.
  CreateCarpoolTripProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'createCarpoolTripProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$createCarpoolTripHash();

  @$internal
  @override
  CreateCarpoolTrip create() => CreateCarpoolTrip();
}

String _$createCarpoolTripHash() => r'270526a2a0e5a4011b15e7d5d1a86e50cd611262';

/// Handles creating a new carpool trip.
///
/// Returns the created trip on success. The provider layer handles
/// converting location picker data into the format expected by the repo.

abstract class _$CreateCarpoolTrip extends $AsyncNotifier<void> {
  FutureOr<void> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<void>, void>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<void>, void>,
              AsyncValue<void>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

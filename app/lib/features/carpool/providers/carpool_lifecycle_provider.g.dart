// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'carpool_lifecycle_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Manages trip status transitions: active → departed → arrived → completed.
///
/// Each state change invalidates the detail provider so the UI reflects
/// the latest status without a manual pull-to-refresh.

@ProviderFor(TripLifecycle)
final tripLifecycleProvider = TripLifecycleFamily._();

/// Manages trip status transitions: active → departed → arrived → completed.
///
/// Each state change invalidates the detail provider so the UI reflects
/// the latest status without a manual pull-to-refresh.
final class TripLifecycleProvider
    extends $AsyncNotifierProvider<TripLifecycle, void> {
  /// Manages trip status transitions: active → departed → arrived → completed.
  ///
  /// Each state change invalidates the detail provider so the UI reflects
  /// the latest status without a manual pull-to-refresh.
  TripLifecycleProvider._({
    required TripLifecycleFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'tripLifecycleProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$tripLifecycleHash();

  @override
  String toString() {
    return r'tripLifecycleProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  TripLifecycle create() => TripLifecycle();

  @override
  bool operator ==(Object other) {
    return other is TripLifecycleProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$tripLifecycleHash() => r'fe016a7a37aaa79ba9603ffa2050b83e615d6aef';

/// Manages trip status transitions: active → departed → arrived → completed.
///
/// Each state change invalidates the detail provider so the UI reflects
/// the latest status without a manual pull-to-refresh.

final class TripLifecycleFamily extends $Family
    with
        $ClassFamilyOverride<
          TripLifecycle,
          AsyncValue<void>,
          void,
          FutureOr<void>,
          String
        > {
  TripLifecycleFamily._()
    : super(
        retry: null,
        name: r'tripLifecycleProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Manages trip status transitions: active → departed → arrived → completed.
  ///
  /// Each state change invalidates the detail provider so the UI reflects
  /// the latest status without a manual pull-to-refresh.

  TripLifecycleProvider call(String tripId) =>
      TripLifecycleProvider._(argument: tripId, from: this);

  @override
  String toString() => r'tripLifecycleProvider';
}

/// Manages trip status transitions: active → departed → arrived → completed.
///
/// Each state change invalidates the detail provider so the UI reflects
/// the latest status without a manual pull-to-refresh.

abstract class _$TripLifecycle extends $AsyncNotifier<void> {
  late final _$args = ref.$arg as String;
  String get tripId => _$args;

  FutureOr<void> build(String tripId);
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
    element.handleCreate(ref, () => build(_$args));
  }
}

/// Loads and manages peer reviews for a completed carpool trip.

@ProviderFor(TripReviews)
final tripReviewsProvider = TripReviewsFamily._();

/// Loads and manages peer reviews for a completed carpool trip.
final class TripReviewsProvider
    extends $AsyncNotifierProvider<TripReviews, List<CarpoolReview>> {
  /// Loads and manages peer reviews for a completed carpool trip.
  TripReviewsProvider._({
    required TripReviewsFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'tripReviewsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$tripReviewsHash();

  @override
  String toString() {
    return r'tripReviewsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  TripReviews create() => TripReviews();

  @override
  bool operator ==(Object other) {
    return other is TripReviewsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$tripReviewsHash() => r'c76705b065502cf356f3f5cd74522c0524d84854';

/// Loads and manages peer reviews for a completed carpool trip.

final class TripReviewsFamily extends $Family
    with
        $ClassFamilyOverride<
          TripReviews,
          AsyncValue<List<CarpoolReview>>,
          List<CarpoolReview>,
          FutureOr<List<CarpoolReview>>,
          String
        > {
  TripReviewsFamily._()
    : super(
        retry: null,
        name: r'tripReviewsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Loads and manages peer reviews for a completed carpool trip.

  TripReviewsProvider call(String tripId) =>
      TripReviewsProvider._(argument: tripId, from: this);

  @override
  String toString() => r'tripReviewsProvider';
}

/// Loads and manages peer reviews for a completed carpool trip.

abstract class _$TripReviews extends $AsyncNotifier<List<CarpoolReview>> {
  late final _$args = ref.$arg as String;
  String get tripId => _$args;

  FutureOr<List<CarpoolReview>> build(String tripId);
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref as $Ref<AsyncValue<List<CarpoolReview>>, List<CarpoolReview>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<CarpoolReview>>, List<CarpoolReview>>,
              AsyncValue<List<CarpoolReview>>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, () => build(_$args));
  }
}

/// Fetches the average carpool rating received by a specific user.
///
/// Returns 0.0 when the user has not been reviewed yet.

@ProviderFor(userCarpoolRating)
final userCarpoolRatingProvider = UserCarpoolRatingFamily._();

/// Fetches the average carpool rating received by a specific user.
///
/// Returns 0.0 when the user has not been reviewed yet.

final class UserCarpoolRatingProvider
    extends $FunctionalProvider<AsyncValue<double>, double, FutureOr<double>>
    with $FutureModifier<double>, $FutureProvider<double> {
  /// Fetches the average carpool rating received by a specific user.
  ///
  /// Returns 0.0 when the user has not been reviewed yet.
  UserCarpoolRatingProvider._({
    required UserCarpoolRatingFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'userCarpoolRatingProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$userCarpoolRatingHash();

  @override
  String toString() {
    return r'userCarpoolRatingProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<double> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<double> create(Ref ref) {
    final argument = this.argument as String;
    return userCarpoolRating(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is UserCarpoolRatingProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$userCarpoolRatingHash() => r'50ea882969084c850faa21adc11fe37c17fb19ca';

/// Fetches the average carpool rating received by a specific user.
///
/// Returns 0.0 when the user has not been reviewed yet.

final class UserCarpoolRatingFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<double>, String> {
  UserCarpoolRatingFamily._()
    : super(
        retry: null,
        name: r'userCarpoolRatingProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Fetches the average carpool rating received by a specific user.
  ///
  /// Returns 0.0 when the user has not been reviewed yet.

  UserCarpoolRatingProvider call(String userId) =>
      UserCarpoolRatingProvider._(argument: userId, from: this);

  @override
  String toString() => r'userCarpoolRatingProvider';
}

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pickup_location_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(pickupLocationRepository)
final pickupLocationRepositoryProvider = PickupLocationRepositoryProvider._();

final class PickupLocationRepositoryProvider
    extends
        $FunctionalProvider<
          PickupLocationRepository,
          PickupLocationRepository,
          PickupLocationRepository
        >
    with $Provider<PickupLocationRepository> {
  PickupLocationRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'pickupLocationRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$pickupLocationRepositoryHash();

  @$internal
  @override
  $ProviderElement<PickupLocationRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  PickupLocationRepository create(Ref ref) {
    return pickupLocationRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PickupLocationRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PickupLocationRepository>(value),
    );
  }
}

String _$pickupLocationRepositoryHash() =>
    r'fe98039e2e09bb019959beb9d34833a67682a48d';

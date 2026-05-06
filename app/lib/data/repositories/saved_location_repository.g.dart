// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'saved_location_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(savedLocationRepository)
final savedLocationRepositoryProvider = SavedLocationRepositoryProvider._();

final class SavedLocationRepositoryProvider
    extends
        $FunctionalProvider<
          SavedLocationRepository,
          SavedLocationRepository,
          SavedLocationRepository
        >
    with $Provider<SavedLocationRepository> {
  SavedLocationRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'savedLocationRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$savedLocationRepositoryHash();

  @$internal
  @override
  $ProviderElement<SavedLocationRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  SavedLocationRepository create(Ref ref) {
    return savedLocationRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SavedLocationRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SavedLocationRepository>(value),
    );
  }
}

String _$savedLocationRepositoryHash() =>
    r'288836601ecc6730c40ea4b113ea2bbc263b3a7d';

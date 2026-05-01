// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'rental_extension_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(rentalExtensionRepository)
final rentalExtensionRepositoryProvider = RentalExtensionRepositoryProvider._();

final class RentalExtensionRepositoryProvider
    extends
        $FunctionalProvider<
          RentalExtensionRepository,
          RentalExtensionRepository,
          RentalExtensionRepository
        >
    with $Provider<RentalExtensionRepository> {
  RentalExtensionRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'rentalExtensionRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$rentalExtensionRepositoryHash();

  @$internal
  @override
  $ProviderElement<RentalExtensionRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  RentalExtensionRepository create(Ref ref) {
    return rentalExtensionRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(RentalExtensionRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<RentalExtensionRepository>(value),
    );
  }
}

String _$rentalExtensionRepositoryHash() =>
    r'5812093d513174f6e1b1bff9bef6e1122969a0d1';

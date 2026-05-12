// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'carpool_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(carpoolRepository)
final carpoolRepositoryProvider = CarpoolRepositoryProvider._();

final class CarpoolRepositoryProvider
    extends
        $FunctionalProvider<
          CarpoolRepository,
          CarpoolRepository,
          CarpoolRepository
        >
    with $Provider<CarpoolRepository> {
  CarpoolRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'carpoolRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$carpoolRepositoryHash();

  @$internal
  @override
  $ProviderElement<CarpoolRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  CarpoolRepository create(Ref ref) {
    return carpoolRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CarpoolRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CarpoolRepository>(value),
    );
  }
}

String _$carpoolRepositoryHash() => r'e535f44de43aaab8136e7ba19501ae09fbcfdfbd';

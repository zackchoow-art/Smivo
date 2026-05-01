// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'school_data_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(schoolDataRepository)
final schoolDataRepositoryProvider = SchoolDataRepositoryProvider._();

final class SchoolDataRepositoryProvider
    extends
        $FunctionalProvider<
          SchoolDataRepository,
          SchoolDataRepository,
          SchoolDataRepository
        >
    with $Provider<SchoolDataRepository> {
  SchoolDataRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'schoolDataRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$schoolDataRepositoryHash();

  @$internal
  @override
  $ProviderElement<SchoolDataRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  SchoolDataRepository create(Ref ref) {
    return schoolDataRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SchoolDataRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SchoolDataRepository>(value),
    );
  }
}

String _$schoolDataRepositoryHash() =>
    r'ae93091bf1f65ad1324b5faf46e4c0ab203c6ce6';

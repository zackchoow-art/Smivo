// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'saved_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(savedRepository)
final savedRepositoryProvider = SavedRepositoryProvider._();

final class SavedRepositoryProvider
    extends
        $FunctionalProvider<SavedRepository, SavedRepository, SavedRepository>
    with $Provider<SavedRepository> {
  SavedRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'savedRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$savedRepositoryHash();

  @$internal
  @override
  $ProviderElement<SavedRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  SavedRepository create(Ref ref) {
    return savedRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SavedRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SavedRepository>(value),
    );
  }
}

String _$savedRepositoryHash() => r'4846c4b3cec643cda6c7f3864369dea847ec97a9';

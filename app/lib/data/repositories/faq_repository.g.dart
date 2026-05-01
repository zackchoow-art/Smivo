// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'faq_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(faqRepository)
final faqRepositoryProvider = FaqRepositoryProvider._();

final class FaqRepositoryProvider
    extends $FunctionalProvider<FaqRepository, FaqRepository, FaqRepository>
    with $Provider<FaqRepository> {
  FaqRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'faqRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$faqRepositoryHash();

  @$internal
  @override
  $ProviderElement<FaqRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  FaqRepository create(Ref ref) {
    return faqRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(FaqRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<FaqRepository>(value),
    );
  }
}

String _$faqRepositoryHash() => r'0e60f7457f821a8b2f8aed8e9635302271a4a6ff';

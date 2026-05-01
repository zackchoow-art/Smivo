// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'help_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(helpFaqs)
final helpFaqsProvider = HelpFaqsProvider._();

final class HelpFaqsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Faq>>,
          List<Faq>,
          FutureOr<List<Faq>>
        >
    with $FutureModifier<List<Faq>>, $FutureProvider<List<Faq>> {
  HelpFaqsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'helpFaqsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$helpFaqsHash();

  @$internal
  @override
  $FutureProviderElement<List<Faq>> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<List<Faq>> create(Ref ref) {
    return helpFaqs(ref);
  }
}

String _$helpFaqsHash() => r'393825e80e41a36fa71504bd383d8d3dc7963a74';

@ProviderFor(ExpandedFaqState)
final expandedFaqStateProvider = ExpandedFaqStateProvider._();

final class ExpandedFaqStateProvider
    extends $NotifierProvider<ExpandedFaqState, String?> {
  ExpandedFaqStateProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'expandedFaqStateProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$expandedFaqStateHash();

  @$internal
  @override
  ExpandedFaqState create() => ExpandedFaqState();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String?>(value),
    );
  }
}

String _$expandedFaqStateHash() => r'735c6c6fdeb157e27bae8b3d479c1b7540e8b99b';

abstract class _$ExpandedFaqState extends $Notifier<String?> {
  String? build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<String?, String?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<String?, String?>,
              String?,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

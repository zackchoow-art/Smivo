// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'content_filter_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(SensitiveWords)
final sensitiveWordsProvider = SensitiveWordsProvider._();

final class SensitiveWordsProvider
    extends $AsyncNotifierProvider<SensitiveWords, ContentFilter> {
  SensitiveWordsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'sensitiveWordsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$sensitiveWordsHash();

  @$internal
  @override
  SensitiveWords create() => SensitiveWords();
}

String _$sensitiveWordsHash() => r'fbff2a3ca8f1e67b5836d8bb8e9890763a2a2e8b';

abstract class _$SensitiveWords extends $AsyncNotifier<ContentFilter> {
  FutureOr<ContentFilter> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<ContentFilter>, ContentFilter>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<ContentFilter>, ContentFilter>,
              AsyncValue<ContentFilter>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

@ProviderFor(FilterConfigState)
final filterConfigStateProvider = FilterConfigStateProvider._();

final class FilterConfigStateProvider
    extends $AsyncNotifierProvider<FilterConfigState, FilterConfig> {
  FilterConfigStateProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'filterConfigStateProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$filterConfigStateHash();

  @$internal
  @override
  FilterConfigState create() => FilterConfigState();
}

String _$filterConfigStateHash() => r'7e4a92d28b78bb35afe501cf8d7d2ac3de3aa097';

abstract class _$FilterConfigState extends $AsyncNotifier<FilterConfig> {
  FutureOr<FilterConfig> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<FilterConfig>, FilterConfig>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<FilterConfig>, FilterConfig>,
              AsyncValue<FilterConfig>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

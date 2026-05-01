// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'system_urls_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(SystemUrls)
final systemUrlsProvider = SystemUrlsProvider._();

final class SystemUrlsProvider
    extends $AsyncNotifierProvider<SystemUrls, Map<String, String>> {
  SystemUrlsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'systemUrlsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$systemUrlsHash();

  @$internal
  @override
  SystemUrls create() => SystemUrls();
}

String _$systemUrlsHash() => r'5d0440e58d6a900080c6c1746d59f0aa7af2e6ba';

abstract class _$SystemUrls extends $AsyncNotifier<Map<String, String>> {
  FutureOr<Map<String, String>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref as $Ref<AsyncValue<Map<String, String>>, Map<String, String>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<Map<String, String>>, Map<String, String>>,
              AsyncValue<Map<String, String>>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

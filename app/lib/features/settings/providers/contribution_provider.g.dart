// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'contribution_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(MyContributions)
final myContributionsProvider = MyContributionsProvider._();

final class MyContributionsProvider
    extends $AsyncNotifierProvider<MyContributions, List<ContributionEntry>> {
  MyContributionsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'myContributionsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$myContributionsHash();

  @$internal
  @override
  MyContributions create() => MyContributions();
}

String _$myContributionsHash() => r'7e73602866d8e719120ce8d05d17c7597068b07c';

abstract class _$MyContributions
    extends $AsyncNotifier<List<ContributionEntry>> {
  FutureOr<List<ContributionEntry>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref
            as $Ref<
              AsyncValue<List<ContributionEntry>>,
              List<ContributionEntry>
            >;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<List<ContributionEntry>>,
                List<ContributionEntry>
              >,
              AsyncValue<List<ContributionEntry>>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

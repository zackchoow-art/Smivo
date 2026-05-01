// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'listing_views_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(ListingViews)
final listingViewsProvider = ListingViewsFamily._();

final class ListingViewsProvider
    extends $AsyncNotifierProvider<ListingViews, List<ListingView>> {
  ListingViewsProvider._({
    required ListingViewsFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'listingViewsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$listingViewsHash();

  @override
  String toString() {
    return r'listingViewsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  ListingViews create() => ListingViews();

  @override
  bool operator ==(Object other) {
    return other is ListingViewsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$listingViewsHash() => r'7ff7db1ee6d5b95c505186bf74ca722e0146107b';

final class ListingViewsFamily extends $Family
    with
        $ClassFamilyOverride<
          ListingViews,
          AsyncValue<List<ListingView>>,
          List<ListingView>,
          FutureOr<List<ListingView>>,
          String
        > {
  ListingViewsFamily._()
    : super(
        retry: null,
        name: r'listingViewsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  ListingViewsProvider call(String listingId) =>
      ListingViewsProvider._(argument: listingId, from: this);

  @override
  String toString() => r'listingViewsProvider';
}

abstract class _$ListingViews extends $AsyncNotifier<List<ListingView>> {
  late final _$args = ref.$arg as String;
  String get listingId => _$args;

  FutureOr<List<ListingView>> build(String listingId);
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref as $Ref<AsyncValue<List<ListingView>>, List<ListingView>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<ListingView>>, List<ListingView>>,
              AsyncValue<List<ListingView>>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, () => build(_$args));
  }
}

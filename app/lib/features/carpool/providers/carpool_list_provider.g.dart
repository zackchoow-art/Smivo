// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'carpool_list_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(CarpoolList)
final carpoolListProvider = CarpoolListProvider._();

final class CarpoolListProvider
    extends $AsyncNotifierProvider<CarpoolList, List<CarpoolTrip>> {
  CarpoolListProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'carpoolListProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$carpoolListHash();

  @$internal
  @override
  CarpoolList create() => CarpoolList();
}

String _$carpoolListHash() => r'c4e28542dbb5f8a500112e6289b30b8f2d0396fc';

abstract class _$CarpoolList extends $AsyncNotifier<List<CarpoolTrip>> {
  FutureOr<List<CarpoolTrip>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref as $Ref<AsyncValue<List<CarpoolTrip>>, List<CarpoolTrip>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<CarpoolTrip>>, List<CarpoolTrip>>,
              AsyncValue<List<CarpoolTrip>>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

@ProviderFor(MyCarpool)
final myCarpoolProvider = MyCarpoolProvider._();

final class MyCarpoolProvider
    extends $AsyncNotifierProvider<MyCarpool, List<CarpoolTrip>> {
  MyCarpoolProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'myCarpoolProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$myCarpoolHash();

  @$internal
  @override
  MyCarpool create() => MyCarpool();
}

String _$myCarpoolHash() => r'85f6d71411a4a4b5caa51d646dc0768e7937c7ef';

abstract class _$MyCarpool extends $AsyncNotifier<List<CarpoolTrip>> {
  FutureOr<List<CarpoolTrip>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref as $Ref<AsyncValue<List<CarpoolTrip>>, List<CarpoolTrip>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<CarpoolTrip>>, List<CarpoolTrip>>,
              AsyncValue<List<CarpoolTrip>>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

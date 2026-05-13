// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'carpool_detail_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(CarpoolDetail)
final carpoolDetailProvider = CarpoolDetailFamily._();

final class CarpoolDetailProvider
    extends $AsyncNotifierProvider<CarpoolDetail, CarpoolTrip?> {
  CarpoolDetailProvider._({
    required CarpoolDetailFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'carpoolDetailProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$carpoolDetailHash();

  @override
  String toString() {
    return r'carpoolDetailProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  CarpoolDetail create() => CarpoolDetail();

  @override
  bool operator ==(Object other) {
    return other is CarpoolDetailProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$carpoolDetailHash() => r'3b623a9cbddcf771fe3560a50a02b7eaf4c74aa2';

final class CarpoolDetailFamily extends $Family
    with
        $ClassFamilyOverride<
          CarpoolDetail,
          AsyncValue<CarpoolTrip?>,
          CarpoolTrip?,
          FutureOr<CarpoolTrip?>,
          String
        > {
  CarpoolDetailFamily._()
    : super(
        retry: null,
        name: r'carpoolDetailProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  CarpoolDetailProvider call(String tripId) =>
      CarpoolDetailProvider._(argument: tripId, from: this);

  @override
  String toString() => r'carpoolDetailProvider';
}

abstract class _$CarpoolDetail extends $AsyncNotifier<CarpoolTrip?> {
  late final _$args = ref.$arg as String;
  String get tripId => _$args;

  FutureOr<CarpoolTrip?> build(String tripId);
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<CarpoolTrip?>, CarpoolTrip?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<CarpoolTrip?>, CarpoolTrip?>,
              AsyncValue<CarpoolTrip?>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, () => build(_$args));
  }
}

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_carpool_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(CreateCarpool)
final createCarpoolProvider = CreateCarpoolProvider._();

final class CreateCarpoolProvider
    extends $NotifierProvider<CreateCarpool, AsyncValue<void>> {
  CreateCarpoolProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'createCarpoolProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$createCarpoolHash();

  @$internal
  @override
  CreateCarpool create() => CreateCarpool();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AsyncValue<void> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AsyncValue<void>>(value),
    );
  }
}

String _$createCarpoolHash() => r'f04294c2c76e1f6dc4be9eb3506ce6b539cdf1dd';

abstract class _$CreateCarpool extends $Notifier<AsyncValue<void>> {
  AsyncValue<void> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<void>, AsyncValue<void>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<void>, AsyncValue<void>>,
              AsyncValue<void>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

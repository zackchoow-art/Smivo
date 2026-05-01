// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'order_evidence_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Fetches evidence photos for a specific order.

@ProviderFor(orderEvidence)
final orderEvidenceProvider = OrderEvidenceFamily._();

/// Fetches evidence photos for a specific order.

final class OrderEvidenceProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<OrderEvidence>>,
          List<OrderEvidence>,
          FutureOr<List<OrderEvidence>>
        >
    with
        $FutureModifier<List<OrderEvidence>>,
        $FutureProvider<List<OrderEvidence>> {
  /// Fetches evidence photos for a specific order.
  OrderEvidenceProvider._({
    required OrderEvidenceFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'orderEvidenceProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$orderEvidenceHash();

  @override
  String toString() {
    return r'orderEvidenceProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<OrderEvidence>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<OrderEvidence>> create(Ref ref) {
    final argument = this.argument as String;
    return orderEvidence(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is OrderEvidenceProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$orderEvidenceHash() => r'3b677f9a47b5cd639a82dce8a4a61f7478043139';

/// Fetches evidence photos for a specific order.

final class OrderEvidenceFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<OrderEvidence>>, String> {
  OrderEvidenceFamily._()
    : super(
        retry: null,
        name: r'orderEvidenceProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Fetches evidence photos for a specific order.

  OrderEvidenceProvider call(String orderId) =>
      OrderEvidenceProvider._(argument: orderId, from: this);

  @override
  String toString() => r'orderEvidenceProvider';
}

/// Mutation provider for uploading evidence.

@ProviderFor(EvidenceUploader)
final evidenceUploaderProvider = EvidenceUploaderProvider._();

/// Mutation provider for uploading evidence.
final class EvidenceUploaderProvider
    extends $NotifierProvider<EvidenceUploader, AsyncValue<void>> {
  /// Mutation provider for uploading evidence.
  EvidenceUploaderProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'evidenceUploaderProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$evidenceUploaderHash();

  @$internal
  @override
  EvidenceUploader create() => EvidenceUploader();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AsyncValue<void> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AsyncValue<void>>(value),
    );
  }
}

String _$evidenceUploaderHash() => r'bb20f3f48c07a9487a33b38897b4da5b3618fd90';

/// Mutation provider for uploading evidence.

abstract class _$EvidenceUploader extends $Notifier<AsyncValue<void>> {
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

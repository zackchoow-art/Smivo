// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'order_evidence_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(orderEvidenceRepository)
final orderEvidenceRepositoryProvider = OrderEvidenceRepositoryProvider._();

final class OrderEvidenceRepositoryProvider
    extends
        $FunctionalProvider<
          OrderEvidenceRepository,
          OrderEvidenceRepository,
          OrderEvidenceRepository
        >
    with $Provider<OrderEvidenceRepository> {
  OrderEvidenceRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'orderEvidenceRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$orderEvidenceRepositoryHash();

  @$internal
  @override
  $ProviderElement<OrderEvidenceRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  OrderEvidenceRepository create(Ref ref) {
    return orderEvidenceRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(OrderEvidenceRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<OrderEvidenceRepository>(value),
    );
  }
}

String _$orderEvidenceRepositoryHash() =>
    r'a0b80b3547f647436ba7f41d586ec1ca0d8cea90';

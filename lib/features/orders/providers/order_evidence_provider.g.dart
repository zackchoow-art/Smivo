// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'order_evidence_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$orderEvidenceHash() => r'3b677f9a47b5cd639a82dce8a4a61f7478043139';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

/// Fetches evidence photos for a specific order.
///
/// Copied from [orderEvidence].
@ProviderFor(orderEvidence)
const orderEvidenceProvider = OrderEvidenceFamily();

/// Fetches evidence photos for a specific order.
///
/// Copied from [orderEvidence].
class OrderEvidenceFamily extends Family<AsyncValue<List<OrderEvidence>>> {
  /// Fetches evidence photos for a specific order.
  ///
  /// Copied from [orderEvidence].
  const OrderEvidenceFamily();

  /// Fetches evidence photos for a specific order.
  ///
  /// Copied from [orderEvidence].
  OrderEvidenceProvider call(String orderId) {
    return OrderEvidenceProvider(orderId);
  }

  @override
  OrderEvidenceProvider getProviderOverride(
    covariant OrderEvidenceProvider provider,
  ) {
    return call(provider.orderId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'orderEvidenceProvider';
}

/// Fetches evidence photos for a specific order.
///
/// Copied from [orderEvidence].
class OrderEvidenceProvider
    extends AutoDisposeFutureProvider<List<OrderEvidence>> {
  /// Fetches evidence photos for a specific order.
  ///
  /// Copied from [orderEvidence].
  OrderEvidenceProvider(String orderId)
    : this._internal(
        (ref) => orderEvidence(ref as OrderEvidenceRef, orderId),
        from: orderEvidenceProvider,
        name: r'orderEvidenceProvider',
        debugGetCreateSourceHash:
            const bool.fromEnvironment('dart.vm.product')
                ? null
                : _$orderEvidenceHash,
        dependencies: OrderEvidenceFamily._dependencies,
        allTransitiveDependencies:
            OrderEvidenceFamily._allTransitiveDependencies,
        orderId: orderId,
      );

  OrderEvidenceProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.orderId,
  }) : super.internal();

  final String orderId;

  @override
  Override overrideWith(
    FutureOr<List<OrderEvidence>> Function(OrderEvidenceRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: OrderEvidenceProvider._internal(
        (ref) => create(ref as OrderEvidenceRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        orderId: orderId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<OrderEvidence>> createElement() {
    return _OrderEvidenceProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is OrderEvidenceProvider && other.orderId == orderId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, orderId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin OrderEvidenceRef on AutoDisposeFutureProviderRef<List<OrderEvidence>> {
  /// The parameter `orderId` of this provider.
  String get orderId;
}

class _OrderEvidenceProviderElement
    extends AutoDisposeFutureProviderElement<List<OrderEvidence>>
    with OrderEvidenceRef {
  _OrderEvidenceProviderElement(super.provider);

  @override
  String get orderId => (origin as OrderEvidenceProvider).orderId;
}

String _$evidenceUploaderHash() => r'56e42ca1eaec387100b5afdf633e787889b895ab';

/// Mutation provider for uploading evidence.
///
/// Copied from [EvidenceUploader].
@ProviderFor(EvidenceUploader)
final evidenceUploaderProvider =
    AutoDisposeNotifierProvider<EvidenceUploader, AsyncValue<void>>.internal(
      EvidenceUploader.new,
      name: r'evidenceUploaderProvider',
      debugGetCreateSourceHash:
          const bool.fromEnvironment('dart.vm.product')
              ? null
              : _$evidenceUploaderHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$EvidenceUploader = AutoDisposeNotifier<AsyncValue<void>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package

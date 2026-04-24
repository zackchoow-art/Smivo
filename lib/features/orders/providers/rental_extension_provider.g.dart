// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'rental_extension_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$orderExtensionsHash() => r'0643a539bc718191a83b999cf2b5a7c1d15b7809';

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

/// Fetches all extension requests for a given order.
///
/// Copied from [orderExtensions].
@ProviderFor(orderExtensions)
const orderExtensionsProvider = OrderExtensionsFamily();

/// Fetches all extension requests for a given order.
///
/// Copied from [orderExtensions].
class OrderExtensionsFamily extends Family<AsyncValue<List<RentalExtension>>> {
  /// Fetches all extension requests for a given order.
  ///
  /// Copied from [orderExtensions].
  const OrderExtensionsFamily();

  /// Fetches all extension requests for a given order.
  ///
  /// Copied from [orderExtensions].
  OrderExtensionsProvider call(String orderId) {
    return OrderExtensionsProvider(orderId);
  }

  @override
  OrderExtensionsProvider getProviderOverride(
    covariant OrderExtensionsProvider provider,
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
  String? get name => r'orderExtensionsProvider';
}

/// Fetches all extension requests for a given order.
///
/// Copied from [orderExtensions].
class OrderExtensionsProvider
    extends AutoDisposeFutureProvider<List<RentalExtension>> {
  /// Fetches all extension requests for a given order.
  ///
  /// Copied from [orderExtensions].
  OrderExtensionsProvider(String orderId)
    : this._internal(
        (ref) => orderExtensions(ref as OrderExtensionsRef, orderId),
        from: orderExtensionsProvider,
        name: r'orderExtensionsProvider',
        debugGetCreateSourceHash:
            const bool.fromEnvironment('dart.vm.product')
                ? null
                : _$orderExtensionsHash,
        dependencies: OrderExtensionsFamily._dependencies,
        allTransitiveDependencies:
            OrderExtensionsFamily._allTransitiveDependencies,
        orderId: orderId,
      );

  OrderExtensionsProvider._internal(
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
    FutureOr<List<RentalExtension>> Function(OrderExtensionsRef provider)
    create,
  ) {
    return ProviderOverride(
      origin: this,
      override: OrderExtensionsProvider._internal(
        (ref) => create(ref as OrderExtensionsRef),
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
  AutoDisposeFutureProviderElement<List<RentalExtension>> createElement() {
    return _OrderExtensionsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is OrderExtensionsProvider && other.orderId == orderId;
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
mixin OrderExtensionsRef
    on AutoDisposeFutureProviderRef<List<RentalExtension>> {
  /// The parameter `orderId` of this provider.
  String get orderId;
}

class _OrderExtensionsProviderElement
    extends AutoDisposeFutureProviderElement<List<RentalExtension>>
    with OrderExtensionsRef {
  _OrderExtensionsProviderElement(super.provider);

  @override
  String get orderId => (origin as OrderExtensionsProvider).orderId;
}

String _$rentalExtensionActionsHash() =>
    r'9cdb8d956b03a8b80d71bed4243303be1c74808c';

/// Handles extension request actions (create, approve, reject).
///
/// Copied from [RentalExtensionActions].
@ProviderFor(RentalExtensionActions)
final rentalExtensionActionsProvider =
    AutoDisposeAsyncNotifierProvider<RentalExtensionActions, void>.internal(
      RentalExtensionActions.new,
      name: r'rentalExtensionActionsProvider',
      debugGetCreateSourceHash:
          const bool.fromEnvironment('dart.vm.product')
              ? null
              : _$rentalExtensionActionsHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$RentalExtensionActions = AutoDisposeAsyncNotifier<void>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package

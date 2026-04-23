// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'orders_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$filteredOrdersHash() => r'5bcb39ddaba4053e3b9a97901000e80b64d9f783';

/// Orders filtered by the currently selected tab (buying vs selling).
///
/// Copied from [filteredOrders].
@ProviderFor(filteredOrders)
final filteredOrdersProvider = AutoDisposeFutureProvider<List<Order>>.internal(
  filteredOrders,
  name: r'filteredOrdersProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$filteredOrdersHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef FilteredOrdersRef = AutoDisposeFutureProviderRef<List<Order>>;
String _$orderDetailHash() => r'0452f926a3ee175fff257efb04ee578c9469b813';

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

/// Fetches a single order by ID.
///
/// Copied from [orderDetail].
@ProviderFor(orderDetail)
const orderDetailProvider = OrderDetailFamily();

/// Fetches a single order by ID.
///
/// Copied from [orderDetail].
class OrderDetailFamily extends Family<AsyncValue<Order>> {
  /// Fetches a single order by ID.
  ///
  /// Copied from [orderDetail].
  const OrderDetailFamily();

  /// Fetches a single order by ID.
  ///
  /// Copied from [orderDetail].
  OrderDetailProvider call(String orderId) {
    return OrderDetailProvider(orderId);
  }

  @override
  OrderDetailProvider getProviderOverride(
    covariant OrderDetailProvider provider,
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
  String? get name => r'orderDetailProvider';
}

/// Fetches a single order by ID.
///
/// Copied from [orderDetail].
class OrderDetailProvider extends AutoDisposeFutureProvider<Order> {
  /// Fetches a single order by ID.
  ///
  /// Copied from [orderDetail].
  OrderDetailProvider(String orderId)
    : this._internal(
        (ref) => orderDetail(ref as OrderDetailRef, orderId),
        from: orderDetailProvider,
        name: r'orderDetailProvider',
        debugGetCreateSourceHash:
            const bool.fromEnvironment('dart.vm.product')
                ? null
                : _$orderDetailHash,
        dependencies: OrderDetailFamily._dependencies,
        allTransitiveDependencies: OrderDetailFamily._allTransitiveDependencies,
        orderId: orderId,
      );

  OrderDetailProvider._internal(
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
    FutureOr<Order> Function(OrderDetailRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: OrderDetailProvider._internal(
        (ref) => create(ref as OrderDetailRef),
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
  AutoDisposeFutureProviderElement<Order> createElement() {
    return _OrderDetailProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is OrderDetailProvider && other.orderId == orderId;
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
mixin OrderDetailRef on AutoDisposeFutureProviderRef<Order> {
  /// The parameter `orderId` of this provider.
  String get orderId;
}

class _OrderDetailProviderElement
    extends AutoDisposeFutureProviderElement<Order>
    with OrderDetailRef {
  _OrderDetailProviderElement(super.provider);

  @override
  String get orderId => (origin as OrderDetailProvider).orderId;
}

String _$selectedOrdersTabHash() => r'f83cc35478509dc892152616cfc4b09b6fd4c726';

/// Current tab state for the orders screen.
///
/// Copied from [SelectedOrdersTab].
@ProviderFor(SelectedOrdersTab)
final selectedOrdersTabProvider =
    AutoDisposeNotifierProvider<SelectedOrdersTab, OrdersTab>.internal(
      SelectedOrdersTab.new,
      name: r'selectedOrdersTabProvider',
      debugGetCreateSourceHash:
          const bool.fromEnvironment('dart.vm.product')
              ? null
              : _$selectedOrdersTabHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$SelectedOrdersTab = AutoDisposeNotifier<OrdersTab>;
String _$allOrdersHash() => r'895ce6f37dbd1aa764f2bf5bc08c8dbdd9783e70';

/// Fetches all orders for the current user with realtime updates.
///
/// Subscribes to INSERT/UPDATE on the orders table. RLS ensures
/// we only receive events for rows where we are buyer or seller.
/// Any change re-fetches the list so status transitions propagate
/// to all screens holding this provider.
///
/// Copied from [AllOrders].
@ProviderFor(AllOrders)
final allOrdersProvider =
    AutoDisposeAsyncNotifierProvider<AllOrders, List<Order>>.internal(
      AllOrders.new,
      name: r'allOrdersProvider',
      debugGetCreateSourceHash:
          const bool.fromEnvironment('dart.vm.product')
              ? null
              : _$allOrdersHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$AllOrders = AutoDisposeAsyncNotifier<List<Order>>;
String _$orderActionsHash() => r'8eb23c7c1d285a42abcac7f984ccba527aee80a2';

/// Mutation actions for a specific order.
///
/// Copied from [OrderActions].
@ProviderFor(OrderActions)
final orderActionsProvider =
    AutoDisposeNotifierProvider<OrderActions, AsyncValue<void>>.internal(
      OrderActions.new,
      name: r'orderActionsProvider',
      debugGetCreateSourceHash:
          const bool.fromEnvironment('dart.vm.product')
              ? null
              : _$orderActionsHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$OrderActions = AutoDisposeNotifier<AsyncValue<void>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package

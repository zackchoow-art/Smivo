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
String _$latestOrderByListingAndBuyerHash() =>
    r'eb59ce578ff0b7be7662ba577015b314ef7fe89b';

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

/// Fetches the latest order for a specific listing and buyer.
///
/// Copied from [latestOrderByListingAndBuyer].
@ProviderFor(latestOrderByListingAndBuyer)
const latestOrderByListingAndBuyerProvider =
    LatestOrderByListingAndBuyerFamily();

/// Fetches the latest order for a specific listing and buyer.
///
/// Copied from [latestOrderByListingAndBuyer].
class LatestOrderByListingAndBuyerFamily extends Family<AsyncValue<Order?>> {
  /// Fetches the latest order for a specific listing and buyer.
  ///
  /// Copied from [latestOrderByListingAndBuyer].
  const LatestOrderByListingAndBuyerFamily();

  /// Fetches the latest order for a specific listing and buyer.
  ///
  /// Copied from [latestOrderByListingAndBuyer].
  LatestOrderByListingAndBuyerProvider call({
    required String listingId,
    required String buyerId,
  }) {
    return LatestOrderByListingAndBuyerProvider(
      listingId: listingId,
      buyerId: buyerId,
    );
  }

  @override
  LatestOrderByListingAndBuyerProvider getProviderOverride(
    covariant LatestOrderByListingAndBuyerProvider provider,
  ) {
    return call(listingId: provider.listingId, buyerId: provider.buyerId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'latestOrderByListingAndBuyerProvider';
}

/// Fetches the latest order for a specific listing and buyer.
///
/// Copied from [latestOrderByListingAndBuyer].
class LatestOrderByListingAndBuyerProvider
    extends AutoDisposeFutureProvider<Order?> {
  /// Fetches the latest order for a specific listing and buyer.
  ///
  /// Copied from [latestOrderByListingAndBuyer].
  LatestOrderByListingAndBuyerProvider({
    required String listingId,
    required String buyerId,
  }) : this._internal(
         (ref) => latestOrderByListingAndBuyer(
           ref as LatestOrderByListingAndBuyerRef,
           listingId: listingId,
           buyerId: buyerId,
         ),
         from: latestOrderByListingAndBuyerProvider,
         name: r'latestOrderByListingAndBuyerProvider',
         debugGetCreateSourceHash:
             const bool.fromEnvironment('dart.vm.product')
                 ? null
                 : _$latestOrderByListingAndBuyerHash,
         dependencies: LatestOrderByListingAndBuyerFamily._dependencies,
         allTransitiveDependencies:
             LatestOrderByListingAndBuyerFamily._allTransitiveDependencies,
         listingId: listingId,
         buyerId: buyerId,
       );

  LatestOrderByListingAndBuyerProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.listingId,
    required this.buyerId,
  }) : super.internal();

  final String listingId;
  final String buyerId;

  @override
  Override overrideWith(
    FutureOr<Order?> Function(LatestOrderByListingAndBuyerRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: LatestOrderByListingAndBuyerProvider._internal(
        (ref) => create(ref as LatestOrderByListingAndBuyerRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        listingId: listingId,
        buyerId: buyerId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<Order?> createElement() {
    return _LatestOrderByListingAndBuyerProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is LatestOrderByListingAndBuyerProvider &&
        other.listingId == listingId &&
        other.buyerId == buyerId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, listingId.hashCode);
    hash = _SystemHash.combine(hash, buyerId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin LatestOrderByListingAndBuyerRef on AutoDisposeFutureProviderRef<Order?> {
  /// The parameter `listingId` of this provider.
  String get listingId;

  /// The parameter `buyerId` of this provider.
  String get buyerId;
}

class _LatestOrderByListingAndBuyerProviderElement
    extends AutoDisposeFutureProviderElement<Order?>
    with LatestOrderByListingAndBuyerRef {
  _LatestOrderByListingAndBuyerProviderElement(super.provider);

  @override
  String get listingId =>
      (origin as LatestOrderByListingAndBuyerProvider).listingId;
  @override
  String get buyerId =>
      (origin as LatestOrderByListingAndBuyerProvider).buyerId;
}

String _$unreadOrderUpdatesCountHash() =>
    r'755c023d9908483c8f20a9c36cae051cd766c757';

/// See also [unreadOrderUpdatesCount].
@ProviderFor(unreadOrderUpdatesCount)
final unreadOrderUpdatesCountProvider = AutoDisposeFutureProvider<int>.internal(
  unreadOrderUpdatesCount,
  name: r'unreadOrderUpdatesCountProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$unreadOrderUpdatesCountHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef UnreadOrderUpdatesCountRef = AutoDisposeFutureProviderRef<int>;
String _$unreadBuyerUpdatesCountHash() =>
    r'1c7892d991e071748710ca08cd7e7f2150ab8e34';

/// See also [unreadBuyerUpdatesCount].
@ProviderFor(unreadBuyerUpdatesCount)
final unreadBuyerUpdatesCountProvider = AutoDisposeFutureProvider<int>.internal(
  unreadBuyerUpdatesCount,
  name: r'unreadBuyerUpdatesCountProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$unreadBuyerUpdatesCountHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef UnreadBuyerUpdatesCountRef = AutoDisposeFutureProviderRef<int>;
String _$unreadSellerUpdatesCountHash() =>
    r'c8e787d7cb7f7b93359613b2f2390a7908a88c38';

/// See also [unreadSellerUpdatesCount].
@ProviderFor(unreadSellerUpdatesCount)
final unreadSellerUpdatesCountProvider =
    AutoDisposeFutureProvider<int>.internal(
      unreadSellerUpdatesCount,
      name: r'unreadSellerUpdatesCountProvider',
      debugGetCreateSourceHash:
          const bool.fromEnvironment('dart.vm.product')
              ? null
              : _$unreadSellerUpdatesCountHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef UnreadSellerUpdatesCountRef = AutoDisposeFutureProviderRef<int>;
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
String _$orderDetailHash() => r'd5fdd919f9c21f2cba5655ac50667dfbcb417a44';

abstract class _$OrderDetail extends BuildlessAutoDisposeAsyncNotifier<Order> {
  late final String orderId;

  FutureOr<Order> build(String orderId);
}

/// Fetches a single order by ID with realtime updates.
///
/// Copied from [OrderDetail].
@ProviderFor(OrderDetail)
const orderDetailProvider = OrderDetailFamily();

/// Fetches a single order by ID with realtime updates.
///
/// Copied from [OrderDetail].
class OrderDetailFamily extends Family<AsyncValue<Order>> {
  /// Fetches a single order by ID with realtime updates.
  ///
  /// Copied from [OrderDetail].
  const OrderDetailFamily();

  /// Fetches a single order by ID with realtime updates.
  ///
  /// Copied from [OrderDetail].
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

/// Fetches a single order by ID with realtime updates.
///
/// Copied from [OrderDetail].
class OrderDetailProvider
    extends AutoDisposeAsyncNotifierProviderImpl<OrderDetail, Order> {
  /// Fetches a single order by ID with realtime updates.
  ///
  /// Copied from [OrderDetail].
  OrderDetailProvider(String orderId)
    : this._internal(
        () => OrderDetail()..orderId = orderId,
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
  FutureOr<Order> runNotifierBuild(covariant OrderDetail notifier) {
    return notifier.build(orderId);
  }

  @override
  Override overrideWith(OrderDetail Function() create) {
    return ProviderOverride(
      origin: this,
      override: OrderDetailProvider._internal(
        () => create()..orderId = orderId,
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
  AutoDisposeAsyncNotifierProviderElement<OrderDetail, Order> createElement() {
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
mixin OrderDetailRef on AutoDisposeAsyncNotifierProviderRef<Order> {
  /// The parameter `orderId` of this provider.
  String get orderId;
}

class _OrderDetailProviderElement
    extends AutoDisposeAsyncNotifierProviderElement<OrderDetail, Order>
    with OrderDetailRef {
  _OrderDetailProviderElement(super.provider);

  @override
  String get orderId => (origin as OrderDetailProvider).orderId;
}

String _$orderActionsHash() => r'9623b1b5f8e98f2cfa43297e32bf3e8620fe8529';

/// Handles order actions (cancel, confirm delivery, request return, etc.).
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

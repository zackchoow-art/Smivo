// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'orders_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Current tab state for the orders screen.

@ProviderFor(SelectedOrdersTab)
final selectedOrdersTabProvider = SelectedOrdersTabProvider._();

/// Current tab state for the orders screen.
final class SelectedOrdersTabProvider
    extends $NotifierProvider<SelectedOrdersTab, OrdersTab> {
  /// Current tab state for the orders screen.
  SelectedOrdersTabProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'selectedOrdersTabProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$selectedOrdersTabHash();

  @$internal
  @override
  SelectedOrdersTab create() => SelectedOrdersTab();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(OrdersTab value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<OrdersTab>(value),
    );
  }
}

String _$selectedOrdersTabHash() => r'f83cc35478509dc892152616cfc4b09b6fd4c726';

/// Current tab state for the orders screen.

abstract class _$SelectedOrdersTab extends $Notifier<OrdersTab> {
  OrdersTab build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<OrdersTab, OrdersTab>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<OrdersTab, OrdersTab>,
              OrdersTab,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

/// Fetches all orders for the current user with realtime updates.
///
/// Subscribes to INSERT/UPDATE on the orders table. RLS ensures
/// we only receive events for rows where we are buyer or seller.
/// Any change re-fetches the list so status transitions propagate
/// to all screens holding this provider.

@ProviderFor(AllOrders)
final allOrdersProvider = AllOrdersProvider._();

/// Fetches all orders for the current user with realtime updates.
///
/// Subscribes to INSERT/UPDATE on the orders table. RLS ensures
/// we only receive events for rows where we are buyer or seller.
/// Any change re-fetches the list so status transitions propagate
/// to all screens holding this provider.
final class AllOrdersProvider
    extends $AsyncNotifierProvider<AllOrders, List<Order>> {
  /// Fetches all orders for the current user with realtime updates.
  ///
  /// Subscribes to INSERT/UPDATE on the orders table. RLS ensures
  /// we only receive events for rows where we are buyer or seller.
  /// Any change re-fetches the list so status transitions propagate
  /// to all screens holding this provider.
  AllOrdersProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'allOrdersProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$allOrdersHash();

  @$internal
  @override
  AllOrders create() => AllOrders();
}

String _$allOrdersHash() => r'6c5d92a0849c24582e3efcdfa0fcdc8e85079ecf';

/// Fetches all orders for the current user with realtime updates.
///
/// Subscribes to INSERT/UPDATE on the orders table. RLS ensures
/// we only receive events for rows where we are buyer or seller.
/// Any change re-fetches the list so status transitions propagate
/// to all screens holding this provider.

abstract class _$AllOrders extends $AsyncNotifier<List<Order>> {
  FutureOr<List<Order>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<List<Order>>, List<Order>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<Order>>, List<Order>>,
              AsyncValue<List<Order>>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

/// Orders filtered by the currently selected tab (buying vs selling).

@ProviderFor(filteredOrders)
final filteredOrdersProvider = FilteredOrdersProvider._();

/// Orders filtered by the currently selected tab (buying vs selling).

final class FilteredOrdersProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Order>>,
          List<Order>,
          FutureOr<List<Order>>
        >
    with $FutureModifier<List<Order>>, $FutureProvider<List<Order>> {
  /// Orders filtered by the currently selected tab (buying vs selling).
  FilteredOrdersProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'filteredOrdersProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$filteredOrdersHash();

  @$internal
  @override
  $FutureProviderElement<List<Order>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<Order>> create(Ref ref) {
    return filteredOrders(ref);
  }
}

String _$filteredOrdersHash() => r'0ff6a024da9b1c28dca9991adaca19489bee4927';

/// Fetches a single order by ID with realtime updates.

@ProviderFor(OrderDetail)
final orderDetailProvider = OrderDetailFamily._();

/// Fetches a single order by ID with realtime updates.
final class OrderDetailProvider
    extends $AsyncNotifierProvider<OrderDetail, Order> {
  /// Fetches a single order by ID with realtime updates.
  OrderDetailProvider._({
    required OrderDetailFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'orderDetailProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$orderDetailHash();

  @override
  String toString() {
    return r'orderDetailProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  OrderDetail create() => OrderDetail();

  @override
  bool operator ==(Object other) {
    return other is OrderDetailProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$orderDetailHash() => r'd5fdd919f9c21f2cba5655ac50667dfbcb417a44';

/// Fetches a single order by ID with realtime updates.

final class OrderDetailFamily extends $Family
    with
        $ClassFamilyOverride<
          OrderDetail,
          AsyncValue<Order>,
          Order,
          FutureOr<Order>,
          String
        > {
  OrderDetailFamily._()
    : super(
        retry: null,
        name: r'orderDetailProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Fetches a single order by ID with realtime updates.

  OrderDetailProvider call(String orderId) =>
      OrderDetailProvider._(argument: orderId, from: this);

  @override
  String toString() => r'orderDetailProvider';
}

/// Fetches a single order by ID with realtime updates.

abstract class _$OrderDetail extends $AsyncNotifier<Order> {
  late final _$args = ref.$arg as String;
  String get orderId => _$args;

  FutureOr<Order> build(String orderId);
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<Order>, Order>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<Order>, Order>,
              AsyncValue<Order>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, () => build(_$args));
  }
}

/// Fetches the latest order for a specific listing and buyer.

@ProviderFor(latestOrderByListingAndBuyer)
final latestOrderByListingAndBuyerProvider =
    LatestOrderByListingAndBuyerFamily._();

/// Fetches the latest order for a specific listing and buyer.

final class LatestOrderByListingAndBuyerProvider
    extends $FunctionalProvider<AsyncValue<Order?>, Order?, FutureOr<Order?>>
    with $FutureModifier<Order?>, $FutureProvider<Order?> {
  /// Fetches the latest order for a specific listing and buyer.
  LatestOrderByListingAndBuyerProvider._({
    required LatestOrderByListingAndBuyerFamily super.from,
    required ({String listingId, String buyerId}) super.argument,
  }) : super(
         retry: null,
         name: r'latestOrderByListingAndBuyerProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$latestOrderByListingAndBuyerHash();

  @override
  String toString() {
    return r'latestOrderByListingAndBuyerProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $FutureProviderElement<Order?> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<Order?> create(Ref ref) {
    final argument = this.argument as ({String listingId, String buyerId});
    return latestOrderByListingAndBuyer(
      ref,
      listingId: argument.listingId,
      buyerId: argument.buyerId,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is LatestOrderByListingAndBuyerProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$latestOrderByListingAndBuyerHash() =>
    r'13307ff52eec048f45dd9dc9d6b001a3d81953c7';

/// Fetches the latest order for a specific listing and buyer.

final class LatestOrderByListingAndBuyerFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<Order?>,
          ({String listingId, String buyerId})
        > {
  LatestOrderByListingAndBuyerFamily._()
    : super(
        retry: null,
        name: r'latestOrderByListingAndBuyerProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Fetches the latest order for a specific listing and buyer.

  LatestOrderByListingAndBuyerProvider call({
    required String listingId,
    required String buyerId,
  }) => LatestOrderByListingAndBuyerProvider._(
    argument: (listingId: listingId, buyerId: buyerId),
    from: this,
  );

  @override
  String toString() => r'latestOrderByListingAndBuyerProvider';
}

/// Handles order actions (cancel, confirm delivery, request return, etc.).

@ProviderFor(OrderActions)
final orderActionsProvider = OrderActionsProvider._();

/// Handles order actions (cancel, confirm delivery, request return, etc.).
final class OrderActionsProvider
    extends $NotifierProvider<OrderActions, AsyncValue<void>> {
  /// Handles order actions (cancel, confirm delivery, request return, etc.).
  OrderActionsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'orderActionsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$orderActionsHash();

  @$internal
  @override
  OrderActions create() => OrderActions();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AsyncValue<void> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AsyncValue<void>>(value),
    );
  }
}

String _$orderActionsHash() => r'064f8dd2bc93cf6920f00b3c5ad1bd59fd33a77c';

/// Handles order actions (cancel, confirm delivery, request return, etc.).

abstract class _$OrderActions extends $Notifier<AsyncValue<void>> {
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

@ProviderFor(unreadOrderUpdatesCount)
final unreadOrderUpdatesCountProvider = UnreadOrderUpdatesCountProvider._();

final class UnreadOrderUpdatesCountProvider
    extends $FunctionalProvider<AsyncValue<int>, int, FutureOr<int>>
    with $FutureModifier<int>, $FutureProvider<int> {
  UnreadOrderUpdatesCountProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'unreadOrderUpdatesCountProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$unreadOrderUpdatesCountHash();

  @$internal
  @override
  $FutureProviderElement<int> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<int> create(Ref ref) {
    return unreadOrderUpdatesCount(ref);
  }
}

String _$unreadOrderUpdatesCountHash() =>
    r'755c023d9908483c8f20a9c36cae051cd766c757';

@ProviderFor(unreadBuyerUpdatesCount)
final unreadBuyerUpdatesCountProvider = UnreadBuyerUpdatesCountProvider._();

final class UnreadBuyerUpdatesCountProvider
    extends $FunctionalProvider<AsyncValue<int>, int, FutureOr<int>>
    with $FutureModifier<int>, $FutureProvider<int> {
  UnreadBuyerUpdatesCountProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'unreadBuyerUpdatesCountProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$unreadBuyerUpdatesCountHash();

  @$internal
  @override
  $FutureProviderElement<int> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<int> create(Ref ref) {
    return unreadBuyerUpdatesCount(ref);
  }
}

String _$unreadBuyerUpdatesCountHash() =>
    r'2c697c370de13efe7c4465d7e9c941e204925586';

@ProviderFor(unreadSellerUpdatesCount)
final unreadSellerUpdatesCountProvider = UnreadSellerUpdatesCountProvider._();

final class UnreadSellerUpdatesCountProvider
    extends $FunctionalProvider<AsyncValue<int>, int, FutureOr<int>>
    with $FutureModifier<int>, $FutureProvider<int> {
  UnreadSellerUpdatesCountProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'unreadSellerUpdatesCountProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$unreadSellerUpdatesCountHash();

  @$internal
  @override
  $FutureProviderElement<int> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<int> create(Ref ref) {
    return unreadSellerUpdatesCount(ref);
  }
}

String _$unreadSellerUpdatesCountHash() =>
    r'1f1d08c84b38a056bf3f75b517ae92a1ddd96bac';

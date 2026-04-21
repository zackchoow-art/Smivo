// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'orders_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$ordersHash() => r'873b03d11b46ff5f243bd17c16fc6a3c0d8974af';

/// See also [orders].
@ProviderFor(orders)
final ordersProvider = AutoDisposeProvider<List<Order>>.internal(
  orders,
  name: r'ordersProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$ordersHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef OrdersRef = AutoDisposeProviderRef<List<Order>>;
String _$ordersTabHash() => r'55afd16314436d0f4ab72e54fa6eb2d6d74ed985';

/// See also [OrdersTab].
@ProviderFor(OrdersTab)
final ordersTabProvider =
    AutoDisposeNotifierProvider<OrdersTab, OrderTab>.internal(
      OrdersTab.new,
      name: r'ordersTabProvider',
      debugGetCreateSourceHash:
          const bool.fromEnvironment('dart.vm.product')
              ? null
              : _$ordersTabHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$OrdersTab = AutoDisposeNotifier<OrderTab>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package

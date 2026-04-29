// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'buyer_center_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$buyerOrdersHash() => r'ce91ee35b44f4c80bb366887d30c7338ae56d378';

/// Fetches all orders where the current user is the buyer (realtime).
///
/// Copied from [buyerOrders].
@ProviderFor(buyerOrders)
final buyerOrdersProvider = AutoDisposeFutureProvider<List<Order>>.internal(
  buyerOrders,
  name: r'buyerOrdersProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$buyerOrdersHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef BuyerOrdersRef = AutoDisposeFutureProviderRef<List<Order>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package

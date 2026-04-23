// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'buyer_center_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$buyerOrdersHash() => r'da273065a82b03e04da2393fc5fb8a765a0fb29d';

/// Fetches all orders where the current user is the buyer.
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

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_orders_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$adminOrdersHash() => r'bd360cb5b60d77b1268cf19dc201ee5479ab70e3';

/// Fetches all orders for the admin panel.
///
/// Copied from [adminOrders].
@ProviderFor(adminOrders)
final adminOrdersProvider =
    AutoDisposeFutureProvider<List<Map<String, dynamic>>>.internal(
      adminOrders,
      name: r'adminOrdersProvider',
      debugGetCreateSourceHash:
          const bool.fromEnvironment('dart.vm.product')
              ? null
              : _$adminOrdersHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AdminOrdersRef =
    AutoDisposeFutureProviderRef<List<Map<String, dynamic>>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package

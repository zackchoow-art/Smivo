// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'seller_center_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$sellerOrdersHash() => r'508a61d08db3bae82fe66815863d5d9cb2b90377';

/// Fetches all orders where the current user is the seller.
///
/// Copied from [sellerOrders].
@ProviderFor(sellerOrders)
final sellerOrdersProvider = AutoDisposeFutureProvider<List<Order>>.internal(
  sellerOrders,
  name: r'sellerOrdersProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$sellerOrdersHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef SellerOrdersRef = AutoDisposeFutureProviderRef<List<Order>>;
String _$myListingsHash() => r'fc2ec9a9b04f7c49a53749e0affffba59c148330';

/// Fetches all listings owned by the current user with realtime updates.
///
/// Copied from [MyListings].
@ProviderFor(MyListings)
final myListingsProvider =
    AutoDisposeAsyncNotifierProvider<MyListings, List<Listing>>.internal(
      MyListings.new,
      name: r'myListingsProvider',
      debugGetCreateSourceHash:
          const bool.fromEnvironment('dart.vm.product')
              ? null
              : _$myListingsHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$MyListings = AutoDisposeAsyncNotifier<List<Listing>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package

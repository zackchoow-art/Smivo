// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'seller_center_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Fetches all listings owned by the current user with realtime updates.

@ProviderFor(MyListings)
final myListingsProvider = MyListingsProvider._();

/// Fetches all listings owned by the current user with realtime updates.
final class MyListingsProvider
    extends $AsyncNotifierProvider<MyListings, List<Listing>> {
  /// Fetches all listings owned by the current user with realtime updates.
  MyListingsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'myListingsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$myListingsHash();

  @$internal
  @override
  MyListings create() => MyListings();
}

String _$myListingsHash() => r'd27c9cd88a9942e420e052036faa1ea1ebeb3330';

/// Fetches all listings owned by the current user with realtime updates.

abstract class _$MyListings extends $AsyncNotifier<List<Listing>> {
  FutureOr<List<Listing>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<List<Listing>>, List<Listing>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<Listing>>, List<Listing>>,
              AsyncValue<List<Listing>>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

/// Fetches all orders where the current user is the seller.

@ProviderFor(sellerOrders)
final sellerOrdersProvider = SellerOrdersProvider._();

/// Fetches all orders where the current user is the seller.

final class SellerOrdersProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Order>>,
          List<Order>,
          FutureOr<List<Order>>
        >
    with $FutureModifier<List<Order>>, $FutureProvider<List<Order>> {
  /// Fetches all orders where the current user is the seller.
  SellerOrdersProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'sellerOrdersProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$sellerOrdersHash();

  @$internal
  @override
  $FutureProviderElement<List<Order>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<Order>> create(Ref ref) {
    return sellerOrders(ref);
  }
}

String _$sellerOrdersHash() => r'2665d5536db11114897ed1ffe1a37dd91a41bd17';

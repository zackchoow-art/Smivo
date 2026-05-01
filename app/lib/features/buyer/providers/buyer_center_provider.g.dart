// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'buyer_center_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Fetches all orders where the current user is the buyer (realtime).

@ProviderFor(buyerOrders)
final buyerOrdersProvider = BuyerOrdersProvider._();

/// Fetches all orders where the current user is the buyer (realtime).

final class BuyerOrdersProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Order>>,
          List<Order>,
          FutureOr<List<Order>>
        >
    with $FutureModifier<List<Order>>, $FutureProvider<List<Order>> {
  /// Fetches all orders where the current user is the buyer (realtime).
  BuyerOrdersProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'buyerOrdersProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$buyerOrdersHash();

  @$internal
  @override
  $FutureProviderElement<List<Order>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<Order>> create(Ref ref) {
    return buyerOrders(ref);
  }
}

String _$buyerOrdersHash() => r'92eb165ae00db8b2d9d62c3e941aaffce7a5830d';

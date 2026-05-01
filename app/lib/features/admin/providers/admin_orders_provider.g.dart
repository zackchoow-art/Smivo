// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_orders_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Fetches all orders for the admin panel.

@ProviderFor(adminOrders)
final adminOrdersProvider = AdminOrdersProvider._();

/// Fetches all orders for the admin panel.

final class AdminOrdersProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Map<String, dynamic>>>,
          List<Map<String, dynamic>>,
          FutureOr<List<Map<String, dynamic>>>
        >
    with
        $FutureModifier<List<Map<String, dynamic>>>,
        $FutureProvider<List<Map<String, dynamic>>> {
  /// Fetches all orders for the admin panel.
  AdminOrdersProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'adminOrdersProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$adminOrdersHash();

  @$internal
  @override
  $FutureProviderElement<List<Map<String, dynamic>>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<Map<String, dynamic>>> create(Ref ref) {
    return adminOrders(ref);
  }
}

String _$adminOrdersHash() => r'bd360cb5b60d77b1268cf19dc201ee5479ab70e3';

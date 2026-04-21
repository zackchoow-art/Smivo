import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:smivo/data/models/order.dart';
import 'package:smivo/data/repositories/order_repository.dart';
import 'package:smivo/features/auth/providers/auth_provider.dart';

part 'orders_provider.g.dart';

/// Which tab is active on the orders screen.
enum OrdersTab { buying, selling }

/// Current tab state for the orders screen.
@riverpod
class SelectedOrdersTab extends _$SelectedOrdersTab {
  @override
  OrdersTab build() => OrdersTab.buying;

  void setTab(OrdersTab tab) {
    state = tab;
  }
}

/// Fetches all orders for the current user.
///
/// Reactive to auth state — returns empty list if user is not logged in.
@riverpod
Future<List<Order>> allOrders(Ref ref) async {
  final user = ref.watch(authStateProvider).valueOrNull;
  if (user == null) return [];

  final repository = ref.watch(orderRepositoryProvider);
  return repository.fetchOrders(user.id);
}

/// Orders filtered by the currently selected tab (buying vs selling).
@riverpod
Future<List<Order>> filteredOrders(Ref ref) async {
  final user = ref.watch(authStateProvider).valueOrNull;
  if (user == null) return [];

  final tab = ref.watch(selectedOrdersTabProvider);
  final allOrdersList = await ref.watch(allOrdersProvider.future);

  if (tab == OrdersTab.buying) {
    return allOrdersList.where((o) => o.buyerId == user.id).toList();
  } else {
    return allOrdersList.where((o) => o.sellerId == user.id).toList();
  }
}

/// Fetches a single order by ID.
@riverpod
Future<Order> orderDetail(Ref ref, String orderId) async {
  final repository = ref.watch(orderRepositoryProvider);
  return repository.fetchOrder(orderId);
}

/// Mutation actions for a specific order.
@riverpod
class OrderActions extends _$OrderActions {
  @override
  AsyncValue<void> build() => const AsyncValue.data(null);

  /// Cancels an order (buyer or seller can trigger).
  Future<void> cancelOrder(String orderId) async {
    state = const AsyncValue.loading();
    try {
      await ref.read(orderRepositoryProvider).updateOrderStatus(orderId, 'cancelled');
      // Refresh order lists so the cancelled order shows updated status
      ref.invalidate(allOrdersProvider);
      ref.invalidate(orderDetailProvider(orderId));
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// Confirms delivery for the current user's role.
  ///
  /// The role is determined by comparing the current user's id to
  /// the order's buyer/seller. If both parties have confirmed,
  /// the order transitions to 'completed'.
  Future<void> confirmDelivery(Order order) async {
    state = const AsyncValue.loading();
    try {
      final user = ref.read(authStateProvider).valueOrNull;
      if (user == null) {
        throw StateError('User must be logged in to confirm delivery');
      }

      final role = (order.buyerId == user.id) ? 'buyer' : 'seller';

      await ref.read(orderRepositoryProvider).confirmDelivery(
        orderId: order.id,
        byUserRole: role,
      );

      // Refresh lists so status updates everywhere
      ref.invalidate(allOrdersProvider);
      ref.invalidate(orderDetailProvider(order.id));
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

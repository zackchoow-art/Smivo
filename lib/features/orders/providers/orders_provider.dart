import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:smivo/core/providers/supabase_provider.dart';
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

/// Fetches all orders for the current user with realtime updates.
///
/// Subscribes to INSERT/UPDATE on the orders table. RLS ensures 
/// we only receive events for rows where we are buyer or seller. 
/// Any change re-fetches the list so status transitions propagate 
/// to all screens holding this provider.
@riverpod
class AllOrders extends _$AllOrders {
  RealtimeChannel? _channel;

  @override
  Future<List<Order>> build() async {
    final user = ref.watch(authStateProvider).valueOrNull;
    if (user == null) return [];

    ref.onDispose(() {
      _channel?.unsubscribe();
      _channel = null;
    });

    _subscribe(user.id);

    final repository = ref.read(orderRepositoryProvider);
    return repository.fetchOrders(user.id);
  }

  void _subscribe(String userId) {
    final client = ref.read(supabaseClientProvider);
    _channel = client
        .channel('orders_list:$userId')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'orders',
          callback: (payload) {
            ref.invalidateSelf();
          },
        )
        .subscribe();
  }
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

  /// Creates a new order from a listing.
  ///
  /// For sale: totalPrice = listing.price
  /// For rental: totalPrice = listing.price * number of days
  /// 
  /// Returns the created Order on success. Throws on failure.
  Future<Order> createOrder({
    required String listingId,
    required String sellerId,
    required double price,
    required String orderType,  // 'sale' or 'rental'
    double depositAmount = 0.0,
    DateTime? rentalStartDate,
    DateTime? rentalEndDate,
    String school = 'Smith College',
  }) async {
    state = const AsyncValue.loading();
    try {
      final user = ref.read(authStateProvider).valueOrNull;
      if (user == null) {
        throw StateError('User must be logged in to place an order');
      }
      if (user.id == sellerId) {
        throw StateError('Cannot place an order on your own listing');
      }

      // Calculate total price for rentals
      double totalPrice = price;
      if (orderType == 'rental' && 
          rentalStartDate != null && 
          rentalEndDate != null) {
        final days = rentalEndDate.difference(rentalStartDate).inDays;
        // Minimum 1 day
        final effectiveDays = days > 0 ? days : 1;
        totalPrice = price * effectiveDays;
      }

      final now = DateTime.now();
      final draft = Order(
        id: '',  // Database will generate
        listingId: listingId,
        buyerId: user.id,
        sellerId: sellerId,
        orderType: orderType,
        school: school,
        totalPrice: totalPrice,
        depositAmount: depositAmount,
        rentalStartDate: rentalStartDate,
        rentalEndDate: rentalEndDate,
        createdAt: now,
        updatedAt: now,
      );

      final created = await ref.read(orderRepositoryProvider)
          .createOrder(draft);

      // Refresh orders list so the new order appears
      ref.invalidate(allOrdersProvider);
      
      state = const AsyncValue.data(null);
      return created;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  /// Seller accepts a pending order, transitioning it to 'confirmed'.
  Future<void> acceptOrder(String orderId) async {
    state = const AsyncValue.loading();
    try {
      await ref.read(orderRepositoryProvider)
          .updateOrderStatus(orderId, 'confirmed');
      ref.invalidate(allOrdersProvider);
      ref.invalidate(orderDetailProvider(orderId));
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

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

      final isBuyer = order.buyerId == user.id;

      // Sale orders: only buyers can confirm, and it directly 
      // completes the order. Seller has no action here.
      if (order.orderType == 'sale') {
        if (!isBuyer) {
          throw StateError('Only the buyer can confirm a sale pickup');
        }
        
        await ref.read(orderRepositoryProvider)
            .updateOrderStatus(order.id, 'completed');
      } else {
        // Rental: keep dual confirmation (existing behavior)
        final role = isBuyer ? 'buyer' : 'seller';
        await ref.read(orderRepositoryProvider).confirmDelivery(
          orderId: order.id,
          byUserRole: role,
        );
      }

      // Refresh lists so status updates everywhere
      ref.invalidate(allOrdersProvider);
      ref.invalidate(orderDetailProvider(order.id));
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:smivo/core/providers/supabase_provider.dart';
import 'package:smivo/data/models/order.dart';
import 'package:smivo/data/repositories/listing_repository.dart';
import 'package:smivo/data/repositories/order_repository.dart';
import 'package:smivo/features/auth/providers/auth_provider.dart';
import 'package:smivo/features/notifications/providers/notification_provider.dart';

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

/// Fetches a single order by ID with realtime updates.
@riverpod
class OrderDetail extends _$OrderDetail {
  RealtimeChannel? _channel;

  @override
  Future<Order> build(String orderId) async {
    ref.onDispose(() {
      _channel?.unsubscribe();
      _channel = null;
    });

    _subscribe(orderId);

    final repository = ref.watch(orderRepositoryProvider);
    return repository.fetchOrder(orderId);
  }

  void _subscribe(String orderId) {
    final client = ref.read(supabaseClientProvider);
    _channel = client
        .channel('order_detail:$orderId')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'orders',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'id',
            value: orderId,
          ),
          callback: (payload) {
            ref.invalidateSelf();
          },
        )
        .subscribe();
  }
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
    String? pickupLocationId,
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

      // NOTE: price is the pre-calculated total from the UI layer.
      // For sales: listing.price. For rentals: rate × duration.
      final totalPrice = price;

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
        pickupLocationId: pickupLocationId,
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
  /// Also cancels all other pending orders for the same listing.
  /// For sale orders: listing status → 'sold' (removed from home feed).
  Future<void> acceptOrder(String orderId) async {
    state = const AsyncValue.loading();
    try {
      final repo = ref.read(orderRepositoryProvider);
      
      // 1. Fetch order to get listingId and orderType
      final order = await repo.fetchOrder(orderId);
      
      // 2. Update status to confirmed and mark others as missed
      await repo.acceptOrderAndRejectOthers(orderId, order.listingId);
      
      // 4. Sale: auto-mark listing as 'sold' (removes from home feed)
      //    Rental: keep listing active until delivery is confirmed
      if (order.orderType == 'sale') {
        await ref.read(listingRepositoryProvider)
            .updateListingStatus(order.listingId, 'sold');
      }
      
      ref.invalidate(allOrdersProvider);
      ref.invalidate(orderDetailProvider(orderId));
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
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
        // Rental: keep dual confirmation
        final role = isBuyer ? 'buyer' : 'seller';
        await ref.read(orderRepositoryProvider).confirmDelivery(
          orderId: order.id,
          byUserRole: role,
          orderType: order.orderType,
        );
        
        // After both parties confirm, activate the rental
        // (instead of completing it — rental has a return lifecycle)
        final updated = await ref.read(orderRepositoryProvider)
            .fetchOrder(order.id);
        if (updated.deliveryConfirmedByBuyer && 
            updated.deliveryConfirmedBySeller &&
            updated.rentalStatus == null) {
          await ref.read(orderRepositoryProvider)
              .updateRentalStatus(order.id, 'active');
          // NOTE: Mark listing as 'rented' once rental is active
          // This removes it from the home feed
          await ref.read(listingRepositoryProvider)
              .updateListingStatus(order.listingId, 'rented');
        }
      }

      // Refresh lists so status updates everywhere
      ref.invalidate(allOrdersProvider);
      ref.invalidate(orderDetailProvider(order.id));
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// Activates a rental order after both parties confirm delivery.
  /// Called automatically when rental delivery is confirmed.
  Future<void> activateRental(String orderId) async {
    state = const AsyncValue.loading();
    try {
      await ref.read(orderRepositoryProvider)
          .updateRentalStatus(orderId, 'active');
      ref.invalidate(allOrdersProvider);
      ref.invalidate(orderDetailProvider(orderId));
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// Buyer requests to return the rented item.
  Future<void> requestReturn(String orderId) async {
    state = const AsyncValue.loading();
    try {
      await ref.read(orderRepositoryProvider)
          .updateRentalStatus(orderId, 'return_requested');
      ref.invalidate(allOrdersProvider);
      ref.invalidate(orderDetailProvider(orderId));
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// Seller confirms the item has been returned.
  ///
  /// If deposit is 0, skips the refund step and completes the order directly.
  Future<void> confirmReturn(String orderId, {double depositAmount = 0}) async {
    state = const AsyncValue.loading();
    try {
      final repo = ref.read(orderRepositoryProvider);
      await repo.updateRentalStatus(orderId, 'returned');

      // NOTE: Skip deposit refund step when no deposit was charged
      if (depositAmount <= 0) {
        await repo.updateRentalStatus(orderId, 'deposit_refunded');
        await repo.updateOrderStatus(orderId, 'completed');
      }

      ref.invalidate(allOrdersProvider);
      ref.invalidate(orderDetailProvider(orderId));
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// Seller confirms the deposit has been refunded.
  Future<void> refundDeposit(String orderId) async {
    state = const AsyncValue.loading();
    try {
      await ref.read(orderRepositoryProvider)
          .updateRentalStatus(orderId, 'deposit_refunded');
      // Mark the order as completed after deposit refund
      await ref.read(orderRepositoryProvider)
          .updateOrderStatus(orderId, 'completed');
      ref.invalidate(allOrdersProvider);
      ref.invalidate(orderDetailProvider(orderId));
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// Updates rental reminder preferences.
  Future<void> updateReminderPreferences({
    required String orderId,
    required int daysBefore,
    required bool sendEmail,
  }) async {
    state = const AsyncValue.loading();
    try {
      await ref.read(orderRepositoryProvider).updateReminderPreferences(
        orderId: orderId,
        daysBefore: daysBefore,
        sendEmail: sendEmail,
      );
      ref.invalidate(orderDetailProvider(orderId));
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

@riverpod
Future<int> unreadOrderUpdatesCount(Ref ref) async {
  final notifications = await ref.watch(notificationListProvider.future);
  return notifications.where((n) => !n.isRead && n.actionType == 'order').length;
}

@riverpod
Future<int> unreadBuyerUpdatesCount(Ref ref) async {
  final user = ref.watch(authStateProvider).valueOrNull;
  if (user == null) return 0;
  final notifications = await ref.watch(notificationListProvider.future);
  final allOrdersList = await ref.watch(allOrdersProvider.future);
  
  int count = 0;
  for (final n in notifications) {
    if (!n.isRead && n.actionType == 'order' && n.relatedOrderId != null) {
      final order = allOrdersList.where((o) => o.id == n.relatedOrderId).firstOrNull;
      if (order != null && order.buyerId == user.id) {
        count++;
      }
    }
  }
  return count;
}

@riverpod
Future<int> unreadSellerUpdatesCount(Ref ref) async {
  final user = ref.watch(authStateProvider).valueOrNull;
  if (user == null) return 0;
  final notifications = await ref.watch(notificationListProvider.future);
  final allOrdersList = await ref.watch(allOrdersProvider.future);
  
  int count = 0;
  for (final n in notifications) {
    if (!n.isRead && n.actionType == 'order' && n.relatedOrderId != null) {
      final order = allOrdersList.where((o) => o.id == n.relatedOrderId).firstOrNull;
      if (order != null && order.sellerId == user.id) {
        count++;
      }
    }
  }
  return count;
}

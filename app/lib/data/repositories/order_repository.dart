import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:smivo/core/constants/app_constants.dart';
import 'package:smivo/core/exceptions/app_exception.dart';
import 'package:smivo/core/providers/supabase_provider.dart';
import 'package:smivo/data/models/order.dart';

part 'order_repository.g.dart';

/// Handles order-related Supabase operations.
class OrderRepository {
  const OrderRepository(this._client);

  final SupabaseClient _client;

  /// Fetches all orders where [userId] is buyer or seller.
  Future<List<Order>> fetchOrders(String userId) async {
    try {
      final data = await _client
          .from(AppConstants.tableOrders)
          .select('''
            *,
            buyer:user_profiles!buyer_id(*),
            seller:user_profiles!seller_id(*),
            listing:listings(id, title, status, rental_daily_price, rental_weekly_price, rental_monthly_price, deposit_amount, listing_cycle, images:listing_images(image_url)),
            pickup_location:pickup_locations(*)
          ''')
          .or('buyer_id.eq.$userId,seller_id.eq.$userId')
          .order('created_at', ascending: false);

      return data.map((json) => Order.fromJson(json)).where((o) {
        // 1. Always keep completed orders visible
        if (o.status == 'completed') return true;

        // 2. Buyers should always see their own history (even if cancelled/missed in past cycles)
        if (o.buyerId == userId) return true;

        // 3. For sellers, hide non-completed orders from previous listing cycles
        // This ensures a "fresh start" when a listing is relisted.
        return o.listingCycle == (o.listing?.listingCycle ?? o.listingCycle);
      }).toList();
    } on PostgrestException catch (e) {
      throw DatabaseException(e.message, e);
    }
  }

  /// Fetches a single order by [id] with full details.
  Future<Order> fetchOrder(String id) async {
    try {
      final data =
          await _client
              .from(AppConstants.tableOrders)
              .select('''
            *,
            buyer:user_profiles!buyer_id(*),
            seller:user_profiles!seller_id(*),
            listing:listings(id, title, status, rental_daily_price, rental_weekly_price, rental_monthly_price, deposit_amount, listing_cycle, images:listing_images(image_url)),
            pickup_location:pickup_locations(*)
          ''')
              .eq('id', id)
              .single();
      return Order.fromJson(data);
    } on PostgrestException catch (e) {
      throw DatabaseException(e.message, e);
    }
  }

  /// Fetches all orders for a specific listing.
  ///
  /// NOTE: Uses a two-step query to avoid PostgREST join ambiguity
  /// with multiple user_profiles foreign keys (buyer_id, seller_id).
  Future<List<Order>> fetchOrdersByListing(String listingId) async {
    try {
      // Step 1: Simple query to get order IDs for this listing
      final rawData = await _client
          .from(AppConstants.tableOrders)
          .select()
          .eq('listing_id', listingId);

      if (rawData.isEmpty) return [];

      // Step 2: Fetch with full joins using the known order IDs
      final orderIds = rawData.map((r) => r['id'] as String).toList();
      final data = await _client
          .from(AppConstants.tableOrders)
          .select('''
            *,
            buyer:user_profiles!buyer_id(*),
            seller:user_profiles!seller_id(*),
            listing:listings(id, title, status, rental_daily_price, rental_weekly_price, rental_monthly_price, deposit_amount, listing_cycle, images:listing_images(image_url)),
            pickup_location:pickup_locations(*)
          ''')
          .inFilter('id', orderIds)
          .order('created_at', ascending: false);

      return data
          .map((json) => Order.fromJson(json))
          .where((o) => o.listingCycle == o.listing?.listingCycle)
          .toList();
    } on PostgrestException catch (e) {
      throw DatabaseException(e.message, e);
    }
  }

  /// Updates the rental status of an order.
  Future<Order> updateRentalStatus(String id, String rentalStatus) async {
    try {
      final updateData = <String, dynamic>{'rental_status': rentalStatus};

      // Add timestamps for specific transitions
      if (rentalStatus == 'return_requested') {
        updateData['return_requested_at'] = DateTime.now().toIso8601String();
      } else if (rentalStatus == 'returned') {
        updateData['return_confirmed_at'] = DateTime.now().toIso8601String();
      } else if (rentalStatus == 'deposit_refunded') {
        updateData['deposit_refunded_at'] = DateTime.now().toIso8601String();
      }

      final data =
          await _client
              .from(AppConstants.tableOrders)
              .update(updateData)
              .eq('id', id)
              .select()
              .single();
      return Order.fromJson(data);
    } on PostgrestException catch (e) {
      throw DatabaseException(e.message, e);
    }
  }

  /// Creates a new order. Strips nested join fields before insert.
  Future<Order> createOrder(Order order) async {
    try {
      final orderJson =
          order.toJson()
            // Nested join fields — not columns
            ..remove('buyer')
            ..remove('seller')
            ..remove('listing')
            ..remove('pickup_location')
            // Database-generated fields — let Postgres assign these
            ..remove('id')
            ..remove('created_at')
            ..remove('updated_at');

      // Remove null fields to avoid overwriting defaults
      orderJson.removeWhere((key, value) => value == null);

      final data =
          await _client
              .from(AppConstants.tableOrders)
              .insert(orderJson)
              .select()
              .single();
      return Order.fromJson(data);
    } on PostgrestException catch (e) {
      throw DatabaseException(e.message, e);
    }
  }

  /// Accepts an order and marks all other pending orders for the same listing as missed.
  Future<void> acceptOrderAndRejectOthers(
    String orderId,
    String listingId,
  ) async {
    try {
      await _client.rpc(
        'accept_order_and_reject_others',
        params: {'p_order_id': orderId, 'p_listing_id': listingId},
      );
    } on PostgrestException catch (e) {
      throw DatabaseException(e.message, e);
    }
  }

  /// Updates an order's status (e.g. 'cancelled').
  ///
  /// [cancelledBy] — optional: the user UUID who performed the cancel.
  /// When provided, the DB trigger will notify only the OTHER party instead
  /// of both buyer and seller.
  Future<Order> updateOrderStatus(
    String id,
    String status, {
    String? cancelledBy,
  }) async {
    try {
      final payload = <String, dynamic>{'status': status};
      // NOTE: Pass cancelled_by so the trigger can notify only the other party.
      if (cancelledBy != null) {
        payload['cancelled_by'] = cancelledBy;
      }
      final data =
          await _client
              .from(AppConstants.tableOrders)
              .update(payload)
              .eq('id', id)
              .select()
              .single();
      return Order.fromJson(data);
    } on PostgrestException catch (e) {
      throw DatabaseException(e.message, e);
    }
  }

  /// Confirms delivery by [byUserRole] ('buyer' or 'seller').
  ///
  /// For rental orders: stays in 'confirmed', provider layer activates rental.
  Future<Order> confirmDelivery({
    required String orderId,
    required String byUserRole,
    required String orderType,
  }) async {
    try {
      final field =
          byUserRole == 'buyer'
              ? 'delivery_confirmed_by_buyer'
              : 'delivery_confirmed_by_seller';

      // Step 1: confirm delivery by this role
      await _client
          .from(AppConstants.tableOrders)
          .update({field: true})
          .eq('id', orderId);

      // Note: Sale orders are handled directly by confirmSaleDelivery
      // Rental orders stay in 'confirmed' — provider layer activates rental.

      return fetchOrder(orderId);
    } on PostgrestException catch (e) {
      throw DatabaseException(e.message, e);
    }
  }

  /// Confirms delivery for a sale order (buyer only) and completes it.
  Future<void> confirmSaleDelivery(String orderId) async {
    try {
      await _client
          .from(AppConstants.tableOrders)
          .update({
            'delivery_confirmed_by_buyer': true,
            'delivery_confirmed_by_seller': true,
            'status': 'completed',
          })
          .eq('id', orderId);
    } on PostgrestException catch (e) {
      throw DatabaseException(e.message, e);
    }
  }

  /// Finds an existing order by listing and buyer.
  /// Returns null if no active order exists.
  Future<Order?> fetchOrderByListingAndBuyer({
    required String listingId,
    required String buyerId,
  }) async {
    try {
      final data =
          await _client
              .from(AppConstants.tableOrders)
              .select()
              .eq('listing_id', listingId)
              .eq('buyer_id', buyerId)
              .inFilter('status', ['pending', 'confirmed', 'invalidated'])
              .maybeSingle();
      if (data == null) return null;
      return Order.fromJson(data);
    } on PostgrestException catch (e) {
      throw DatabaseException(e.message, e);
    }
  }

  /// Cancels all other pending orders for a listing when one is accepted.
  Future<void> cancelOtherPendingOrders(
    String listingId,
    String acceptedOrderId,
  ) async {
    try {
      await _client
          .from(AppConstants.tableOrders)
          .update({'status': 'cancelled'})
          .eq('listing_id', listingId)
          .eq('status', 'pending')
          .neq('id', acceptedOrderId);
    } on PostgrestException catch (e) {
      throw DatabaseException(e.message, e);
    }
  }

  /// Updates rental reminder preferences for an order.
  Future<void> updateReminderPreferences({
    required String orderId,
    required int daysBefore,
    required bool sendEmail,
  }) async {
    try {
      await _client
          .from(AppConstants.tableOrders)
          .update({
            'reminder_days_before': daysBefore,
            'reminder_email': sendEmail,
            'reminder_sent': false, // Reset so new reminder can fire
          })
          .eq('id', orderId);
    } on PostgrestException catch (e) {
      throw DatabaseException(e.message, e);
    }
  }

  /// Checks if any confirmed (non-completed, non-cancelled) order exists for a listing.
  ///
  /// Used to prevent delisting while an active transaction is in progress.
  Future<bool> hasConfirmedOrderForListing(String listingId) async {
    try {
      final data = await _client
          .from(AppConstants.tableOrders)
          .select('id')
          .eq('listing_id', listingId)
          .eq('status', 'confirmed')
          .limit(1);
      return data.isNotEmpty;
    } on PostgrestException catch (e) {
      throw DatabaseException(e.message, e);
    }
  }

  /// Cancels all pending orders for a listing (used when delisting).
  ///
  /// NOTE: Uses the cancel_pending_orders_on_delist RPC instead of a direct
  /// UPDATE so that cancelled_by is automatically set to the seller's ID.
  /// This lets the notify_order_status_change trigger send buyers a
  /// "listing removed" message rather than the generic cancel notification.
  Future<void> cancelAllPendingOrders(String listingId) async {
    try {
      await _client.rpc(
        'cancel_pending_orders_on_delist',
        params: {'p_listing_id': listingId},
      );
    } on PostgrestException catch (e) {
      throw DatabaseException(e.message, e);
    }
  }

  /// Fetches the most relevant/latest order for a given listing and buyer.
  Future<Order?> fetchLatestOrderByListingAndBuyer(
    String listingId,
    String buyerId,
  ) async {
    try {
      final data =
          await _client
              .from(AppConstants.tableOrders)
              .select()
              .eq('listing_id', listingId)
              .eq('buyer_id', buyerId)
              .order('created_at', ascending: false)
              .limit(1)
              .maybeSingle();
      if (data == null) return null;

      // Now fetch full order details using the ID
      final order = await fetchOrder(data['id'] as String);

      // If the latest order is from a previous listing cycle,
      // act as if the user has no active orders for this listing.
      if (order.listingCycle != order.listing?.listingCycle) {
        return null;
      }

      return order;
    } on PostgrestException catch (e) {
      throw DatabaseException(e.message, e);
    }
  }

  /// Checks whether [buyerId] is allowed to place an order on a listing
  /// owned by [sellerId].
  ///
  /// Returns `true` if the seller has blocked the buyer (order should be
  /// blocked), `false` otherwise.
  ///
  /// NOTE: Only checks the block relationship — deliberately does NOT check
  /// mute or freeze status, which are chat-only restrictions and must not
  /// prevent a user from placing orders.
  Future<bool> isBlockedBySeller({
    required String buyerId,
    required String sellerId,
  }) async {
    try {
      final result = await _client.rpc(
        'check_order_eligibility',
        params: {'p_buyer_id': buyerId, 'p_seller_id': sellerId},
      );
      return (result['is_blocked_by_seller'] as bool?) ?? false;
    } on PostgrestException catch (e) {
      throw DatabaseException(e.message, e);
    } catch (_) {
      // NOTE: Fail-safe: if the RPC fails for any reason, allow the order
      // attempt to proceed. The server-side RLS will be the final guard.
      return false;
    }
  }
}

@riverpod
OrderRepository orderRepository(Ref ref) =>
    OrderRepository(ref.watch(supabaseClientProvider));

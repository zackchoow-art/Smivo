import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
            listing:listings(id, title, rental_daily_price, rental_weekly_price, rental_monthly_price, deposit_amount, images:listing_images(image_url)),
            pickup_location:pickup_locations(*)
          ''')
          .or('buyer_id.eq.$userId,seller_id.eq.$userId')
          .order('created_at', ascending: false);
      return data.map((json) => Order.fromJson(json)).toList();
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
            listing:listings(id, title, rental_daily_price, rental_weekly_price, rental_monthly_price, deposit_amount, images:listing_images(image_url)),
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
            listing:listings(id, title, rental_daily_price, rental_weekly_price, rental_monthly_price, deposit_amount, images:listing_images(image_url)),
            pickup_location:pickup_locations(*)
          ''')
          .inFilter('id', orderIds)
          .order('created_at', ascending: false);
      return data.map((json) => Order.fromJson(json)).toList();
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
  Future<Order> updateOrderStatus(String id, String status) async {
    try {
      final data =
          await _client
              .from(AppConstants.tableOrders)
              .update({'status': status})
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
  /// If both parties have confirmed after this update, the order
  /// status transitions to 'completed'. The database trigger
  /// (00006_order_listing_status_sync) then updates the listing
  /// status for sale orders.
  /// Confirms delivery by [byUserRole] ('buyer' or 'seller').
  ///
  /// For sale orders: if both confirmed, transitions to 'completed'.
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

      // Step 2: fetch updated record to check both confirmations
      final current =
          await _client
              .from(AppConstants.tableOrders)
              .select(
                'delivery_confirmed_by_buyer, delivery_confirmed_by_seller, status',
              )
              .eq('id', orderId)
              .single();

      final bothConfirmed =
          current['delivery_confirmed_by_buyer'] == true &&
          current['delivery_confirmed_by_seller'] == true;

      // Step 3: only complete sale orders automatically.
      // Rental orders stay in 'confirmed' — provider layer activates rental.
      if (bothConfirmed &&
          current['status'] != 'completed' &&
          orderType == 'sale') {
        await _client
            .from(AppConstants.tableOrders)
            .update({'status': 'completed'})
            .eq('id', orderId);
      }

      return fetchOrder(orderId);
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
              .inFilter('status', ['pending', 'confirmed'])
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
  Future<void> cancelAllPendingOrders(String listingId) async {
    try {
      await _client
          .from(AppConstants.tableOrders)
          .update({'status': 'cancelled'})
          .eq('listing_id', listingId)
          .eq('status', 'pending');
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
      return fetchOrder(data['id'] as String);
    } on PostgrestException catch (e) {
      throw DatabaseException(e.message, e);
    }
  }
}

@riverpod
OrderRepository orderRepository(Ref ref) =>
    OrderRepository(ref.watch(supabaseClientProvider));

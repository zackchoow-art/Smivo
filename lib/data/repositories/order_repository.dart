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
      final data = await _client
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
  Future<List<Order>> fetchOrdersByListing(String listingId) async {
    try {
      final data = await _client
          .from(AppConstants.tableOrders)
          .select('''
            *,
            buyer:user_profiles!buyer_id(*),
            seller:user_profiles!seller_id(*)
          ''')
          .eq('listing_id', listingId)
          .order('created_at', ascending: false);
      return data.map((json) => Order.fromJson(json)).toList();
    } on PostgrestException catch (e) {
      throw DatabaseException(e.message, e);
    }
  }

  /// Updates the rental status of an order.
  Future<Order> updateRentalStatus(String id, String rentalStatus) async {
    try {
      final updateData = <String, dynamic>{
        'rental_status': rentalStatus,
      };
      
      // Add timestamps for specific transitions
      if (rentalStatus == 'return_requested') {
        updateData['return_requested_at'] = DateTime.now().toIso8601String();
      } else if (rentalStatus == 'returned') {
        updateData['return_confirmed_at'] = DateTime.now().toIso8601String();
      } else if (rentalStatus == 'deposit_refunded') {
        updateData['deposit_refunded_at'] = DateTime.now().toIso8601String();
      }
      
      final data = await _client
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
      final orderJson = order.toJson()
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

      final data = await _client
          .from(AppConstants.tableOrders)
          .insert(orderJson)
          .select()
          .single();
      return Order.fromJson(data);
    } on PostgrestException catch (e) {
      throw DatabaseException(e.message, e);
    }
  }

  /// Updates an order's status (e.g. 'cancelled').
  Future<Order> updateOrderStatus(String id, String status) async {
    try {
      final data = await _client
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
  Future<Order> confirmDelivery({
    required String orderId,
    required String byUserRole,
  }) async {
    try {
      final field = byUserRole == 'buyer'
          ? 'delivery_confirmed_by_buyer'
          : 'delivery_confirmed_by_seller';

      // Step 1: confirm delivery by this role
      await _client
          .from(AppConstants.tableOrders)
          .update({field: true})
          .eq('id', orderId);

      // Step 2: fetch updated record to check both confirmations
      final current = await _client
          .from(AppConstants.tableOrders)
          .select('delivery_confirmed_by_buyer, delivery_confirmed_by_seller, status')
          .eq('id', orderId)
          .single();

      final bothConfirmed = 
          current['delivery_confirmed_by_buyer'] == true &&
          current['delivery_confirmed_by_seller'] == true;

      // Step 3: if both confirmed and not already completed, mark complete
      if (bothConfirmed && current['status'] != 'completed') {
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
      final data = await _client
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
}

@riverpod
OrderRepository orderRepository(Ref ref) =>
    OrderRepository(ref.watch(supabaseClientProvider));

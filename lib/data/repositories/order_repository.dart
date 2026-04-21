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
            listing:listings(id, title, images:listing_images(image_url))
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
            listing:listings(id, title, images:listing_images(image_url))
          ''')
          .eq('id', id)
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
        ..remove('buyer')
        ..remove('seller')
        ..remove('listing');

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
}

@riverpod
OrderRepository orderRepository(Ref ref) =>
    OrderRepository(ref.watch(supabaseClientProvider));

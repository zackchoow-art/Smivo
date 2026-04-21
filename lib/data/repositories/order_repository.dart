import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:smivo/core/constants/app_constants.dart';
import 'package:smivo/core/exceptions/app_exception.dart';
import 'package:smivo/core/providers/supabase_provider.dart';
import 'package:smivo/data/models/order.dart';

part 'order_repository.g.dart';

/// Handles all order-related Supabase operations.
class OrderRepository {
  const OrderRepository(this._client);

  final SupabaseClient _client;

  /// Creates a new order (purchase or rental request).
  Future<Order> createOrder(Order order) async {
    try {
      final data = await _client
          .from(AppConstants.tableOrders)
          .insert(order.toJson())
          .select()
          .single();
      return Order.fromJson(data);
    } on PostgrestException catch (e) {
      throw DatabaseException(e.message, e);
    }
  }

  /// Fetches orders where the user is buyer or seller.
  Future<List<Order>> fetchOrders(String userId) async {
    try {
      final data = await _client
          .from(AppConstants.tableOrders)
          .select()
          .or('buyer_id.eq.$userId,seller_id.eq.$userId')
          .order('created_at', ascending: false);
      return data.map((json) => Order.fromJson(json)).toList();
    } on PostgrestException catch (e) {
      throw DatabaseException(e.message, e);
    }
  }

  /// Fetches a single order by [id].
  Future<Order> fetchOrder(String id) async {
    try {
      final data = await _client
          .from(AppConstants.tableOrders)
          .select()
          .eq('id', id)
          .single();
      return Order.fromJson(data);
    } on PostgrestException catch (e) {
      throw DatabaseException(e.message, e);
    }
  }

  /// Updates the status of an order.
  Future<Order> updateOrderStatus({
    required String orderId,
    required String status,
  }) async {
    try {
      final data = await _client
          .from(AppConstants.tableOrders)
          .update({'status': status, 'updated_at': DateTime.now().toIso8601String()})
          .eq('id', orderId)
          .select()
          .single();
      return Order.fromJson(data);
    } on PostgrestException catch (e) {
      throw DatabaseException(e.message, e);
    }
  }
}

@riverpod
OrderRepository orderRepository(Ref ref) =>
    OrderRepository(ref.watch(supabaseClientProvider));

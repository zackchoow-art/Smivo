import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:smivo/data/models/order.dart';

import 'package:smivo/features/auth/providers/auth_provider.dart';

import 'package:smivo/features/orders/providers/orders_provider.dart';

part 'buyer_center_provider.g.dart';

/// Fetches all orders where the current user is the buyer (realtime).
@riverpod
Future<List<Order>> buyerOrders(Ref ref) async {
  final user = ref.watch(authStateProvider).valueOrNull;
  if (user == null) return [];
  
  final allOrders = await ref.watch(allOrdersProvider.future);
  return allOrders.where((o) => o.buyerId == user.id).toList();
}

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:smivo/data/models/order.dart';
import 'package:smivo/data/repositories/order_repository.dart';
import 'package:smivo/features/auth/providers/auth_provider.dart';

part 'buyer_center_provider.g.dart';

/// Fetches all orders where the current user is the buyer.
@riverpod
Future<List<Order>> buyerOrders(Ref ref) async {
  final user = ref.watch(authStateProvider).valueOrNull;
  if (user == null) return [];
  
  final repo = ref.watch(orderRepositoryProvider);
  final allOrders = await repo.fetchOrders(user.id);
  return allOrders.where((o) => o.buyerId == user.id).toList();
}

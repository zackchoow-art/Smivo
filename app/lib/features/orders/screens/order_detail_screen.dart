import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:smivo/core/theme/theme_extensions.dart';
import 'package:smivo/features/orders/providers/orders_provider.dart';
import 'package:smivo/features/orders/screens/sale_order_detail_screen.dart';
import 'package:smivo/features/orders/screens/rental_order_detail_screen.dart';
import 'package:smivo/features/auth/providers/auth_provider.dart';

class OrderDetailScreen extends ConsumerWidget {
  const OrderDetailScreen({super.key, required this.orderId});
  final String orderId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orderAsync = ref.watch(orderDetailProvider(orderId));
    final currentUserId = ref.watch(authStateProvider).valueOrNull?.id;
    final colors = context.smivoColors;

    // Listen for global action errors
    ref.listen(orderActionsProvider, (previous, next) {
      if (next.hasError && !next.isLoading) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Action failed: ${next.error}'),
            backgroundColor: colors.error,
          ),
        );
      }
    });

    return Scaffold(
      backgroundColor: colors.surfaceContainerLowest,
      appBar: AppBar(
        backgroundColor: colors.surfaceContainerLowest,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new,
            size: 20,
            color: colors.onSurface,
          ),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Order Details',
          style: context.smivoTypo.headlineSmall.copyWith(
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: orderAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: $err')),
        data: (order) {
          if (order.orderType == 'rental') {
            return RentalOrderDetailScreen(
              order: order,
              orderId: orderId,
              currentUserId: currentUserId,
            );
          }
          return SaleOrderDetailScreen(
            order: order,
            orderId: orderId,
            currentUserId: currentUserId,
          );
        },
      ),
    );
  }
}

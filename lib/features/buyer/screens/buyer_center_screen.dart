import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:smivo/core/router/app_routes.dart';
import 'package:smivo/core/theme/app_colors.dart';
import 'package:smivo/core/theme/app_spacing.dart';
import 'package:smivo/core/theme/app_text_styles.dart';
import 'package:smivo/features/buyer/providers/buyer_center_provider.dart';

class BuyerCenterScreen extends ConsumerWidget {
  const BuyerCenterScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ordersAsync = ref.watch(buyerOrdersProvider);

    return Scaffold(
      backgroundColor: AppColors.surfaceContainerLowest,
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
          slivers: [
            // Header
            SliverPadding(
              padding: const EdgeInsets.all(24),
              sliver: SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Buyer Center',
                          style: AppTextStyles.headlineLarge.copyWith(
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Track your purchase requests and orders.',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.onSurface.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            ordersAsync.when(
              loading: () => const SliverFillRemaining(
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (e, _) => SliverFillRemaining(
                child: Center(child: Text('Error: $e')),
              ),
              data: (orders) {
                // Split into categories
                final requested = orders
                    .where((o) => o.status == 'pending')
                    .toList();
                final active = orders
                    .where((o) => o.status == 'confirmed')
                    .toList();
                final history = orders
                    .where((o) =>
                        o.status == 'completed' ||
                        o.status == 'cancelled')
                    .toList();

                if (orders.isEmpty) {
                  return SliverFillRemaining(
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.shopping_bag_outlined,
                              size: 48,
                              color: AppColors.onSurface
                                  .withValues(alpha: 0.3)),
                          const SizedBox(height: 12),
                          Text(
                            'No orders yet',
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.outlineVariant,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Browse listings to find what you need!',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.outlineVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return SliverMainAxisGroup(
                  slivers: [
                    ..._buildSection(context, 'REQUESTED', requested,
                        Icons.hourglass_top, Colors.orange),
                    ..._buildSection(context, 'ACTIVE', active,
                        Icons.local_shipping, AppColors.primary),
                    ..._buildSection(context, 'HISTORY', history,
                        Icons.history, AppColors.outlineVariant),
                  ],
                );
              },
            ),

            // Bottom padding
            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildSection(
    BuildContext context,
    String title,
    List orders,
    IconData icon,
    Color color,
  ) {
    if (orders.isEmpty) return [];

    return [
      SliverPadding(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
        sliver: SliverToBoxAdapter(
          child: Row(
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 8),
              Text(
                '$title (${orders.length})',
                style: AppTextStyles.labelSmall.copyWith(
                  color: AppColors.onSurface.withValues(alpha: 0.5),
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
      ),
      SliverPadding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        sliver: SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              final order = orders[index];
              final isMissed = order.status == 'cancelled';
              final dateStr = DateFormat('MMM d').format(order.createdAt);

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(AppSpacing.radiusMd),
                ),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: isMissed
                        ? Colors.red.withValues(alpha: 0.1)
                        : color.withValues(alpha: 0.1),
                    child: Icon(
                      isMissed ? Icons.cancel : icon,
                      color: isMissed ? Colors.red : color,
                      size: 20,
                    ),
                  ),
                  title: Text(
                    order.listing?.title ?? 'Order',
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  subtitle: Text(
                    '\$${order.totalPrice.toStringAsFixed(0)} · $dateStr',
                    style: AppTextStyles.bodySmall,
                  ),
                  trailing: _StatusChip(status: order.status),
                  onTap: () => context.pushNamed(
                    AppRoutes.orderDetail,
                    pathParameters: {'id': order.id},
                  ),
                ),
              );
            },
            childCount: orders.length,
          ),
        ),
      ),
    ];
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});
  final String status;

  @override
  Widget build(BuildContext context) {
    Color bgColor;
    Color textColor;
    String label;

    switch (status) {
      case 'pending':
        bgColor = Colors.orange.withValues(alpha: 0.1);
        textColor = Colors.orange;
        label = 'Pending';
        break;
      case 'confirmed':
        bgColor = AppColors.primary.withValues(alpha: 0.1);
        textColor = AppColors.primary;
        label = 'Active';
        break;
      case 'completed':
        bgColor = Colors.green.withValues(alpha: 0.1);
        textColor = Colors.green;
        label = 'Done';
        break;
      case 'cancelled':
        bgColor = Colors.red.withValues(alpha: 0.1);
        textColor = Colors.red;
        label = 'Missed';
        break;
      default:
        bgColor = Colors.grey.withValues(alpha: 0.1);
        textColor = Colors.grey;
        label = status;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: AppTextStyles.labelSmall.copyWith(
          color: textColor,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

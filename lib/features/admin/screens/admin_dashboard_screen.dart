import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:smivo/core/theme/theme_extensions.dart';
import 'package:smivo/features/admin/providers/admin_dashboard_provider.dart';

/// Admin dashboard with platform metrics and recent activity.
class AdminDashboardScreen extends ConsumerWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.smivoColors;
    final typo = context.smivoTypo;
    final radius = context.smivoRadius;
    final metricsState = ref.watch(adminDashboardMetricsProvider);
    final recentState = ref.watch(adminRecentOrdersProvider);

    return Scaffold(
      backgroundColor: colors.surfaceContainerLowest,
      appBar: AppBar(
        title: Text('Dashboard', style: typo.headlineSmall.copyWith(fontWeight: FontWeight.w800)),
        backgroundColor: colors.surfaceContainerLowest,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.invalidate(adminDashboardMetricsProvider);
              ref.invalidate(adminRecentOrdersProvider);
            },
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Metrics cards
            Text('Platform Overview', style: typo.headlineMedium.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 20),
            metricsState.when(
              data: (metrics) => Wrap(
                spacing: 16,
                runSpacing: 16,
                children: [
                  _MetricCard(
                    title: 'Total Users',
                    value: metrics.totalUsers.toString(),
                    icon: Icons.people,
                    color: const Color(0xFF4F46E5),
                  ),
                  _MetricCard(
                    title: 'Active Listings',
                    value: metrics.activeListings.toString(),
                    subtitle: '${metrics.totalListings} total',
                    icon: Icons.storefront,
                    color: const Color(0xFF059669),
                  ),
                  _MetricCard(
                    title: 'Pending Orders',
                    value: metrics.pendingOrders.toString(),
                    icon: Icons.hourglass_empty,
                    color: const Color(0xFFD97706),
                  ),
                  _MetricCard(
                    title: 'Completed Orders',
                    value: metrics.completedOrders.toString(),
                    subtitle: '${metrics.totalOrders} total',
                    icon: Icons.check_circle,
                    color: const Color(0xFF7C3AED),
                  ),
                  _MetricCard(
                    title: 'Schools',
                    value: metrics.totalSchools.toString(),
                    icon: Icons.school,
                    color: const Color(0xFF0891B2),
                  ),
                  _MetricCard(
                    title: 'Categories',
                    value: metrics.totalCategories.toString(),
                    icon: Icons.category,
                    color: const Color(0xFFDB2777),
                  ),
                ],
              ),
              loading: () => const Center(child: Padding(
                padding: EdgeInsets.all(32),
                child: CircularProgressIndicator(),
              )),
              error: (err, _) => _ErrorCard(message: 'Error loading metrics: $err'),
            ),

            const SizedBox(height: 40),

            // Recent activity
            Text('Recent Orders', style: typo.headlineMedium.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 20),
            recentState.when(
              data: (orders) {
                if (orders.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Text('No recent orders.', style: typo.bodyLarge.copyWith(color: colors.onSurfaceVariant)),
                    ),
                  );
                }

                return Container(
                  decoration: BoxDecoration(
                    color: colors.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(radius.md),
                    border: Border.all(color: colors.outlineVariant.withValues(alpha: 0.3)),
                  ),
                  child: Column(
                    children: orders.asMap().entries.map((entry) {
                      final order = entry.value;
                      final isLast = entry.key == orders.length - 1;
                      final status = order['status'] ?? '';
                      final createdAt = order['created_at'] != null
                          ? DateFormat('MMM d, yyyy HH:mm').format(DateTime.parse(order['created_at']))
                          : '-';

                      Color statusColor;
                      switch (status) {
                        case 'pending':
                          statusColor = const Color(0xFFD97706);
                          break;
                        case 'confirmed':
                          statusColor = colors.primary;
                          break;
                        case 'completed':
                          statusColor = const Color(0xFF059669);
                          break;
                        case 'cancelled':
                          statusColor = colors.error;
                          break;
                        default:
                          statusColor = colors.onSurfaceVariant;
                      }

                      return Column(
                        children: [
                          ListTile(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                            leading: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: statusColor.withValues(alpha: 0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                status == 'completed'
                                    ? Icons.check_circle_outline
                                    : status == 'pending'
                                        ? Icons.schedule
                                        : status == 'cancelled'
                                            ? Icons.cancel_outlined
                                            : Icons.receipt_long,
                                color: statusColor,
                                size: 20,
                              ),
                            ),
                            title: Text(
                              order['listing_title'] ?? 'Unknown Item',
                              style: typo.titleMedium.copyWith(fontWeight: FontWeight.w700, fontSize: 14),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            subtitle: Text(
                              '${order['buyer_name'] ?? 'Unknown'} • ${order['order_type'] ?? 'sale'} • $createdAt',
                              style: typo.bodySmall.copyWith(color: colors.onSurfaceVariant),
                            ),
                            trailing: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: statusColor.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                status.toUpperCase(),
                                style: typo.labelSmall.copyWith(
                                  color: statusColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          if (!isLast)
                            Divider(height: 1, indent: 20, endIndent: 20, color: colors.outlineVariant.withValues(alpha: 0.3)),
                        ],
                      );
                    }).toList(),
                  ),
                );
              },
              loading: () => const Center(child: Padding(
                padding: EdgeInsets.all(32),
                child: CircularProgressIndicator(),
              )),
              error: (err, _) => _ErrorCard(message: 'Error loading recent orders: $err'),
            ),
          ],
        ),
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String title;
  final String value;
  final String? subtitle;
  final IconData icon;
  final Color color;

  const _MetricCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.smivoColors;
    final typo = context.smivoTypo;
    final radius = context.smivoRadius;

    return Container(
      width: 220,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(radius.md),
        border: Border.all(color: colors.outlineVariant.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const Spacer(),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            value,
            style: typo.headlineMedium.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: typo.bodyMedium.copyWith(color: colors.onSurfaceVariant),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 2),
            Text(
              subtitle!,
              style: typo.bodySmall.copyWith(color: colors.onSurfaceVariant.withValues(alpha: 0.7)),
            ),
          ],
        ],
      ),
    );
  }
}

class _ErrorCard extends StatelessWidget {
  final String message;
  const _ErrorCard({required this.message});

  @override
  Widget build(BuildContext context) {
    final colors = context.smivoColors;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.error.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: colors.error),
          const SizedBox(width: 12),
          Expanded(child: Text(message, style: TextStyle(color: colors.error))),
        ],
      ),
    );
  }
}

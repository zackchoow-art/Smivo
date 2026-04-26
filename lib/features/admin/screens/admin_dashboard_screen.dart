import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smivo/core/theme/theme_extensions.dart';
import 'package:smivo/features/admin/providers/admin_dashboard_provider.dart';

class AdminDashboardScreen extends ConsumerWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.smivoColors;
    final typo = context.smivoTypo;
    final metricsState = ref.watch(adminDashboardMetricsProvider);

    return Scaffold(
      backgroundColor: colors.surfaceContainerLowest,
      appBar: AppBar(
        title: const Text('Dashboard'),
        backgroundColor: colors.surfaceContainerLowest,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.invalidate(adminDashboardMetricsProvider),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: metricsState.when(
        data: (metrics) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Platform Overview', style: typo.headlineMedium),
                const SizedBox(height: 24),
                Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  children: [
                    _MetricCard(
                      title: 'Total Users',
                      value: metrics.totalUsers.toString(),
                      icon: Icons.people,
                      color: Colors.blue,
                    ),
                    _MetricCard(
                      title: 'Active Listings',
                      value: metrics.activeListings.toString(),
                      icon: Icons.storefront,
                      color: Colors.green,
                    ),
                    _MetricCard(
                      title: 'Pending Orders',
                      value: metrics.pendingOrders.toString(),
                      icon: Icons.hourglass_empty,
                      color: Colors.orange,
                    ),
                    _MetricCard(
                      title: 'Completed Orders',
                      value: metrics.completedOrders.toString(),
                      icon: Icons.check_circle,
                      color: Colors.purple,
                    ),
                  ],
                ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(
          child: Text('Error loading dashboard: $err', style: TextStyle(color: colors.error)),
        ),
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _MetricCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.smivoColors;
    final typo = context.smivoTypo;
    final radius = context.smivoRadius;

    return Container(
      width: 240,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(radius.md),
        border: Border.all(color: colors.outlineVariant.withValues(alpha: 0.5)),
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
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: typo.labelLarge.copyWith(color: colors.onSurfaceVariant),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            value,
            style: typo.headlineLarge.copyWith(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}

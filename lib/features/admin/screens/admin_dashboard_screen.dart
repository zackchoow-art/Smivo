import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:smivo/core/router/app_routes.dart';
import 'package:smivo/core/theme/theme_extensions.dart';
import 'package:smivo/data/repositories/admin_repository.dart';
import 'package:smivo/features/admin/providers/admin_auth_provider.dart';
import 'package:smivo/features/admin/providers/admin_dashboard_provider.dart';
import 'package:smivo/features/shared/providers/status_resolver_provider.dart';

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

            // Quick actions
            Text('Quick Actions', style: typo.headlineMedium.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _QuickActionChip(
                  icon: Icons.school,
                  label: 'Manage Schools',
                  onTap: () => context.goNamed(AppRoutes.adminSchools),
                ),
                _QuickActionChip(
                  icon: Icons.category,
                  label: 'Categories',
                  onTap: () => context.goNamed(AppRoutes.adminCategories),
                ),
                _QuickActionChip(
                  icon: Icons.help,
                  label: 'FAQs',
                  onTap: () => context.goNamed(AppRoutes.adminFaqs),
                ),
                _QuickActionChip(
                  icon: Icons.book,
                  label: 'Dictionary',
                  onTap: () => context.goNamed(AppRoutes.adminDictionary),
                ),
                _QuickActionChip(
                  icon: Icons.security,
                  label: 'Roles',
                  onTap: () => context.goNamed(AppRoutes.adminRoles),
                ),
              ],
            ),

            const SizedBox(height: 40),

            // Danger Zone — only for admin/sysadmin
            Builder(
              builder: (context) {
                final adminCtx = ref.watch(adminContextProvider).valueOrNull;
                final canWrite = adminCtx?.canWrite(AdminModule.dashboard) ?? false;
                if (!canWrite) return const SizedBox.shrink();

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Danger Zone',
                      style: typo.headlineMedium.copyWith(
                        fontWeight: FontWeight.w700,
                        color: colors.error,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: colors.error.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(radius.sm),
                        border: Border.all(
                          color: colors.error.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.warning_amber_rounded,
                              color: colors.error, size: 28),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Clear All Test Data',
                                  style: typo.titleMedium.copyWith(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Delete all orders, listings, messages, chat rooms, notifications, and saved listings. System config (schools, categories, etc.) will be preserved.',
                                  style: typo.bodySmall.copyWith(
                                    color: colors.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          FilledButton.icon(
                            onPressed: () => _showClearDataDialog(context, ref),
                            icon: const Icon(Icons.delete_forever, size: 18),
                            label: const Text('Clear Data'),
                            style: FilledButton.styleFrom(
                              backgroundColor: colors.error,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                );
              },
            ),

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

                      // NOTE: Use DB-driven status colors via StatusResolver
                      final resolver = ref.watch(statusResolverProvider).valueOrNull;
                      final statusColor = resolver?.orderColor(status) ?? colors.onSurfaceVariant;

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
                                resolver?.orderLabel(status) ?? status.toUpperCase(),
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

  /// Two-step confirmation dialog for clearing all test data.
  void _showClearDataDialog(BuildContext context, WidgetRef ref) {
    final colors = context.smivoColors;
    final typo = context.smivoTypo;
    final confirmCtrl = TextEditingController();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) {
          return AlertDialog(
            title: Row(
              children: [
                Icon(Icons.warning_amber_rounded,
                    color: colors.error, size: 24),
                const SizedBox(width: 12),
                const Text('Clear Test Data'),
              ],
            ),
            content: SizedBox(
              width: 420,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'This will permanently delete:',
                    style: typo.bodyMedium
                        .copyWith(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  ...[
                    '• All orders & order evidence',
                    '• All rental extensions',
                    '• All messages & chat rooms',
                    '• All notifications',
                    '• All saved listings',
                    '• All listing images',
                    '• All listings',
                  ].map((t) => Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Text(t,
                            style: typo.bodySmall.copyWith(
                                color: colors.onSurfaceVariant)),
                      )),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF059669)
                          .withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '✓ Schools, categories, conditions, pickup locations, FAQs, dictionary, admin roles, and user accounts will NOT be deleted.',
                      style: typo.bodySmall.copyWith(
                        color: const Color(0xFF059669),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Type DELETE to confirm:',
                    style: typo.bodyMedium
                        .copyWith(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: confirmCtrl,
                    onChanged: (_) => setDialogState(() {}),
                    decoration: InputDecoration(
                      hintText: 'DELETE',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  confirmCtrl.dispose();
                  Navigator.of(ctx).pop();
                },
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: confirmCtrl.text.trim() == 'DELETE'
                    ? () async {
                        confirmCtrl.dispose();
                        Navigator.of(ctx).pop();
                        _executeClearData(context, ref);
                      }
                    : null,
                style: FilledButton.styleFrom(
                  backgroundColor: colors.error,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor:
                      colors.error.withValues(alpha: 0.3),
                ),
                child: const Text('Confirm Delete'),
              ),
            ],
          );
        },
      ),
    );
  }

  /// Executes the clear data operation with a loading overlay.
  void _executeClearData(BuildContext context, WidgetRef ref) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const AlertDialog(
        content: Row(
          children: [
            CircularProgressIndicator(),
            SizedBox(width: 24),
            Text('Clearing data…'),
          ],
        ),
      ),
    );

    try {
      final repo = ref.read(adminRepositoryProvider);
      final counts = await repo.clearTestData();

      if (context.mounted) Navigator.of(context).pop();

      // Refresh dashboard metrics
      ref.invalidate(adminDashboardMetricsProvider);
      ref.invalidate(adminRecentOrdersProvider);

      if (context.mounted) {
        final total = counts.values.fold(0, (a, b) => a + b);
        final details = counts.entries
            .where((e) => e.value > 0)
            .map((e) => '${e.key}: ${e.value}')
            .join('\n');

        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Row(
              children: [
                Icon(Icons.check_circle, color: Color(0xFF059669), size: 24),
                SizedBox(width: 12),
                Text('Data Cleared'),
              ],
            ),
            content: SizedBox(
              width: 380,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('$total records deleted.',
                      style: context.smivoTypo.bodyMedium
                          .copyWith(fontWeight: FontWeight.w700)),
                  if (details.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Text(details,
                        style: context.smivoTypo.bodySmall.copyWith(
                            color:
                                context.smivoColors.onSurfaceVariant)),
                  ],
                ],
              ),
            ),
            actions: [
              FilledButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (context.mounted) Navigator.of(context).pop();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error clearing data: $e'),
            backgroundColor: context.smivoColors.error,
          ),
        );
      }
    }
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

/// Tappable chip for quick navigation from the dashboard.
class _QuickActionChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _QuickActionChip({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.smivoColors;
    final typo = context.smivoTypo;
    final radius = context.smivoRadius;

    return Material(
      color: colors.surfaceContainerLow,
      borderRadius: BorderRadius.circular(radius.sm),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(radius.sm),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(radius.sm),
            border: Border.all(
              color: colors.outlineVariant.withValues(alpha: 0.3),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 18, color: colors.primary),
              const SizedBox(width: 8),
              Text(
                label,
                style: typo.labelLarge.copyWith(
                  color: colors.onSurface,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

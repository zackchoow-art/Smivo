import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:smivo/core/theme/theme_extensions.dart';
import 'package:smivo/features/admin/providers/admin_orders_provider.dart';
import 'package:smivo/features/shared/providers/status_resolver_provider.dart';

/// Admin screen for viewing and searching all orders.
class AdminOrdersScreen extends ConsumerStatefulWidget {
  const AdminOrdersScreen({super.key});

  @override
  ConsumerState<AdminOrdersScreen> createState() => _AdminOrdersScreenState();
}

class _AdminOrdersScreenState extends ConsumerState<AdminOrdersScreen> {
  String _searchQuery = '';
  String _statusFilter = 'all';

  @override
  Widget build(BuildContext context) {
    final colors = context.smivoColors;
    final typo = context.smivoTypo;
    final radius = context.smivoRadius;
    final ordersState = ref.watch(adminOrdersProvider);

    return Scaffold(
      backgroundColor: colors.surfaceContainerLowest,
      appBar: AppBar(
        title: Text(
          'Manage Orders',
          style: typo.headlineSmall.copyWith(fontWeight: FontWeight.w800),
        ),
        backgroundColor: colors.surfaceContainerLowest,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.invalidate(adminOrdersProvider),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: Column(
        children: [
          // Search + filter row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    onChanged: (v) => setState(() => _searchQuery = v),
                    decoration: InputDecoration(
                      hintText: 'Search by item, buyer, or seller…',
                      prefixIcon: const Icon(Icons.search, size: 20),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(radius.md),
                      ),
                      filled: true,
                      fillColor: colors.surfaceContainerLow,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                DropdownButton<String>(
                  value: _statusFilter,
                  underline: const SizedBox.shrink(),
                  items: const [
                    DropdownMenuItem(value: 'all', child: Text('All')),
                    DropdownMenuItem(value: 'pending', child: Text('Pending')),
                    DropdownMenuItem(
                      value: 'confirmed',
                      child: Text('Confirmed'),
                    ),
                    DropdownMenuItem(
                      value: 'completed',
                      child: Text('Completed'),
                    ),
                    DropdownMenuItem(
                      value: 'cancelled',
                      child: Text('Cancelled'),
                    ),
                    DropdownMenuItem(value: 'missed', child: Text('Missed')),
                  ],
                  onChanged: (v) => setState(() => _statusFilter = v ?? 'all'),
                ),
              ],
            ),
          ),
          // Order table
          Expanded(
            child: ordersState.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error:
                  (err, _) => Center(
                    child: Text(
                      'Error: $err',
                      style: TextStyle(color: colors.error),
                    ),
                  ),
              data: (orders) {
                var filtered =
                    orders.where((o) {
                      if (_statusFilter != 'all' &&
                          o['status'] != _statusFilter)
                        return false;
                      if (_searchQuery.isNotEmpty) {
                        final q = _searchQuery.toLowerCase();
                        return (o['listing_title'] ?? '')
                                .toString()
                                .toLowerCase()
                                .contains(q) ||
                            (o['buyer_name'] ?? '')
                                .toString()
                                .toLowerCase()
                                .contains(q) ||
                            (o['seller_name'] ?? '')
                                .toString()
                                .toLowerCase()
                                .contains(q);
                      }
                      return true;
                    }).toList();

                if (filtered.isEmpty) {
                  return Center(
                    child: Text(
                      'No orders found.',
                      style: typo.bodyLarge.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  );
                }

                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: SingleChildScrollView(
                    child: DataTable(
                      headingRowColor: WidgetStateProperty.all(
                        colors.surfaceContainerLow,
                      ),
                      columns: const [
                        DataColumn(label: Text('Item')),
                        DataColumn(label: Text('Buyer')),
                        DataColumn(label: Text('Seller')),
                        DataColumn(label: Text('Type')),
                        DataColumn(label: Text('Total')),
                        DataColumn(label: Text('Status')),
                        DataColumn(label: Text('Created')),
                      ],
                      rows:
                          filtered.map((o) {
                            final status = o['status'] ?? 'unknown';
                            // NOTE: Use DB-driven status colors via StatusResolver
                            final resolver =
                                ref.watch(statusResolverProvider).valueOrNull;
                            final statusColor =
                                resolver?.orderColor(status) ??
                                colors.onSurfaceVariant;

                            return DataRow(
                              cells: [
                                DataCell(
                                  SizedBox(
                                    width: 180,
                                    child: Text(
                                      o['listing_title'] ?? '-',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ),
                                DataCell(Text(o['buyer_name'] ?? '-')),
                                DataCell(Text(o['seller_name'] ?? '-')),
                                DataCell(Text(o['order_type'] ?? '-')),
                                DataCell(
                                  Text(
                                    '\$${(o['total_price'] ?? 0).toStringAsFixed(0)}',
                                  ),
                                ),
                                DataCell(
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 3,
                                    ),
                                    decoration: BoxDecoration(
                                      color: statusColor.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      resolver?.orderLabel(status) ??
                                          status.toString().toUpperCase(),
                                      style: typo.labelSmall.copyWith(
                                        color: statusColor,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                                DataCell(
                                  Text(
                                    o['created_at'] != null
                                        ? DateFormat('MM/dd/yy').format(
                                          DateTime.parse(o['created_at']),
                                        )
                                        : '-',
                                  ),
                                ),
                              ],
                            );
                          }).toList(),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

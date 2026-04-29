import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:smivo/core/theme/theme_extensions.dart';
import 'package:smivo/features/admin/providers/admin_listings_provider.dart';
import 'package:smivo/features/shared/providers/status_resolver_provider.dart';

/// Admin screen for viewing and searching all listings.
class AdminListingsScreen extends ConsumerStatefulWidget {
  const AdminListingsScreen({super.key});

  @override
  ConsumerState<AdminListingsScreen> createState() =>
      _AdminListingsScreenState();
}

class _AdminListingsScreenState extends ConsumerState<AdminListingsScreen> {
  String _searchQuery = '';
  String _statusFilter = 'all';

  @override
  Widget build(BuildContext context) {
    final colors = context.smivoColors;
    final typo = context.smivoTypo;
    final radius = context.smivoRadius;
    final listingsState = ref.watch(adminListingsProvider);

    return Scaffold(
      backgroundColor: colors.surfaceContainerLowest,
      appBar: AppBar(
        title: Text(
          'Manage Listings',
          style: typo.headlineSmall.copyWith(fontWeight: FontWeight.w800),
        ),
        backgroundColor: colors.surfaceContainerLowest,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.invalidate(adminListingsProvider),
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
                      hintText: 'Search by title, seller, or category…',
                      prefixIcon: const Icon(Icons.search, size: 20),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(radius.sm),
                      ),
                      filled: true,
                      fillColor: colors.surfaceContainerLow,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Status filter chips
                DropdownButton<String>(
                  value: _statusFilter,
                  underline: const SizedBox.shrink(),
                  items: const [
                    DropdownMenuItem(value: 'all', child: Text('All')),
                    DropdownMenuItem(value: 'active', child: Text('Active')),
                    DropdownMenuItem(value: 'sold', child: Text('Sold')),
                    DropdownMenuItem(
                      value: 'delisted',
                      child: Text('Delisted'),
                    ),
                  ],
                  onChanged: (v) => setState(() => _statusFilter = v ?? 'all'),
                ),
              ],
            ),
          ),
          // Listing table
          Expanded(
            child: listingsState.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error:
                  (err, _) => Center(
                    child: Text(
                      'Error: $err',
                      style: TextStyle(color: colors.error),
                    ),
                  ),
              data: (listings) {
                var filtered =
                    listings.where((l) {
                      if (_statusFilter != 'all' &&
                          l['status'] != _statusFilter)
                        return false;
                      if (_searchQuery.isNotEmpty) {
                        final q = _searchQuery.toLowerCase();
                        return (l['title'] ?? '')
                                .toString()
                                .toLowerCase()
                                .contains(q) ||
                            (l['category'] ?? '')
                                .toString()
                                .toLowerCase()
                                .contains(q) ||
                            (l['seller_name'] ?? '')
                                .toString()
                                .toLowerCase()
                                .contains(q);
                      }
                      return true;
                    }).toList();

                if (filtered.isEmpty) {
                  return Center(
                    child: Text(
                      'No listings found.',
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
                        DataColumn(label: Text('Title')),
                        DataColumn(label: Text('Category')),
                        DataColumn(label: Text('Price')),
                        DataColumn(label: Text('Type')),
                        DataColumn(label: Text('Status')),
                        DataColumn(label: Text('Seller')),
                        DataColumn(label: Text('Created')),
                      ],
                      rows:
                          filtered.map((l) {
                            final status = l['status'] ?? 'unknown';
                            // NOTE: Use DB-driven listing status colors via StatusResolver
                            final resolver =
                                ref.watch(statusResolverProvider).valueOrNull;
                            final statusColor =
                                resolver?.listingColor(status) ??
                                colors.onSurfaceVariant;

                            return DataRow(
                              cells: [
                                DataCell(
                                  SizedBox(
                                    width: 200,
                                    child: Text(
                                      l['title'] ?? '-',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ),
                                DataCell(Text(l['category'] ?? '-')),
                                DataCell(
                                  Text(
                                    '\$${(l['price'] ?? 0).toStringAsFixed(0)}',
                                  ),
                                ),
                                DataCell(Text(l['listing_type'] ?? '-')),
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
                                      resolver?.listingLabel(status) ??
                                          status.toString().toUpperCase(),
                                      style: typo.labelSmall.copyWith(
                                        color: statusColor,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                                DataCell(Text(l['seller_name'] ?? '-')),
                                DataCell(
                                  Text(
                                    l['created_at'] != null
                                        ? DateFormat('MM/dd/yy').format(
                                          DateTime.parse(l['created_at']),
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

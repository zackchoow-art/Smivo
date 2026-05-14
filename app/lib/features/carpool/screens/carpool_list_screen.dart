import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:smivo/core/router/app_routes.dart';
import 'package:smivo/data/models/carpool_trip.dart';
import 'package:smivo/features/carpool/providers/carpool_list_provider.dart';
import 'package:smivo/features/carpool/widgets/carpool_trip_card.dart';

class CarpoolListScreen extends ConsumerStatefulWidget {
  const CarpoolListScreen({super.key});

  @override
  ConsumerState<CarpoolListScreen> createState() => _CarpoolListScreenState();
}

class _CarpoolListScreenState extends ConsumerState<CarpoolListScreen> {
  bool sortByDeparture = true;

  // Search & filter state
  final _searchController = TextEditingController();
  String _searchQuery = '';
  DateTimeRange? _dateRange;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// Picks a date range using the Material date range picker.
  ///
  /// NOTE: firstDate is today because past trips are rarely useful;
  /// lastDate is 6 months out to cover break/holiday carpools.
  Future<void> _pickDateRange() async {
    final now = DateTime.now();
    final result = await showDateRangePicker(
      context: context,
      firstDate: now.subtract(const Duration(days: 7)),
      lastDate: now.add(const Duration(days: 180)),
      initialDateRange: _dateRange,
      helpText: 'Select departure date range',
    );

    if (result != null) {
      setState(() => _dateRange = result);
    }
  }

  /// Clears both search query and date range filters.
  void _clearAllFilters() {
    setState(() {
      _searchQuery = '';
      _searchController.clear();
      _dateRange = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tripListAsync = ref.watch(carpoolListProvider);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
        title: const Text('Carpool'),
        bottom: const TabBar(
          tabs: [
            Tab(text: 'Explore'),
            Tab(text: 'My Trips'),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(
              sortByDeparture ? Icons.schedule : Icons.access_time_filled,
            ),
            tooltip: sortByDeparture ? 'Sort by post time' : 'Sort by departure',
            onPressed: () => setState(() => sortByDeparture = !sortByDeparture),
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              context.pushNamed(AppRoutes.createCarpool);
            },
          ),
        ],
      ),
      body: TabBarView(
        children: [
          _buildExploreTab(context, theme, tripListAsync),
          _buildMyTripsTab(context, theme),
        ],
      ),
      ),
    );
  }

  Widget _buildExploreTab(BuildContext context, ThemeData theme, AsyncValue<List<CarpoolTrip>> tripListAsync) {
    return Column(
      children: [
          // Search & date filter bar
          _FilterBar(
            searchController: _searchController,
            dateRange: _dateRange,
            onSearchChanged: (value) =>
                setState(() => _searchQuery = value.trim().toLowerCase()),
            onPickDateRange: _pickDateRange,
            onClearDateRange: () => setState(() => _dateRange = null),
            onClearAll: _clearAllFilters,
            hasActiveFilters:
                _searchQuery.isNotEmpty || _dateRange != null,
            theme: theme,
          ),

          // Trip list
          Expanded(
            child: tripListAsync.when(
              data: (trips) {
                // Apply local filters before sorting
                var filtered = trips.where((trip) {
                  // Date range filter — match departure_time
                  if (_dateRange != null) {
                    final depDate = trip.departureTime.toLocal();
                    // NOTE: end of range is inclusive (full day), so add 1 day
                    final rangeEnd = _dateRange!.end
                        .add(const Duration(days: 1));
                    if (depDate.isBefore(_dateRange!.start) ||
                        depDate.isAfter(rangeEnd)) {
                      return false;
                    }
                  }

                  // Fuzzy text search — match any of the 5 target fields
                  if (_searchQuery.isNotEmpty) {
                    final q = _searchQuery;
                    final fields = [
                      trip.departureDescription ?? '',
                      trip.destinationDescription ?? '',
                      trip.departureAddress,
                      trip.destinationAddress,
                      trip.creator?.displayName ?? '',
                    ];
                    // NOTE: Any field containing the query is a match.
                    // Using lowercase comparison for case-insensitive search.
                    final matches =
                        fields.any((f) => f.toLowerCase().contains(q));
                    if (!matches) return false;
                  }

                  return true;
                }).toList();

                if (filtered.isEmpty) {
                  return RefreshIndicator(
                    onRefresh: () =>
                        ref.read(carpoolListProvider.notifier).refresh(),
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: Container(
                        height: MediaQuery.of(context).size.height -
                            kToolbarHeight -
                            kBottomNavigationBarHeight -
                            160, // account for filter bar
                        alignment: Alignment.center,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.directions_car,
                                size: 64, color: theme.dividerColor),
                            const SizedBox(height: 16),
                            Text(
                              _searchQuery.isNotEmpty || _dateRange != null
                                  ? 'No trips match your filters'
                                  : 'No carpool rides yet. Be the first to post one!',
                              style:
                                  theme.textTheme.titleMedium?.copyWith(
                                color:
                                    theme.colorScheme.onSurfaceVariant,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            if (_searchQuery.isNotEmpty ||
                                _dateRange != null) ...[
                              const SizedBox(height: 12),
                              TextButton(
                                onPressed: _clearAllFilters,
                                child: const Text('Clear Filters'),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  );
                }

                final sorted = [...filtered];
                sorted.sort((a, b) => sortByDeparture
                    ? a.departureTime.compareTo(b.departureTime)
                    : b.createdAt.compareTo(a.createdAt));

                return RefreshIndicator(
                  onRefresh: () =>
                      ref.read(carpoolListProvider.notifier).refresh(),
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: sorted.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final trip = sorted[index];
                      return CarpoolTripCard(
                        trip: trip,
                        onTap: () {
                          context.pushNamed(
                            AppRoutes.carpoolDetail,
                            pathParameters: {'id': trip.id},
                          );
                        },
                      );
                    },
                  ),
                );
              },
              loading: () =>
                  const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(error.toString(),
                        textAlign: TextAlign.center),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => ref
                          .read(carpoolListProvider.notifier)
                          .refresh(),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      );
  }

  Widget _buildMyTripsTab(BuildContext context, ThemeData theme) {
    final myTripsAsync = ref.watch(myCarpoolProvider);

    return myTripsAsync.when(
      data: (trips) {
        if (trips.isEmpty) {
          return Center(
            child: Text(
              'No trips yet.',
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          );
        }

        final pendingConfirmation = trips.where((t) => t.status == 'active' || t.status == 'inactive').toList();
        final waitingForDeparture = trips.where((t) => t.status == 'confirmed').toList();
        final pastTrips = trips.where((t) => t.status == 'departed' || t.status == 'completed' || t.status == 'cancelled').toList();

        return ListView(
          padding: const EdgeInsets.symmetric(vertical: 16),
          children: [
            if (pendingConfirmation.isNotEmpty) ...[
              _buildTripSection(context, theme, 'Pending Confirmation', pendingConfirmation),
              const SizedBox(height: 16),
            ],
            if (waitingForDeparture.isNotEmpty) ...[
              _buildTripSection(context, theme, 'Waiting for Departure', waitingForDeparture),
              const SizedBox(height: 16),
            ],
            if (pastTrips.isNotEmpty) ...[
              _buildTripSection(context, theme, 'Past Trips', pastTrips),
              const SizedBox(height: 16),
            ],
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(child: Text(error.toString())),
    );
  }

  Widget _buildTripSection(BuildContext context, ThemeData theme, String title, List<CarpoolTrip> trips) {
    return Theme(
      data: theme.copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        title: Text(
          '$title (${trips.length})',
          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        initiallyExpanded: true,
        children: trips.map((trip) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: CarpoolTripCard(
              trip: trip,
              onTap: () {
                context.pushNamed(
                  AppRoutes.carpoolDetail,
                  pathParameters: {'id': trip.id},
                );
              },
            ),
          );
        }).toList(),
      ),
    );
  }
}

/// Compact filter bar with a search field and date range chip.
///
/// NOTE: This is a stateless extraction — all state lives in the parent
/// [_CarpoolListScreenState] to keep filter logic centralized.
class _FilterBar extends StatelessWidget {
  const _FilterBar({
    required this.searchController,
    required this.dateRange,
    required this.onSearchChanged,
    required this.onPickDateRange,
    required this.onClearDateRange,
    required this.onClearAll,
    required this.hasActiveFilters,
    required this.theme,
  });

  final TextEditingController searchController;
  final DateTimeRange? dateRange;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onPickDateRange;
  final VoidCallback onClearDateRange;
  final VoidCallback onClearAll;
  final bool hasActiveFilters;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MM/dd');

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color: theme.dividerColor.withValues(alpha: 0.3),
          ),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Search bar
          TextField(
            controller: searchController,
            onChanged: onSearchChanged,
            decoration: InputDecoration(
              hintText: 'Search by location, address, or poster...',
              hintStyle: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant
                    .withValues(alpha: 0.6),
              ),
              prefixIcon: const Icon(Icons.search, size: 20),
              suffixIcon: searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, size: 18),
                      onPressed: () {
                        searchController.clear();
                        onSearchChanged('');
                      },
                    )
                  : null,
              filled: true,
              fillColor:
                  theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 10,
              ),
              isDense: true,
            ),
          ),
          const SizedBox(height: 8),

          // Date range row
          Row(
            children: [
              // Date range picker chip
              ActionChip(
                avatar: Icon(
                  Icons.date_range,
                  size: 16,
                  color: dateRange != null
                      ? theme.colorScheme.primary
                      : theme.colorScheme.onSurfaceVariant,
                ),
                label: Text(
                  dateRange != null
                      ? '${dateFormat.format(dateRange!.start)} – ${dateFormat.format(dateRange!.end)}'
                      : 'Date Range',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: dateRange != null
                        ? theme.colorScheme.primary
                        : theme.colorScheme.onSurfaceVariant,
                    fontWeight: dateRange != null
                        ? FontWeight.w600
                        : FontWeight.normal,
                  ),
                ),
                side: BorderSide(
                  color: dateRange != null
                      ? theme.colorScheme.primary
                      : theme.colorScheme.outline.withValues(alpha: 0.3),
                ),
                onPressed: onPickDateRange,
              ),

              // Clear date range
              if (dateRange != null) ...[
                const SizedBox(width: 4),
                IconButton(
                  icon: Icon(
                    Icons.close,
                    size: 16,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  visualDensity: VisualDensity.compact,
                  constraints:
                      const BoxConstraints(minWidth: 28, minHeight: 28),
                  padding: EdgeInsets.zero,
                  tooltip: 'Clear date range',
                  onPressed: onClearDateRange,
                ),
              ],

              const Spacer(),

              // Clear all filters button
              if (hasActiveFilters)
                TextButton.icon(
                  onPressed: onClearAll,
                  icon: const Icon(Icons.filter_list_off, size: 16),
                  label: const Text('Clear All'),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    visualDensity: VisualDensity.compact,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:smivo/core/theme/theme_extensions.dart';
import 'package:smivo/core/router/app_routes.dart';
import 'package:smivo/core/providers/supabase_provider.dart';
import 'package:smivo/data/models/carpool_trip.dart';
import 'package:smivo/features/carpool/providers/carpool_list_provider.dart';
import 'package:smivo/features/carpool/widgets/carpool_trip_card.dart';

class CarpoolListScreen extends ConsumerStatefulWidget {
  const CarpoolListScreen({super.key});

  @override
  ConsumerState<CarpoolListScreen> createState() => _CarpoolListScreenState();
}

class _CarpoolListScreenState extends ConsumerState<CarpoolListScreen> {
  // Search & filter state
  final _searchController = TextEditingController();
  String _searchQuery = '';
  DateTimeRange? _dateRange;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

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

  void _clearAllFilters() {
    setState(() {
      _searchQuery = '';
      _searchController.clear();
      _dateRange = null;
    });
  }

  bool _matchesFilter(CarpoolTrip trip) {
    if (_dateRange != null) {
      final depDate = trip.departureTime.toLocal();
      final rangeEnd = _dateRange!.end.add(const Duration(days: 1));
      if (depDate.isBefore(_dateRange!.start) || depDate.isAfter(rangeEnd)) {
        return false;
      }
    }

    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery;
      final fields = [
        trip.departureDescription ?? '',
        trip.destinationDescription ?? '',
        trip.departureAddress,
        trip.destinationAddress,
        trip.creator?.displayName ?? '',
      ];
      return fields.any((f) => f.toLowerCase().contains(q));
    }

    return true;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final typo = context.smivoTypo;
    final colors = context.smivoColors;
    final tripListAsync = ref.watch(carpoolListProvider);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: colors.surfaceContainerLowest,
        body: SafeArea(
          child: NestedScrollView(
            headerSliverBuilder: (context, innerBoxIsScrolled) {
              return [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Carpool',
                          style: typo.headlineLarge.copyWith(fontWeight: FontWeight.w900),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Find or offer a ride on campus.',
                          style: typo.bodyMedium.copyWith(
                            color: colors.onSurface.withValues(alpha: 0.7),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SliverPersistentHeader(
                  pinned: true,
                  delegate: _StickyTabBarDelegate(
                    const TabBar(
                      tabs: [
                        Tab(text: 'Explore'),
                        Tab(text: 'My Trips'),
                      ],
                    ),
                    theme.colorScheme.surfaceContainerLowest,
                  ),
                ),
                SliverPersistentHeader(
                  pinned: true,
                  delegate: _StickyFilterBarDelegate(
                    backgroundColor: theme.colorScheme.surface,
                    child: _FilterBar(
                      searchController: _searchController,
                      dateRange: _dateRange,
                      onSearchChanged: (value) => setState(() => _searchQuery = value.trim().toLowerCase()),
                      onPickDateRange: _pickDateRange,
                      onClearDateRange: () => setState(() => _dateRange = null),
                      onClearAll: _clearAllFilters,
                      hasActiveFilters: _searchQuery.isNotEmpty || _dateRange != null,
                      theme: theme,
                    ),
                  ),
                ),
              ];
            },
            body: TabBarView(
              children: [
                _buildExploreTab(context, theme, tripListAsync),
                _buildMyTripsTab(context, theme),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildExploreTab(BuildContext context, ThemeData theme, AsyncValue<List<CarpoolTrip>> tripListAsync) {
    return RefreshIndicator(
      onRefresh: () => ref.read(carpoolListProvider.notifier).refresh(),
      child: tripListAsync.when(
        data: (trips) {
          var filtered = trips.where(_matchesFilter).toList();

          final sorted = [...filtered];
          sorted.sort((a, b) => a.departureTime.compareTo(b.departureTime));

          return CustomScrollView(
            key: const PageStorageKey('explore_tab'),
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              if (sorted.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.directions_car, size: 64, color: theme.dividerColor),
                        const SizedBox(height: 16),
                        Text(
                          _searchQuery.isNotEmpty || _dateRange != null
                              ? 'No trips match your filters'
                              : 'No carpool rides yet. Be the first to post one!',
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        if (_searchQuery.isNotEmpty || _dateRange != null) ...[
                          const SizedBox(height: 12),
                          TextButton(
                            onPressed: _clearAllFilters,
                            child: const Text('Clear Filters'),
                          ),
                        ],
                      ],
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.all(16),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final trip = sorted[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
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
                      },
                      childCount: sorted.length,
                    ),
                  ),
                ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(error.toString(), textAlign: TextAlign.center),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.read(carpoolListProvider.notifier).refresh(),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMyTripsTab(BuildContext context, ThemeData theme) {
    final myTripsAsync = ref.watch(myCarpoolProvider);
    final currentUserId = ref.read(supabaseClientProvider).auth.currentUser?.id;

    return myTripsAsync.when(
      data: (trips) {
        final filteredTrips = trips.where(_matchesFilter).toList();
        
        bool isMemberCancelled(CarpoolTrip t) {
          if (currentUserId == null || t.creatorId == currentUserId) return false;
          try {
            final m = t.members.firstWhere((m) => m.userId == currentUserId);
            return m.status == 'cancelled' || m.status == 'rejected' || m.status == 'left';
          } catch (_) {
            return false;
          }
        }

        final pastTrips = filteredTrips.where((t) => 
            t.status == 'departed' || 
            t.status == 'arrived' ||
            t.status == 'completed' || 
            t.status == 'cancelled' ||
            isMemberCancelled(t)
        ).toList();

        final pendingConfirmation = filteredTrips.where((t) => 
            (t.status == 'active' || t.status == 'inactive') && !isMemberCancelled(t)
        ).toList();

        final waitingForDeparture = filteredTrips.where((t) => 
            t.status == 'confirmed' && !isMemberCancelled(t)
        ).toList();

        return CustomScrollView(
          key: const PageStorageKey('my_trips_tab'),
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => context.pushNamed(AppRoutes.createCarpool),
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: theme.colorScheme.primary.withValues(alpha: 0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.onPrimary.withValues(alpha: 0.2),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.directions_car,
                                color: theme.colorScheme.onPrimary,
                                size: 28,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Start a Carpool Trip',
                                    style: theme.textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.w800,
                                      color: theme.colorScheme.onPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Offer a ride and share travel expenses',
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: theme.colorScheme.onPrimary.withValues(alpha: 0.8),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Icon(
                              Icons.arrow_forward_ios,
                              color: theme.colorScheme.onPrimary.withValues(alpha: 0.8),
                              size: 16,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (trips.isEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 32),
                      child: Center(
                        child: Text(
                          'No trips yet.',
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ),
                  if (pendingConfirmation.isNotEmpty) ...[
                    _buildTripSection(context, theme, 'Pending Confirmation', pendingConfirmation, currentUserId),
                    const SizedBox(height: 16),
                  ],
                  if (waitingForDeparture.isNotEmpty) ...[
                    _buildTripSection(context, theme, 'Waiting for Departure', waitingForDeparture, currentUserId),
                    const SizedBox(height: 16),
                  ],
                  if (pastTrips.isNotEmpty) ...[
                    _buildTripSection(context, theme, 'Past Trips', pastTrips, currentUserId),
                    const SizedBox(height: 16),
                  ],
                ]),
              ),
            ),
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(child: Text(error.toString())),
    );
  }

  Widget _buildTripSection(BuildContext context, ThemeData theme, String title, List<CarpoolTrip> trips, String? currentUserId) {
    return Theme(
      data: theme.copyWith(dividerColor: Colors.transparent),
      // NOTE: PageStorageKey is required here to give the ExpansionTile its own
      // storage namespace. Without it, it reads from the same PageStorage bucket
      // as the CustomScrollView (which stores scroll offset as a double), causing
      // 'type double is not a subtype of bool?' crash in initState.
      child: ExpansionTile(
        key: PageStorageKey<String>('carpool_section_$title'),
        title: Text(
          '$title (${trips.length})',
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        initiallyExpanded: title != 'Past Trips',
        childrenPadding: EdgeInsets.zero,
        tilePadding: const EdgeInsets.symmetric(horizontal: 4),
        children: trips.map((trip) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: CarpoolTripCard(
              trip: trip,
              currentUserId: currentUserId,
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
      height: 56.0,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color: theme.dividerColor.withValues(alpha: 0.3),
          ),
        ),
      ),
      child: Row(
        children: [
          // Search bar
          Expanded(
            child: TextField(
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
                fillColor: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 0,
                ),
                isDense: true,
              ),
            ),
          ),
          const SizedBox(width: 8),

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
                  : 'Dates',
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
              constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
              padding: EdgeInsets.zero,
              tooltip: 'Clear date range',
              onPressed: onClearDateRange,
            ),
          ],
        ],
      ),
    );
  }
}

class _StickyTabBarDelegate extends SliverPersistentHeaderDelegate {
  _StickyTabBarDelegate(this.tabBar, this.backgroundColor);

  final TabBar tabBar;
  final Color backgroundColor;

  @override
  double get minExtent => tabBar.preferredSize.height;

  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: backgroundColor,
      child: tabBar,
    );
  }

  @override
  bool shouldRebuild(_StickyTabBarDelegate oldDelegate) {
    return tabBar != oldDelegate.tabBar || backgroundColor != oldDelegate.backgroundColor;
  }
}

class _StickyFilterBarDelegate extends SliverPersistentHeaderDelegate {
  _StickyFilterBarDelegate({
    required this.backgroundColor,
    required this.child,
  });

  final Color backgroundColor;
  final Widget child;

  @override
  double get minExtent => 56.0;

  @override
  double get maxExtent => 56.0;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: backgroundColor,
      child: child,
    );
  }

  @override
  bool shouldRebuild(covariant _StickyFilterBarDelegate oldDelegate) {
    return backgroundColor != oldDelegate.backgroundColor ||
           child != oldDelegate.child;
  }
}

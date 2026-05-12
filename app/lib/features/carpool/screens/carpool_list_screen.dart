import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:smivo/core/router/app_routes.dart';
import 'package:smivo/features/carpool/providers/carpool_list_provider.dart';
import 'package:smivo/features/carpool/widgets/carpool_trip_card.dart';

class CarpoolListScreen extends ConsumerStatefulWidget {
  const CarpoolListScreen({super.key});

  @override
  ConsumerState<CarpoolListScreen> createState() => _CarpoolListScreenState();
}

class _CarpoolListScreenState extends ConsumerState<CarpoolListScreen> {
  bool sortByDeparture = true;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tripListAsync = ref.watch(carpoolListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Carpool'),
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
      body: tripListAsync.when(
        data: (trips) {
          if (trips.isEmpty) {
            return RefreshIndicator(
              onRefresh: () => ref.read(carpoolListProvider.notifier).refresh(),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Container(
                  height: MediaQuery.of(context).size.height - kToolbarHeight - kBottomNavigationBarHeight,
                  alignment: Alignment.center,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.directions_car, size: 64, color: theme.dividerColor),
                      const SizedBox(height: 16),
                      Text(
                        'No carpool rides yet. Be the first to post one!',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }

          final sorted = [...trips];
          sorted.sort((a, b) => sortByDeparture
              ? a.departureTime.compareTo(b.departureTime)
              : b.createdAt.compareTo(a.createdAt));

          return RefreshIndicator(
            onRefresh: () => ref.read(carpoolListProvider.notifier).refresh(),
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: sorted.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
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
}

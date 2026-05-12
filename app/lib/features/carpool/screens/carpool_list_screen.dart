import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:smivo/core/router/app_routes.dart';
import 'package:smivo/features/carpool/providers/carpool_list_provider.dart';
import 'package:smivo/features/carpool/widgets/carpool_trip_card.dart';

class CarpoolListScreen extends ConsumerWidget {
  const CarpoolListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final tripListAsync = ref.watch(carpoolListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('拼车广场'),
        actions: [
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
                        '暂无拼车信息，快来发布第一个吧！',
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

          return RefreshIndicator(
            onRefresh: () => ref.read(carpoolListProvider.notifier).refresh(),
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: trips.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final trip = trips[index];
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
                child: const Text('重试'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

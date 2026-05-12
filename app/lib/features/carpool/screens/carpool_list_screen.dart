import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
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
              // Note: using router directly, or generic push if no route defined yet.
              // We'll use hardcoded push here since we shouldn't modify router.dart as per rules.
              // Assuming Opus will configure router properly, but we can't navigate if we don't know the route.
              // Let's use context.push('/carpool/create') assuming that will be the route, or generic navigator.
              // Since router config is by Opus, we should probably use a placeholder or generic named route.
              // I will use context.pushNamed('createCarpool') or similar.
              // Actually, without modifying router, maybe GoRouter.of(context).push('/create_carpool');
              // I will just use Navigator for now to avoid go_router path issues if not configured, or GoRouter.
              context.push('/create_carpool');
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
                    context.push('/carpool_detail', extra: trip.id);
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

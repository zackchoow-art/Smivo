import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smivo/core/theme/theme_extensions.dart';
import 'package:smivo/features/settings/providers/contribution_provider.dart';
import 'package:smivo/features/profile/providers/profile_provider.dart';
import 'package:intl/intl.dart';

class MyContributionsScreen extends ConsumerWidget {
  const MyContributionsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.smivoColors;
    final typo = context.smivoTypo;
    final userProfile = ref.watch(profileProvider).value;
    final contributionsAsync = ref.watch(myContributionsProvider);

    final score = userProfile?.contributionScore ?? 0;
    final level = userProfile?.contributionLevel ?? 1;
    final toNextLevel = pointsToNextLevel(score);

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        title: Text('My Contributions', style: typo.titleMedium),
        backgroundColor: colors.surface,
        elevation: 0,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [colors.primary, colors.primary.withAlpha(200)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: colors.primary.withAlpha(50),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                Text(
                  '🎖️ Lv.$level',
                  style: typo.headlineMedium.copyWith(color: Colors.white),
                ),
                const SizedBox(height: 8),
                Text(
                  '$score Points',
                  style: typo.headlineSmall.copyWith(color: Colors.white70),
                ),
                const SizedBox(height: 16),
                if (level < 5)
                  Text(
                    '$toNextLevel points to Lv.${level + 1}',
                    style: typo.labelSmall.copyWith(color: Colors.white70),
                  )
                else
                  Text(
                    'Max Level Reached!',
                    style: typo.labelSmall.copyWith(color: Colors.white70),
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Text('Contribution History', style: typo.titleMedium),
          ),
          Expanded(
            child: contributionsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error: $e')),
              data: (entries) {
                if (entries.isEmpty) {
                  return Center(
                    child: Text(
                      'No contributions yet.\nStart by reporting bugs or suggesting features!',
                      textAlign: TextAlign.center,
                      style: typo.bodyMedium.copyWith(color: colors.onSurfaceVariant),
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: entries.length,
                  itemBuilder: (context, index) {
                    final entry = entries[index];
                    final isPositive = entry.points > 0;
                    final date = entry.createdAt != null 
                        ? DateFormat('MMM d, yyyy').format(entry.createdAt!)
                        : '';

                    return ListTile(
                      title: Text(entry.description, style: typo.bodyLarge),
                      subtitle: Text(date, style: typo.labelSmall.copyWith(color: colors.onSurfaceVariant)),
                      trailing: Text(
                        '${isPositive ? '+' : ''}${entry.points}',
                        style: typo.titleMedium.copyWith(
                          color: isPositive ? Colors.green : Colors.red,
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

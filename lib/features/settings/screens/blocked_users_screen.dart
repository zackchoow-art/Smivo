import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smivo/core/theme/theme_extensions.dart';
import 'package:smivo/core/providers/moderation_provider.dart';
import 'package:smivo/shared/widgets/collapsing_title_app_bar.dart';
import 'package:smivo/shared/widgets/content_width_constraint.dart';
import 'package:cached_network_image/cached_network_image.dart';

class BlockedUsersScreen extends ConsumerWidget {
  const BlockedUsersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.smivoColors;
    final typo = context.smivoTypo;
    final radius = context.smivoRadius;

    final blockedUsersAsync = ref.watch(blockedUsersListProvider);

    return Scaffold(
      backgroundColor: colors.surfaceContainerLowest,
      body: Center(
        child: ContentWidthConstraint(
          maxWidth: 640,
          child: CustomScrollView(
            slivers: [
              const CollapsingTitleAppBar(
                title: 'Blocked Users',
                subtitle: 'Manage users you have blocked from\nviewing or interacting with.',
              ),
              blockedUsersAsync.when(
                loading: () => const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator()),
                ),
                error: (err, stack) => SliverFillRemaining(
                  child: Center(
                    child: Text('Error loading blocked users.',
                        style: typo.bodyMedium.copyWith(color: colors.error)),
                  ),
                ),
                data: (users) {
                  if (users.isEmpty) {
                    return SliverFillRemaining(
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.person_off_outlined,
                                size: 64, color: colors.onSurfaceVariant.withValues(alpha: 0.5)),
                            const SizedBox(height: 16),
                            Text('No blocked users.',
                                style: typo.titleMedium.copyWith(color: colors.onSurfaceVariant)),
                          ],
                        ),
                      ),
                    );
                  }

                  return SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final user = users[index];
                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            decoration: BoxDecoration(
                              color: colors.surfaceContainerLowest,
                              borderRadius: BorderRadius.circular(radius.card),
                              border: Border.all(color: colors.dividerColor),
                            ),
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              leading: CircleAvatar(
                                radius: 24,
                                backgroundColor: colors.surfaceContainerHigh,
                                backgroundImage: user.avatarUrl != null
                                    ? CachedNetworkImageProvider(user.avatarUrl!)
                                    : null,
                                child: user.avatarUrl == null
                                    ? Icon(Icons.person, color: colors.onSurfaceVariant)
                                    : null,
                              ),
                              title: Text(user.displayName ?? 'Unknown User',
                                  style: typo.titleMedium.copyWith(fontWeight: FontWeight.w700)),
                              subtitle: Text(user.school,
                                  style: typo.bodySmall.copyWith(color: colors.onSurfaceVariant)),
                              trailing: TextButton(
                                onPressed: () async {
                                  await ref.read(moderationActionsProvider.notifier).unblockUser(user.id);
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('${user.displayName ?? 'User'} unblocked.')),
                                    );
                                  }
                                },
                                style: TextButton.styleFrom(
                                  foregroundColor: colors.primary,
                                ),
                                child: const Text('Unblock'),
                              ),
                            ),
                          );
                        },
                        childCount: users.length,
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

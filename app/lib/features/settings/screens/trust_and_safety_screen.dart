import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:smivo/core/providers/moderation_provider.dart';
import 'package:smivo/core/theme/theme_extensions.dart';
import 'package:smivo/features/settings/widgets/flippable_report_card.dart';

class TrustAndSafetyScreen extends ConsumerWidget {
  const TrustAndSafetyScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.smivoColors;
    final typo = context.smivoTypo;
    final radius = context.smivoRadius;

    final reportsAsync = ref.watch(userReportsProvider);
    final blockedUsersAsync = ref.watch(blockedUsersListProvider);

    return Scaffold(
      backgroundColor: colors.surfaceContainerLowest,
      appBar: AppBar(
        title: Text(
          'Trust & Safety',
          style: typo.headlineSmall.copyWith(fontWeight: FontWeight.w600),
        ),
        backgroundColor: colors.surfaceContainerLowest,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new,
            size: 20,
            color: colors.onSurface,
          ),
          onPressed: () => context.pop(),
        ),
      ),
      body: SelectionArea(
        child: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  // 1. Blocked Users Section
                  Theme(
                    data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                    child: ExpansionTile(
                      initiallyExpanded: false,
                      title: Text(
                        'Blocked Users',
                        style: typo.titleMedium.copyWith(color: colors.primary),
                      ),
                      iconColor: colors.primary,
                      collapsedIconColor: colors.onSurfaceVariant,
                      tilePadding: const EdgeInsets.symmetric(horizontal: 8),
                      childrenPadding: const EdgeInsets.only(top: 8, bottom: 16),
                      children: [
                        blockedUsersAsync.when(
                          loading: () => const Center(child: CircularProgressIndicator()),
                          error: (err, stack) => Text('Failed to load blocked users', style: typo.bodyMedium.copyWith(color: colors.error)),
                          data: (users) {
                            if (users.isEmpty) {
                              return Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Text('No blocked users.', style: typo.bodyMedium.copyWith(color: colors.onSurfaceVariant)),
                              );
                            }
                            return Column(
                              children: users.map((user) => Container(
                                margin: const EdgeInsets.only(bottom: 12),
                                decoration: BoxDecoration(
                                  color: colors.surface,
                                  borderRadius: BorderRadius.circular(radius.card),
                                  border: Border.all(color: colors.outlineVariant),
                                ),
                                child: ListTile(
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                  leading: CircleAvatar(
                                    radius: 24,
                                    backgroundColor: colors.surfaceContainerHigh,
                                    backgroundImage: user.avatarUrl != null ? CachedNetworkImageProvider(user.avatarUrl!) : null,
                                    child: user.avatarUrl == null ? Icon(Icons.person, color: colors.onSurfaceVariant) : null,
                                  ),
                                  title: Text(
                                    user.displayName ?? 'Unknown User',
                                    style: typo.titleMedium.copyWith(fontWeight: FontWeight.w700),
                                  ),
                                  subtitle: Text(
                                    user.school,
                                    style: typo.bodySmall.copyWith(color: colors.onSurfaceVariant),
                                  ),
                                  trailing: TextButton(
                                    onPressed: () async {
                                      await ref.read(moderationActionsProvider.notifier).unblockUser(user.id);
                                      if (context.mounted) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(content: Text('${user.displayName ?? 'User'} unblocked.')),
                                        );
                                      }
                                    },
                                    style: TextButton.styleFrom(foregroundColor: colors.primary),
                                    child: const Text('Unblock'),
                                  ),
                                ),
                              )).toList(),
                            );
                          },
                        ),
                      ],
                    ),
                  ),

                  // Spacer
                  const SizedBox(height: 16),

                  // 2. Reported Content Sections
                  reportsAsync.when(
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (err, stack) => Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Text(
                        'Failed to load reports: ${err.toString()}',
                        style: typo.bodyMedium.copyWith(color: colors.error),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    data: (reports) {
                      if (reports.isEmpty) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 32.0),
                          child: Column(
                            children: [
                              Icon(Icons.shield_outlined, size: 64, color: colors.outlineVariant),
                              const SizedBox(height: 16),
                              Text(
                                'No Reported Content',
                                style: typo.titleMedium.copyWith(color: colors.onSurfaceVariant),
                              ),
                            ],
                          ),
                        );
                      }

                      final userReports = reports.where((r) => r.listingId == null).toList();
                      final listingReports = reports.where((r) => r.listingId != null).toList();

                      return Column(
                        children: [
                          if (userReports.isNotEmpty)
                            Theme(
                              data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                              child: ExpansionTile(
                                initiallyExpanded: true,
                                title: Text(
                                  'Reported Users (${userReports.length})',
                                  style: typo.titleMedium.copyWith(color: colors.primary),
                                ),
                                iconColor: colors.primary,
                                collapsedIconColor: colors.onSurfaceVariant,
                                tilePadding: const EdgeInsets.symmetric(horizontal: 8),
                                childrenPadding: const EdgeInsets.only(top: 8, bottom: 16),
                                children: userReports.map(
                                  (report) => Padding(
                                    padding: const EdgeInsets.only(bottom: 12),
                                    child: FlippableReportCard(report: report),
                                  ),
                                ).toList(),
                              ),
                            ),
                          if (listingReports.isNotEmpty)
                            Theme(
                              data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                              child: ExpansionTile(
                                initiallyExpanded: true,
                                title: Text(
                                  'Reported Listings (${listingReports.length})',
                                  style: typo.titleMedium.copyWith(color: colors.primary),
                                ),
                                iconColor: colors.primary,
                                collapsedIconColor: colors.onSurfaceVariant,
                                tilePadding: const EdgeInsets.symmetric(horizontal: 8),
                                childrenPadding: const EdgeInsets.only(top: 8, bottom: 16),
                                children: listingReports.map(
                                  (report) => Padding(
                                    padding: const EdgeInsets.only(bottom: 12),
                                    child: FlippableReportCard(report: report),
                                  ),
                                ).toList(),
                              ),
                            ),
                        ],
                      );
                    },
                  ),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

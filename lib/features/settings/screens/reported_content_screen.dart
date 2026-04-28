import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:smivo/core/providers/moderation_provider.dart';
import 'package:smivo/core/theme/theme_extensions.dart';

class ReportedContentScreen extends ConsumerWidget {
  const ReportedContentScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.smivoColors;
    final typo = context.smivoTypo;
    final radius = context.smivoRadius;

    final reportsAsync = ref.watch(userReportsProvider);

    return Scaffold(
      backgroundColor: colors.surfaceContainerLowest,
      appBar: AppBar(
        title: Text(
          'Reported Content',
          style: typo.headlineSmall.copyWith(fontWeight: FontWeight.w600),
        ),
        backgroundColor: colors.surfaceContainerLowest,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, size: 20, color: colors.onSurface),
          onPressed: () => context.pop(),
        ),
      ),
      body: reportsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Text(
              'Failed to load reports: ${err.toString()}',
              style: typo.bodyMedium.copyWith(color: colors.error),
              textAlign: TextAlign.center,
            ),
          ),
        ),
        data: (reports) {
          if (reports.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.shield_outlined, size: 64, color: colors.outline),
                  const SizedBox(height: 16),
                  Text(
                    'No Reported Content',
                    style: typo.titleMedium.copyWith(color: colors.onSurfaceVariant),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'You have not reported any users or listings.',
                    style: typo.bodySmall.copyWith(color: colors.onSurfaceVariant),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: reports.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final report = reports[index];
              final isListingReport = report.listingId != null;
              final targetName = isListingReport
                  ? (report.listing?.title ?? 'Unknown Listing')
                  : (report.reportedUser?.displayName ?? 'Unknown User');
              
              final displayStatus = report.status.substring(0, 1).toUpperCase() + report.status.substring(1);

              return Container(
                decoration: BoxDecoration(
                  color: colors.surface,
                  borderRadius: BorderRadius.circular(radius.lg),
                  border: Border.all(color: colors.outlineVariant),
                ),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          isListingReport ? Icons.storefront : Icons.person,
                          size: 20,
                          color: colors.primary,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            isListingReport ? 'Reported Listing' : 'Reported User',
                            style: typo.labelLarge.copyWith(color: colors.primary),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: report.status == 'pending' ? colors.errorContainer : colors.secondaryContainer,
                            borderRadius: BorderRadius.circular(radius.sm),
                          ),
                          child: Text(
                            displayStatus,
                            style: typo.labelSmall.copyWith(
                              color: report.status == 'pending' ? colors.error : colors.onSecondaryContainer,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      targetName,
                      style: typo.titleMedium.copyWith(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Reason: ${report.reason}',
                      style: typo.bodyMedium.copyWith(color: colors.onSurfaceVariant),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Reported on: ${report.createdAt.toLocal().toString().split(' ')[0]}',
                      style: typo.labelSmall.copyWith(color: colors.outline),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}

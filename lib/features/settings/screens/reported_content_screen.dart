import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:smivo/core/providers/moderation_provider.dart';
import 'package:smivo/core/theme/theme_extensions.dart';
import 'package:smivo/features/settings/widgets/flippable_report_card.dart';

class ReportedContentScreen extends ConsumerWidget {
  const ReportedContentScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.smivoColors;
    final typo = context.smivoTypo;

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

          final userReports = reports.where((r) => r.listingId == null).toList();
          final listingReports = reports.where((r) => r.listingId != null).toList();

          return ListView(
            padding: const EdgeInsets.all(16),
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
                    children: userReports
                        .map((report) => Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: FlippableReportCard(report: report),
                            ))
                        .toList(),
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
                    children: listingReports
                        .map((report) => Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: FlippableReportCard(report: report),
                            ))
                        .toList(),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smivo/core/theme/breakpoints.dart';
import 'package:smivo/core/theme/theme_extensions.dart';
import 'package:smivo/features/listing/providers/saved_listing_provider.dart';
import 'package:smivo/features/listing/widgets/ikea_saved_listing_card.dart';
import 'package:smivo/features/listing/widgets/saved_listing_card.dart';
import 'package:smivo/shared/widgets/collapsing_title_app_bar.dart';
import 'package:smivo/shared/widgets/content_width_constraint.dart';
import 'package:smivo/shared/widgets/responsive_grid.dart';
import 'package:smivo/data/models/saved_listing.dart';

class SavedListingsScreen extends ConsumerStatefulWidget {
  const SavedListingsScreen({super.key});

  @override
  ConsumerState<SavedListingsScreen> createState() => _SavedListingsScreenState();
}

class _SavedListingsScreenState extends ConsumerState<SavedListingsScreen> {
  final Map<String, bool> _expandedSections = {
    'Active': true,
    'Delisted': true,
  };

  @override
  Widget build(BuildContext context) {
    final savedAsync = ref.watch(mySavedListingsProvider);
    final colors = context.smivoColors;
    final typo = context.smivoTypo;

    return Scaffold(
      backgroundColor: colors.surfaceContainerLowest,
      body: SafeArea(
        top: false,
        bottom: false,
        child: RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(mySavedListingsProvider);
            await ref.read(mySavedListingsProvider.future);
          },
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              const CollapsingTitleAppBar(
                title: 'Saved Items',
                subtitle: 'Items you have bookmarked for later.',
              ),
              savedAsync.when(
                loading: () => const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator()),
                ),
                error: (e, _) => SliverFillRemaining(
                  child: Center(child: Text('Error: $e')),
                ),
                data: (savedItems) {
                  if (savedItems.isEmpty) {
                    return SliverFillRemaining(
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.bookmark_outline,
                                size: 48,
                                color: colors.onSurface.withValues(alpha: 0.3)),
                            const SizedBox(height: 12),
                            Text('No saved items yet',
                                style: typo.bodyMedium
                                    .copyWith(color: colors.outlineVariant)),
                            const SizedBox(height: 8),
                            Text('Explore the market and save what you like!',
                                style: typo.bodySmall
                                    .copyWith(color: colors.outlineVariant)),
                          ],
                        ),
                      ),
                    );
                  }

                  final active = savedItems
                      .where((item) => item.listing?.status == 'active')
                      .toList();
                  final inactive = savedItems
                      .where((item) => item.listing?.status != 'active')
                      .toList();

                  return SliverMainAxisGroup(
                    slivers: [
                      ..._buildSection(
                        'Active',
                        active,
                        Icons.bookmark,
                        colors.primary,
                      ),
                      ..._buildSection(
                        'Delisted',
                        inactive,
                        Icons.bookmark_border,
                        colors.outlineVariant,
                      ),
                    ],
                  );
                },
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 100)),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildSection(
    String title,
    List<SavedListing> items,
    IconData icon,
    Color color,
  ) {
    if (items.isEmpty) return [];
    
    final colors = context.smivoColors;
    final typo = context.smivoTypo;
    final radius = context.smivoRadius;
    final isExpanded = _expandedSections[title] ?? true;
    final isIkea = colors.primary == const Color(0xFF004181);

    return [
      SliverPadding(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
        sliver: SliverToBoxAdapter(
          child: InkWell(
            borderRadius: BorderRadius.circular(radius.sm),
            onTap: () => setState(() => _expandedSections[title] = !isExpanded),
            child: Row(
              children: [
                Icon(icon, size: 16, color: color),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '$title (${items.length})',
                    style: typo.titleMedium.copyWith(
                      color: colors.onSurface,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Icon(
                  isExpanded
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                  size: 20,
                  color: colors.onSurface.withValues(alpha: 0.5),
                ),
              ],
            ),
          ),
        ),
      ),
      if (isExpanded)
        Builder(
          builder: (context) {
            final sw = MediaQuery.of(context).size.width;
            final useConstraint = Breakpoints.isDesktop(sw);
            final maxW = isIkea ? 1280.0 : 960.0;
            
            final sliver = SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              sliver: isIkea
                  ? SliverResponsiveGrid(
                      itemCount: items.length,
                      mobileColumns: 2,
                      tabletColumns: 3,
                      desktopColumns: 4,
                      crossAxisSpacing: 24,
                      mainAxisSpacing: 12,
                      childAspectRatio: 0.72,
                      itemBuilder: (context, index) {
                        return IkeaSavedListingCard(savedListing: items[index]);
                      },
                    )
                  : SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: SavedListingCard(savedListing: items[index]),
                          );
                        },
                        childCount: items.length,
                      ),
                    ),
            );

            return useConstraint
                ? SliverToBoxAdapter(
                    child: ContentWidthConstraint(
                      maxWidth: maxW,
                      child: CustomScrollView(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        slivers: [sliver],
                      ),
                    ),
                  )
                : sliver;
          },
        ),
    ];
  }
}

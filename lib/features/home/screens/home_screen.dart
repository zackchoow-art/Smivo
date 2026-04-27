import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smivo/core/providers/theme_provider.dart';
import 'package:smivo/core/theme/breakpoints.dart';
import 'package:smivo/core/theme/theme_extensions.dart';
import 'package:smivo/core/theme/theme_variant.dart';
import 'package:smivo/features/home/providers/home_provider.dart';
import 'package:smivo/features/home/widgets/compact_listing_card.dart';
import 'package:smivo/features/home/widgets/featured_listing_card.dart';
import 'package:smivo/features/home/widgets/home_category_chips.dart';
import 'package:smivo/features/home/widgets/home_header.dart';
import 'package:smivo/features/home/widgets/home_search_bar.dart';
import 'package:smivo/features/home/widgets/ikea_featured_listing_card.dart';
import 'package:smivo/features/home/widgets/ikea_grid_listing_card.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final listingsAsync = ref.watch(homeListingsProvider);
    final themeVariant = ref.watch(themeNotifierProvider);
    final colors = context.smivoColors;
    final typo = context.smivoTypo;

    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            try {
              ref.invalidate(homeListingsProvider);
              await ref.read(homeListingsProvider.future);
            } catch (e) {
              // Silently handle error here, the AsyncValue.error will
              // be caught by ref.watch(homeListingsProvider) and show in UI.
            }
          },
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
            const SliverToBoxAdapter(child: SizedBox(height: 16)),
            const SliverToBoxAdapter(child: HomeHeader()),
            const SliverToBoxAdapter(child: SizedBox(height: 8)),
            SliverPersistentHeader(
              pinned: true,
              delegate: _StickySearchBarDelegate(
                backgroundColor: colors.background,
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 8)),
            const SliverToBoxAdapter(child: HomeCategoryChips()),
            const SliverToBoxAdapter(child: SizedBox(height: 24)),
            
            listingsAsync.when(
              loading: () => const SliverFillRemaining(
                hasScrollBody: false,
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (error, stack) => SliverFillRemaining(
                hasScrollBody: false,
                child: Center(
                  child: Text(
                    'Error loading listings',
                    style: typo.bodyMedium.copyWith(color: colors.error),
                  ),
                ),
              ),
              data: (listings) {
                if (listings.isEmpty) {
                  return SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(
                      child: Text(
                        'No listings found.',
                        style: typo.bodyLarge,
                      ),
                    ),
                  );
                }

                // NOTE: IKEA theme uses a different layout structure:
                // first 3 items as full-width featured cards, then a
                // responsive grid for the rest. Teal theme keeps the
                // original single-column list.
                if (themeVariant == SmivoThemeVariant.ikea) {
                  return _buildIkeaLayout(context, listings);
                }

                return _buildTealLayout(listings);
              },
            ),
            
          ],
          ),
        ),
      ),
    );
  }

  /// Teal theme: original single-column layout.
  /// First 3 = FeaturedListingCard, rest = CompactListingCard.
  Widget _buildTealLayout(List listings) {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            // First 3 items are featured, the rest are compact
            if (index < 3 && index < listings.length) {
              return FeaturedListingCard(
                listing: listings[index],
              );
            } else {
              return CompactListingCard(
                listing: listings[index],
              );
            }
          },
          childCount: listings.length,
        ),
      ),
    );
  }

  /// IKEA theme: featured cards + responsive grid.
  /// First 3 = IkeaFeaturedListingCard (full-width),
  /// from item 4 = IkeaGridListingCard (2/3/4 columns by screen width).
  Widget _buildIkeaLayout(BuildContext context, List listings) {
    final featuredCount = listings.length < 3 ? listings.length : 3;
    final gridItems = listings.length > 3 ? listings.sublist(3) : [];

    return SliverMainAxisGroup(
      slivers: [
        // ── Featured cards (full-width, single column) ─────────
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) => IkeaFeaturedListingCard(
                listing: listings[index],
              ),
              childCount: featuredCount,
            ),
          ),
        ),

        // ── Grid cards (responsive columns) ────────────────────
        if (gridItems.isNotEmpty)
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            // NOTE: Must use SliverLayoutBuilder (not LayoutBuilder)
            // because this widget sits in a sliver context.
            // LayoutBuilder is a RenderBox and causes assertion
            // failures / Duplicate GlobalKey errors in sliver trees.
            sliver: SliverLayoutBuilder(
              builder: (context, constraints) {
                final width = constraints.crossAxisExtent;
                // NOTE: Dynamic column count based on available width.
                // `width` is already the content area inside padding.
                final crossAxisCount = Breakpoints.isDesktop(width + 32)
                    ? 4
                    : Breakpoints.isTablet(width + 32)
                        ? 3
                        : 2;

                return SliverGrid(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    // NOTE: childAspectRatio controls the card's
                    // height relative to width. Lower values = taller
                    // cards. 0.68 accommodates square image + info
                    // section comfortably.
                    childAspectRatio: 0.68,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => IkeaGridListingCard(
                      listing: gridItems[index],
                    ),
                    childCount: gridItems.length,
                  ),
                );
              },
            ),
          ),

        // Bottom spacing so last grid row isn't flush with nav bar
        const SliverToBoxAdapter(
          child: SizedBox(height: 24),
        ),
      ],
    );
  }
}

class _StickySearchBarDelegate extends SliverPersistentHeaderDelegate {
  _StickySearchBarDelegate({required this.backgroundColor});

  final Color backgroundColor;

  @override
  double get minExtent => 64.0;
  
  @override
  double get maxExtent => 64.0;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: backgroundColor,
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      alignment: Alignment.center,
      child: const HomeSearchBar(),
    );
  }

  @override
  bool shouldRebuild(covariant _StickySearchBarDelegate oldDelegate) {
    return oldDelegate.backgroundColor != backgroundColor;
  }
}

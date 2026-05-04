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
import 'package:smivo/core/providers/heartbeat_provider.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Initialize heartbeat manager (only active when user is logged in)
    ref.watch(heartbeatManagerProvider);

    final listingsAsync = ref.watch(homeListingsProvider);
    final themeVariant = ref.watch(themeProvider);
    final colors = context.smivoColors;
    final typo = context.smivoTypo;

    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
              final contentWidth = 800.0;
              final screenWidth = constraints.maxWidth;
              // Calculate horizontal padding to constrain content to max 800px
              final paddingX = screenWidth > contentWidth
                  ? (screenWidth - contentWidth) / 2
                  : 0.0;
              
              final content = RefreshIndicator(
                onRefresh: () async {
                  try {
                    ref.invalidate(homeListingsProvider);
                    await ref.read(homeListingsProvider.future);
                  } catch (e) {
                    // Ignore errors, UI will handle
                  }
                },
                child: CustomScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  slivers: [
                    const SliverToBoxAdapter(child: SizedBox(height: 16)),
                    SliverPadding(
                      padding: EdgeInsets.symmetric(horizontal: paddingX),
                      sliver: const SliverToBoxAdapter(child: HomeHeader()),
                    ),
                    const SliverToBoxAdapter(child: SizedBox(height: 16)),
                    SliverPadding(
                      padding: EdgeInsets.symmetric(horizontal: paddingX),
                      sliver: SliverPersistentHeader(
                        pinned: true,
                        delegate: _StickySearchBarDelegate(
                          backgroundColor: colors.background,
                        ),
                      ),
                    ),
                    const SliverToBoxAdapter(child: SizedBox(height: 16)),
                    // Category chips stay full width
                    const SliverToBoxAdapter(child: HomeCategoryChips()),
                    const SliverToBoxAdapter(child: SizedBox(height: 24)),
                    SliverPadding(
                      padding: EdgeInsets.symmetric(horizontal: paddingX),
                      sliver: listingsAsync.when(
                        loading:
                            () => const SliverFillRemaining(
                              hasScrollBody: false,
                              child: Center(child: CircularProgressIndicator()),
                            ),
                        error:
                            (error, stack) => SliverFillRemaining(
                              hasScrollBody: false,
                              child: Center(
                                child: Text(
                                  'Error loading listings',
                                  style: typo.bodyMedium.copyWith(
                                    color: colors.error,
                                  ),
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

                          if (themeVariant == SmivoThemeVariant.ikea) {
                            return _buildIkeaLayout(context, listings);
                          }

                          return _buildTealLayout(listings);
                        },
                      ),
                    ),
                  ],
                ),
              );

              return content;
            },
          ),
        ),
      );
    }

  /// Teal theme: original single-column layout, but responsive on tablet/desktop.
  /// First 4 = FeaturedListingCard, rest = CompactListingCard.
  Widget _buildTealLayout(List listings) {
    final featuredCount = listings.length < 4 ? listings.length : 4;
    final compactItems = listings.length > 4 ? listings.sublist(4) : [];

    return SliverMainAxisGroup(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          sliver: SliverLayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.crossAxisExtent;
              final isWide =
                  Breakpoints.isTablet(width + 48) ||
                  Breakpoints.isDesktop(width + 48);

              if (isWide) {
                return SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 24,
                    mainAxisSpacing: 24,
                    childAspectRatio: 1.5,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) =>
                        FeaturedListingCard(listing: listings[index]),
                    childCount: featuredCount,
                  ),
                );
              }

              return SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) => Padding(
                    padding: const EdgeInsets.only(bottom: 32),
                    child: FeaturedListingCard(listing: listings[index]),
                  ),
                  childCount: featuredCount,
                ),
              );
            },
          ),
        ),
        if (compactItems.isNotEmpty)
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
            sliver: SliverLayoutBuilder(
              builder: (context, constraints) {
                final width = constraints.crossAxisExtent;
                final isWide =
                    Breakpoints.isTablet(width + 48) ||
                    Breakpoints.isDesktop(width + 48);

                if (isWide) {
                  return SliverGrid(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisExtent: 120,
                          crossAxisSpacing: 24,
                          mainAxisSpacing: 48,
                        ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) =>
                          CompactListingCard(listing: compactItems[index]),
                      childCount: compactItems.length,
                    ),
                  );
                }

                return SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => Padding(
                      padding: const EdgeInsets.only(bottom: 48),
                      child: CompactListingCard(listing: compactItems[index]),
                    ),
                    childCount: compactItems.length,
                  ),
                );
              },
            ),
          ),
      ],
    );
  }

  /// IKEA theme: featured cards + responsive grid.
  /// First 4 = IkeaFeaturedListingCard (full-width or 2-col),
  /// from item 5 = IkeaGridListingCard (2/3/4 columns by screen width).
  Widget _buildIkeaLayout(BuildContext context, List listings) {
    final featuredCount = listings.length < 4 ? listings.length : 4;
    final gridItems = listings.length > 4 ? listings.sublist(4) : [];

    return SliverMainAxisGroup(
      slivers: [
        // ── Featured cards ─────────
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          sliver: SliverLayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.crossAxisExtent;
              final isWide =
                  Breakpoints.isTablet(width + 48) ||
                  Breakpoints.isDesktop(width + 48);

              if (isWide) {
                return SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 24,
                    mainAxisSpacing: 48,
                    childAspectRatio: 0.85,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) =>
                        IkeaFeaturedListingCard(listing: listings[index]),
                    childCount: featuredCount,
                  ),
                );
              }

              return SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) => Padding(
                    padding: const EdgeInsets.only(bottom: 48),
                    child: IkeaFeaturedListingCard(listing: listings[index]),
                  ),
                  childCount: featuredCount,
                ),
              );
            },
          ),
        ),

        // ── Grid cards (responsive columns) ────────────────────
        if (gridItems.isNotEmpty)
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
            // NOTE: Must use SliverLayoutBuilder (not LayoutBuilder)
            // because this widget sits in a sliver context.
            // LayoutBuilder is a RenderBox and causes assertion
            // failures / Duplicate GlobalKey errors in sliver trees.
            sliver: SliverLayoutBuilder(
              builder: (context, constraints) {
                final width = constraints.crossAxisExtent;
                // NOTE: Dynamic column count based on available width.
                // `width` is already the content area inside padding.
                final crossAxisCount =
                    Breakpoints.isDesktop(width + 48)
                        ? 4
                        : Breakpoints.isTablet(width + 48)
                        ? 3
                        : 2;

                return SliverGrid(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    crossAxisSpacing: 24,
                    mainAxisSpacing: 24,
                    // NOTE: childAspectRatio controls the card's
                    // height relative to width. Lower values = taller
                    // cards. 0.68 accommodates square image + info
                    // section comfortably.
                    childAspectRatio: 0.68,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) =>
                        IkeaGridListingCard(listing: gridItems[index]),
                    childCount: gridItems.length,
                  ),
                );
              },
            ),
          ),

        // Bottom spacing so last grid row isn't flush with nav bar
        const SliverToBoxAdapter(child: SizedBox(height: 24)),
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
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
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

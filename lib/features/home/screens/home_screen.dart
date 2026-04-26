import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smivo/core/theme/theme_extensions.dart';
import 'package:smivo/features/home/providers/home_provider.dart';
import 'package:smivo/features/home/widgets/compact_listing_card.dart';
import 'package:smivo/features/home/widgets/featured_listing_card.dart';
import 'package:smivo/features/home/widgets/home_category_chips.dart';
import 'package:smivo/features/home/widgets/home_header.dart';
import 'package:smivo/features/home/widgets/home_search_bar.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final listingsAsync = ref.watch(homeListingsProvider);
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
              },
            ),
            
          ],
          ),
        ),
      ),
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

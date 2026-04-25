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
            ref.invalidate(homeListingsProvider);
            await ref.read(homeListingsProvider.future);
          },
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
            const SliverToBoxAdapter(child: SizedBox(height: 16)),
            const SliverToBoxAdapter(child: HomeHeader()),
            const SliverToBoxAdapter(child: SizedBox(height: 16)),
            const SliverToBoxAdapter(child: HomeSearchBar()),
            const SliverToBoxAdapter(child: SizedBox(height: 16)),
            const SliverToBoxAdapter(child: HomeCategoryChips()),
            const SliverToBoxAdapter(child: SizedBox(height: 24)),
            
            listingsAsync.when(
              loading: () => const SliverFillRemaining(
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (error, stack) => SliverFillRemaining(
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
                    child: Center(
                      child: Text(
                        'No listings found.',
                        style: typo.bodyLarge,
                      ),
                    ),
                  );
                }

                // First 3 items are featured, the rest are compact
                final featuredItems = listings.take(3).toList();
                final compactItems = listings.skip(3).toList();

                return SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        if (index < featuredItems.length) {
                          return FeaturedListingCard(
                            listing: featuredItems[index],
                          );
                        } else {
                          final compactIndex =
                              index - featuredItems.length;
                          return CompactListingCard(
                            listing: compactItems[compactIndex],
                          );
                        }
                      },
                      childCount:
                          featuredItems.length + compactItems.length,
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

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smivo/core/theme/theme_extensions.dart';
import 'package:smivo/data/models/user_review.dart';
import 'package:smivo/data/models/user_profile.dart';
import 'package:smivo/data/repositories/review_repository.dart';
import 'package:intl/intl.dart';

final userReviewsProvider =
    FutureProvider.family<List<UserReview>, ({String userId, String role})>((
      ref,
      args,
    ) {
      return ref
          .read(reviewRepositoryProvider)
          .fetchUserReviews(args.userId, args.role);
    });

class UserReviewsBottomSheet extends ConsumerStatefulWidget {
  const UserReviewsBottomSheet({
    super.key,
    required this.user,
    required this.initialRole, // 'buyer' or 'seller'
  });

  final UserProfile user;
  final String initialRole;

  @override
  ConsumerState<UserReviewsBottomSheet> createState() => _UserReviewsBottomSheetState();
}

class _UserReviewsBottomSheetState extends ConsumerState<UserReviewsBottomSheet> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 2,
      vsync: this,
      initialIndex: widget.initialRole == 'seller' ? 1 : 0,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.smivoColors;
    final typo = context.smivoTypo;
    final radius = context.smivoRadius;
    final user = widget.user;

    return Container(
      decoration: BoxDecoration(
        color: colors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(radius.xl)),
      ),
      padding: const EdgeInsets.only(top: 24, left: 24, right: 24),
      height: MediaQuery.of(context).size.height * 0.85,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 24),
              decoration: BoxDecoration(
                color: colors.outlineVariant,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Text(
            user.displayName ?? 'User',
            style: typo.headlineSmall.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          TabBar(
            controller: _tabController,
            labelColor: colors.primary,
            unselectedLabelColor: colors.onSurfaceVariant,
            indicatorColor: colors.primary,
            tabs: const [
              Tab(text: 'As Buyer'),
              Tab(text: 'As Seller'),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildRoleTab('buyer', user.buyerRating, user.buyerRatingCount),
                _buildRoleTab('seller', user.sellerRating, user.sellerRatingCount),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoleTab(String role, double rating, int count) {
    final colors = context.smivoColors;
    final typo = context.smivoTypo;
    final radius = context.smivoRadius;

    final reviewsAsync = ref.watch(
      userReviewsProvider((userId: widget.user.id, role: role)),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.star_rounded, color: Colors.amber, size: 28),
            const SizedBox(width: 4),
            Text(
              count > 0 ? rating.toStringAsFixed(1) : 'New',
              style: typo.headlineSmall.copyWith(fontWeight: FontWeight.bold),
            ),
            if (count > 0)
              Text(
                ' ($count reviews)',
                style: typo.bodyMedium.copyWith(color: colors.onSurfaceVariant),
              ),
          ],
        ),
        const SizedBox(height: 16),
        Expanded(
          child: reviewsAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, _) => Center(child: Text('Error: $err')),
            data: (reviews) {
              if (reviews.isEmpty) {
                return Center(
                  child: Text('No reviews yet.', style: typo.bodyLarge),
                );
              }

              // Aggregate tags
              final tagCounts = <String, int>{};
              for (final review in reviews) {
                for (final tag in review.tags) {
                  tagCounts[tag.name] = (tagCounts[tag.name] ?? 0) + 1;
                }
              }
              final sortedTags = tagCounts.entries.toList()
                ..sort((a, b) => b.value.compareTo(a.value));

              return CustomScrollView(
                slivers: [
                  if (sortedTags.isNotEmpty) ...[
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: sortedTags.map((e) => Chip(
                            label: Text('${e.key} (${e.value})'),
                            backgroundColor: colors.surfaceContainerHigh,
                            labelStyle: typo.labelSmall.copyWith(color: colors.onSurface),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(radius.sm),
                            ),
                            side: BorderSide.none,
                          )).toList(),
                        ),
                      ),
                    ),
                  ],
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final review = reviews[index];
                        return _buildReviewCard(context, review);
                      },
                      childCount: reviews.length,
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildReviewCard(BuildContext context, UserReview review) {
    final colors = context.smivoColors;
    final typo = context.smivoTypo;
    final radius = context.smivoRadius;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(radius.md),
        border: Border.all(color: colors.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: colors.surfaceContainerHigh,
                backgroundImage: review.reviewer?.avatarUrl != null &&
                        review.reviewer!.avatarUrl!.trim().isNotEmpty
                    ? NetworkImage(review.reviewer!.avatarUrl!)
                    : null,
                child: review.reviewer?.avatarUrl == null ||
                        review.reviewer!.avatarUrl!.trim().isEmpty
                    ? Icon(Icons.person, color: colors.onSurface.withValues(alpha: 0.5), size: 16)
                    : null,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      review.reviewer?.displayName ?? 'User',
                      style: typo.labelLarge.copyWith(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      DateFormat.yMMMd().format(review.createdAt),
                      style: typo.labelSmall.copyWith(color: colors.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
              Row(
                children: List.generate(5, (index) {
                  return Icon(
                    index < review.rating ? Icons.star_rounded : Icons.star_outline_rounded,
                    color: Colors.amber,
                    size: 16,
                  );
                }),
              ),
            ],
          ),
          if (review.comment != null && review.comment!.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(review.comment!, style: typo.bodyMedium),
          ],
        ],
      ),
    );
  }
}

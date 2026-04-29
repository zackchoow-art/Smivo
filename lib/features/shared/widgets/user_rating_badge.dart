import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smivo/core/theme/theme_extensions.dart';
import 'package:smivo/data/models/user_profile.dart';
import 'package:smivo/features/shared/widgets/user_reviews_bottom_sheet.dart';

class UserRatingBadge extends ConsumerWidget {
  const UserRatingBadge({
    super.key,
    required this.user,
    required this.role, // 'buyer' or 'seller'
  });

  final UserProfile user;
  final String role;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.smivoColors;
    final typo = context.smivoTypo;
    final radius = context.smivoRadius;

    final rating = role == 'buyer' ? user.buyerRating : user.sellerRating;
    final count =
        role == 'buyer' ? user.buyerRatingCount : user.sellerRatingCount;

    final hasRating = count > 0;

    return InkWell(
      borderRadius: BorderRadius.circular(radius.sm),
      onTap: () {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder:
              (context) => UserReviewsBottomSheet(
                user: user,
                initialRole: role,
              ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: colors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(radius.sm),
          border: Border.all(
            color: colors.outlineVariant.withValues(alpha: 0.5),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.star_rounded,
              color: hasRating ? Colors.amber : colors.onSurfaceVariant,
              size: 14,
            ),
            const SizedBox(width: 4),
            Text(
              hasRating ? rating.toStringAsFixed(1) : 'New',
              style: typo.labelSmall.copyWith(
                fontWeight: FontWeight.bold,
                color: colors.onSurface,
              ),
            ),
            if (hasRating) ...[
              const SizedBox(width: 2),
              Text(
                '($count)',
                style: typo.labelSmall.copyWith(color: colors.onSurfaceVariant),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

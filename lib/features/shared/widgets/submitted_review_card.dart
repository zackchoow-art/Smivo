import 'package:flutter/material.dart';
import 'package:smivo/core/theme/theme_extensions.dart';
import 'package:smivo/data/models/user_review.dart';

class SubmittedReviewCard extends StatelessWidget {
  const SubmittedReviewCard({
    super.key,
    required this.review,
  });

  final UserReview review;

  @override
  Widget build(BuildContext context) {
    final colors = context.smivoColors;
    final typo = context.smivoTypo;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colors.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.check_circle, color: colors.success, size: 20),
              const SizedBox(width: 8),
              Text(
                'You have reviewed this order',
                style: typo.titleMedium.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colors.success,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (index) {
              return Icon(
                index < review.rating ? Icons.star_rounded : Icons.star_outline_rounded,
                color: colors.primary,
                size: 32,
              );
            }),
          ),
          if (review.tags.isNotEmpty) ...[
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: review.tags.map((tag) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: colors.primary.withValues(alpha: 0.1),
                    border: Border.all(color: colors.primary),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    tag.name,
                    style: typo.labelSmall.copyWith(color: colors.primary),
                  ),
                );
              }).toList(),
            ),
          ],
          if (review.comment != null && review.comment!.trim().isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(
              review.comment!,
              style: typo.bodyMedium.copyWith(color: colors.onSurface),
            ),
          ],
        ],
      ),
    );
  }
}

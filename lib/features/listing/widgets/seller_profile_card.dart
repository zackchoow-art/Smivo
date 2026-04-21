import 'package:flutter/material.dart';
import 'package:smivo/core/theme/app_colors.dart';
import 'package:smivo/core/theme/app_spacing.dart';
import 'package:smivo/core/theme/app_text_styles.dart';

class SellerProfileCard extends StatelessWidget {
  const SellerProfileCard({
    super.key,
    required this.name,
    required this.avatarUrl,
    required this.rating,
    required this.reviewCount,
    this.label = 'SELLER',
    this.onMessageTap,
  });

  final String name;
  final String avatarUrl;
  final String rating;
  final int reviewCount;
  final String label;
  final VoidCallback? onMessageTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundImage: NetworkImage(avatarUrl),
          ),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTextStyles.labelSmall.copyWith(
                    color: AppColors.onSurface.withValues(alpha: 0.5),
                    letterSpacing: 0.5,
                  ),
                ),
                Text(
                  name,
                  style: AppTextStyles.titleMedium,
                ),
                Row(
                  children: [
                    const Icon(Icons.star, color: AppColors.primary, size: 16),
                    const SizedBox(width: AppSpacing.xs),
                    Text(
                      '$rating ($reviewCount reviews)',
                      style: AppTextStyles.labelSmall.copyWith(color: AppColors.primary),
                    ),
                  ],
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: onMessageTap,
            child: Container(
              padding: const EdgeInsets.all(AppSpacing.sm),
              decoration: const BoxDecoration(
                color: AppColors.surfaceContainerLow,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.chat_bubble_outline, color: AppColors.primary, size: 20),
            ),
          ),
        ],
      ),
    );
  }
}

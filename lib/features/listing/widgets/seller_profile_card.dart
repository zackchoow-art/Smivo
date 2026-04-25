import 'package:flutter/material.dart';
import 'package:smivo/core/theme/theme_extensions.dart';

class SellerProfileCard extends StatelessWidget {
  const SellerProfileCard({
    super.key,
    required this.name,
    required this.avatarUrl,
    required this.rating,
    required this.reviewCount,
    this.label = 'SELLER',
    this.email,
    this.onMessageTap,
  });

  final String name;
  final String avatarUrl;
  final String rating;
  final int reviewCount;
  final String label;
  final String? email;
  final VoidCallback? onMessageTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.smivoColors;
    final typo = context.smivoTypo;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundImage: NetworkImage(avatarUrl),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: typo.labelSmall.copyWith(
                    color: colors.onSurface.withValues(alpha: 0.5),
                    letterSpacing: 0.5,
                  ),
                ),
                Text(
                  name,
                  style: typo.titleMedium,
                ),
                if (email != null)
                  Text(
                    email!,
                    style: typo.bodySmall.copyWith(
                      color: colors.outlineVariant,
                    ),
                  ),
                Row(
                  children: [
                    Icon(Icons.star, color: colors.primary, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      '$rating ($reviewCount reviews)',
                      style: typo.labelSmall.copyWith(
                        color: colors.primary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: onMessageTap,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: colors.surfaceContainerLow,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.chat_bubble_outline,
                color: colors.primary,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

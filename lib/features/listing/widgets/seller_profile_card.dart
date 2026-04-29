import 'package:flutter/material.dart';
import 'package:smivo/core/theme/theme_extensions.dart';
import 'package:smivo/data/models/user_profile.dart';
import 'package:smivo/features/shared/widgets/user_rating_badge.dart';

class SellerProfileCard extends StatelessWidget {
  const SellerProfileCard({
    super.key,
    required this.user,
    this.label = 'SELLER',
    this.onMessageTap,
  });

  final UserProfile user;
  final String label;
  final VoidCallback? onMessageTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.smivoColors;
    final typo = context.smivoTypo;

    final name = user.displayName ?? 'Anonymous Student';
    final email = user.email;
    final avatarUrl =
        (user.avatarUrl != null && user.avatarUrl!.isNotEmpty)
            ? user.avatarUrl!
            : 'https://i.pravatar.cc/150?u=${user.id}';

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        children: [
          CircleAvatar(radius: 24, backgroundImage: NetworkImage(avatarUrl)),
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
                Text(name, style: typo.titleMedium),
                Text(
                  email,
                  style: typo.bodySmall.copyWith(color: colors.outlineVariant),
                ),
                const SizedBox(height: 4),
                UserRatingBadge(user: user, role: 'seller'),
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

import 'package:flutter/material.dart';
import 'package:smivo/core/theme/theme_extensions.dart';
import 'package:smivo/data/models/user_profile.dart';
import 'package:smivo/features/shared/widgets/user_rating_badge.dart';
import 'package:smivo/shared/widgets/last_active_badge.dart';
import 'package:smivo/shared/widgets/smivo_user_avatar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SmivoUserIdentity extends ConsumerWidget {
  const SmivoUserIdentity({
    super.key,
    required this.user,
    this.showBackground = false,
    this.role = 'seller',
    this.showPresence,
    this.trailingText,
    this.showMessageButton = false,
    this.onMessageTap,
  });

  final UserProfile user;
  final bool showBackground;
  final String role;
  final bool? showPresence;
  final String? trailingText;
  final bool showMessageButton;
  final VoidCallback? onMessageTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.smivoColors;
    final typo = context.smivoTypo;
    final radius = context.smivoRadius;

    Widget content = Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SmivoUserAvatar(user: user, radius: 24, role: role, showOnlineDot: showPresence),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Flexible(
                    child: Text(
                      user.displayName ?? 'User',
                      style: typo.labelLarge.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colors.onSurface,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (showPresence ?? true) ...[
                    const SizedBox(width: 8),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 2),
                      child: LastActiveBadge(lastActiveAt: user.lastActiveAt),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 2),
              Text(
                user.email,
                style: typo.bodySmall.copyWith(
                  color: colors.onSurfaceVariant,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  UserRatingBadge(user: user, role: role),
                  const Spacer(),
                  if (trailingText != null)
                    Text(
                      trailingText!,
                      style: typo.labelSmall.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.right,
                    ),
                ],
              ),
            ],
          ),
        ),
        if (showMessageButton)
          IconButton(
            onPressed: onMessageTap,
            icon: Icon(Icons.chat_outlined, color: colors.primary),
          ),
      ],
    );

    if (showBackground) {
      content = Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(radius.md),
          border: Border.all(
            color: colors.outlineVariant.withValues(alpha: 0.5),
          ),
        ),
        child: content,
      );
    }

    return content;
  }
}

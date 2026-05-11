import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smivo/core/providers/presence_provider.dart';
import 'package:smivo/core/theme/theme_extensions.dart';
import 'package:smivo/data/models/user_profile.dart';
import 'package:smivo/features/shared/widgets/user_reviews_bottom_sheet.dart';

class SmivoUserAvatar extends ConsumerWidget {
  const SmivoUserAvatar({
    super.key,
    required this.user,
    this.radius = 20.0,
    this.role = 'seller',
    this.showOnlineDot,
    this.enableTap = true,
  });

  final UserProfile user;
  final double radius;
  final String role;
  final bool? showOnlineDot;
  final bool enableTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.smivoColors;
    
    final platformShowDot = ref.watch(presenceConfigProvider).value ?? true;
    final effectiveShowDot = showOnlineDot ?? platformShowDot;

    // Check if the user was active in the last 10 minutes
    final isOnline = user.lastActiveAt != null &&
        DateTime.now().difference(user.lastActiveAt!).inMinutes <= 10;

    final avatarImage =
        user.avatarUrl != null && user.avatarUrl!.trim().isNotEmpty
            ? NetworkImage(user.avatarUrl!)
            : null;

    final avatarFallback = Icon(
      Icons.person,
      size: radius,
      color: colors.onSurface.withValues(alpha: 0.5),
    );

    Widget avatarWidget = CircleAvatar(
      radius: radius,
      backgroundColor: colors.surfaceContainerHigh,
      backgroundImage: avatarImage,
      child: avatarImage == null ? avatarFallback : null,
    );

    return GestureDetector(
      onTap: enableTap
          ? () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (context) => UserReviewsBottomSheet(
                  user: user,
                  initialRole: role,
                ),
              );
            }
          : null,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          avatarWidget,
          if (effectiveShowDot && isOnline)
            Positioned(
              right: 0,
              top: 0,
              child: Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: Colors.green,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: colors.background,
                    width: 1.5,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

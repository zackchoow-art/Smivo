import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:smivo/core/constants/app_constants.dart';
import 'package:smivo/core/theme/app_colors.dart';
import 'package:smivo/core/theme/app_spacing.dart';
import 'package:smivo/core/theme/app_text_styles.dart';
import 'package:smivo/core/router/app_routes.dart';
import 'package:smivo/features/notifications/providers/notification_provider.dart';
import 'package:smivo/shared/widgets/message_badge_icon.dart';

class HomeHeader extends ConsumerWidget {
  const HomeHeader({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unreadAsync = ref.watch(totalUnreadNotificationsProvider);
    final unreadCount = unreadAsync.valueOrNull ?? 0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Campus',
                    style: AppTextStyles.headlineMedium,
                  ),
                  Text(
                    AppConstants.defaultSchool.replaceAll(' ', ''), // e.g. "SmithCollege"
                    style: AppTextStyles.headlineLarge.copyWith(
                      color: const Color(0xFF0546ED), // The screenshot uses a blue tint for the school name
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  MessageBadgeIcon(unreadCount: unreadCount),
                  const SizedBox(width: AppSpacing.md),
                  GestureDetector(
                    onTap: () => context.pushNamed(AppRoutes.settings),
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.outlineVariant, width: 2),
                      ),
                      child: const CircleAvatar(
                        radius: 20,
                        backgroundColor: AppColors.surfaceContainerHigh,
                        child: Icon(Icons.person, color: AppColors.onSurface),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'The digital pulse of your university. Buy, sell, and connect.',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.onSurface.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }
}

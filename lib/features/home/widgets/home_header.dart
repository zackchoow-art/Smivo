import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:smivo/core/constants/app_constants.dart';
import 'package:smivo/core/theme/app_colors.dart';
import 'package:smivo/core/theme/app_spacing.dart';
import 'package:smivo/core/theme/app_text_styles.dart';
import 'package:smivo/core/router/app_routes.dart';
import 'package:smivo/features/notifications/providers/notification_provider.dart';

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
                  _NotificationBellIcon(unreadCount: unreadCount),
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

class _NotificationBellIcon extends StatelessWidget {
  const _NotificationBellIcon({required this.unreadCount});

  final int unreadCount;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () => context.pushNamed(AppRoutes.notificationCenter),
      icon: Stack(
        clipBehavior: Clip.none,
        children: [
          Icon(
            unreadCount > 0
                ? Icons.notifications_active
                : Icons.notifications_outlined,
            color: AppColors.primary,
            size: 28,
          ),
          if (unreadCount > 0)
            Positioned(
              right: -4,
              top: -4,
              child: Container(
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  color: const Color(0xFFCC3300),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 1.5),
                ),
                constraints: const BoxConstraints(
                  minWidth: 18,
                  minHeight: 18,
                ),
                child: Center(
                  child: Text(
                    unreadCount > 9 ? '9+' : unreadCount.toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      height: 1,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

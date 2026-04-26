import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:smivo/core/constants/app_constants.dart';
import 'package:smivo/core/theme/theme_extensions.dart';
import 'package:smivo/core/router/app_routes.dart';
import 'package:smivo/features/notifications/providers/notification_provider.dart';
import 'package:smivo/features/profile/providers/profile_provider.dart';

class HomeHeader extends ConsumerWidget {
  const HomeHeader({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unreadAsync = ref.watch(totalUnreadNotificationsProvider);
    final unreadCount = unreadAsync.valueOrNull ?? 0;
    final profileAsync = ref.watch(profileProvider);
    final profile = profileAsync.valueOrNull;

    final colors = context.smivoColors;
    final typo = context.smivoTypo;

    final schoolName = profile?.school ?? AppConstants.defaultSchool;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
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
                    'Smivo',
                    style: typo.headlineMedium.copyWith(color: colors.primary),
                  ),
                  Text(
                    schoolName.replaceAll(' ', ''),
                    style: typo.headlineLarge.copyWith(
                      color: colors.secondaryGradientStart,
                    ),
                  ),
                  const SizedBox(height: 4),
                  if (profile != null)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              profile.displayName ?? 'User',
                              style: typo.labelLarge.copyWith(color: colors.onSurface, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: colors.success.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.verified, size: 12, color: colors.success),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Verified',
                                    style: typo.labelSmall.copyWith(color: colors.success, fontSize: 10, fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          profile.email,
                          style: typo.labelSmall.copyWith(color: colors.onSurfaceVariant),
                        ),
                      ],
                    )
                  else
                    Row(
                      children: [
                        Icon(Icons.account_circle, size: 14, color: colors.onSurfaceVariant),
                        const SizedBox(width: 4),
                        Text(
                          'Not logged in',
                          style: typo.labelSmall.copyWith(color: colors.onSurfaceVariant),
                        ),
                      ],
                    ),
                ],
              ),
              Row(
                children: [
                  _NotificationBellIcon(unreadCount: unreadCount),
                  const SizedBox(width: 12),
                  GestureDetector(
                    onTap: () => context.pushNamed(AppRoutes.settings),
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: colors.outlineVariant,
                          width: 2,
                        ),
                      ),
                      child: CircleAvatar(
                        radius: 20,
                        backgroundColor: colors.surfaceContainerHigh,
                        backgroundImage: profile?.avatarUrl != null
                            ? NetworkImage(profile!.avatarUrl!)
                            : null,
                        child: profile?.avatarUrl == null
                            ? Icon(Icons.person, color: colors.onSurface)
                            : null,
                      ),
                    ),
                  ),
                ],
              ),
            ],
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
    final colors = context.smivoColors;

    return IconButton(
      onPressed: () => context.pushNamed(AppRoutes.notificationCenter),
      icon: Stack(
        clipBehavior: Clip.none,
        children: [
          Icon(
            unreadCount > 0
                ? Icons.notifications_active
                : Icons.notifications_outlined,
            color: colors.primary,
            size: 28,
          ),
          if (unreadCount > 0)
            Positioned(
              right: -4,
              top: -4,
              child: Container(
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  color: colors.error,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: colors.surfaceContainerLowest,
                    width: 1.5,
                  ),
                ),
                constraints: const BoxConstraints(
                  minWidth: 18,
                  minHeight: 18,
                ),
                child: Center(
                  child: Text(
                    unreadCount > 9 ? '9+' : unreadCount.toString(),
                    style: TextStyle(
                      color: colors.onPrimary,
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

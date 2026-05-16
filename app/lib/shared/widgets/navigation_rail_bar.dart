import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:smivo/core/router/app_routes.dart';
import 'package:smivo/core/theme/theme_extensions.dart';
import 'package:smivo/features/chat/providers/chat_provider.dart';
import 'package:smivo/features/orders/providers/orders_provider.dart';
import 'package:smivo/features/notifications/providers/notification_provider.dart';
import 'package:smivo/features/profile/providers/profile_provider.dart';

/// Vertical navigation rail for tablet-sized screens (600–1024px).
///
/// Mirrors the same tabs and badge logic as [BottomNavBar] but renders
/// as a narrow vertical strip on the left side of the screen.
/// On desktop (> 1024px), [extended] can be set to true to show labels.
class NavigationRailBar extends ConsumerWidget {
  const NavigationRailBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    this.extended = false,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;

  /// When true, shows text labels next to icons (desktop sidebar mode).
  final bool extended;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final totalUnreadAsync = ref.watch(chatTotalUnreadProvider);
    final totalUnread = totalUnreadAsync.value ?? 0;
    final unreadOrderUpdatesAsync = ref.watch(unreadOrderUpdatesCountProvider);
    final unreadOrderUpdates = unreadOrderUpdatesAsync.value ?? 0;
    
    final profileAsync = ref.watch(profileProvider);
    final profile = profileAsync.value;
    final unreadSystemAsync = ref.watch(totalUnreadNotificationsProvider);
    final unreadSystemCount = unreadSystemAsync.value ?? 0;

    final colors = context.smivoColors;
    final typo = context.smivoTypo;

    return NavigationRail(
      selectedIndex: currentIndex,
      onDestinationSelected: onTap,
      extended: false,
      minWidth: 120,
      minExtendedWidth: 200,
      backgroundColor: colors.surfaceContainerLowest,
      indicatorColor: colors.navActiveBackground,
      selectedIconTheme: IconThemeData(color: colors.navActiveIcon, size: 48),
      unselectedIconTheme: IconThemeData(color: colors.onSurfaceVariant, size: 48),
      labelType: NavigationRailLabelType.all,
      selectedLabelTextStyle: typo.labelLarge.copyWith(
        color: colors.primary,
        fontWeight: FontWeight.bold,
      ),
      unselectedLabelTextStyle: typo.labelLarge.copyWith(
        color: colors.onSurfaceVariant,
      ),
      leading: Padding(
        padding: const EdgeInsets.only(top: 16, bottom: 24),
        child: Text(
          'Smivo',
          style: typo.headlineLarge.copyWith(
            color: colors.primary,
            fontWeight: FontWeight.bold,
            fontStyle: FontStyle.italic,
            letterSpacing: -0.5,
          ),
        ),
      ),
      trailing: Expanded(
        child: Align(
          alignment: Alignment.bottomCenter,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  onPressed: () => context.pushNamed(AppRoutes.notificationCenter),
                  icon: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Icon(
                        unreadSystemCount > 0
                            ? Icons.notifications_active
                            : Icons.notifications_outlined,
                        color: colors.primary,
                        size: 32,
                      ),
                      if (unreadSystemCount > 0)
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
                            constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
                            child: Center(
                              child: Text(
                                unreadSystemCount > 9 ? '9+' : unreadSystemCount.toString(),
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
                ),
                const SizedBox(height: 16),
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
                      backgroundImage:
                          profile?.avatarUrl != null
                              ? NetworkImage(profile!.avatarUrl!)
                              : null,
                      child:
                          profile?.avatarUrl == null
                              ? Icon(Icons.person, color: colors.onSurface)
                              : null,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      destinations: [
        const NavigationRailDestination(
          padding: EdgeInsets.symmetric(vertical: 16),
          icon: Icon(Icons.home_outlined),
          selectedIcon: Icon(Icons.home),
          label: Text('Home'),
        ),
        NavigationRailDestination(
          padding: const EdgeInsets.symmetric(vertical: 16),
          icon: Badge(
            label: Text(
              totalUnread > 99 ? '99+' : totalUnread.toString(),
              style: TextStyle(fontSize: 9, color: colors.onPrimary),
            ),
            isLabelVisible: totalUnread > 0,
            backgroundColor: colors.error,
            child: const Icon(Icons.chat_bubble_outline),
          ),
          selectedIcon: Badge(
            label: Text(
              totalUnread > 99 ? '99+' : totalUnread.toString(),
              style: TextStyle(fontSize: 9, color: colors.onPrimary),
            ),
            isLabelVisible: totalUnread > 0,
            backgroundColor: colors.error,
            child: const Icon(Icons.chat_bubble),
          ),
          label: const Text('Chat'),
        ),
        const NavigationRailDestination(
          padding: EdgeInsets.symmetric(vertical: 16),
          icon: Icon(Icons.add_circle_outline),
          selectedIcon: Icon(Icons.add_circle),
          label: Text('Post'),
        ),
        const NavigationRailDestination(
          padding: EdgeInsets.symmetric(vertical: 16),
          icon: Icon(Icons.directions_car_outlined),
          selectedIcon: Icon(Icons.directions_car),
          label: Text('Carpool'),
        ),
        NavigationRailDestination(
          padding: const EdgeInsets.symmetric(vertical: 16),
          icon: Badge(
            label: Text(
              unreadOrderUpdates > 99 ? '99+' : unreadOrderUpdates.toString(),
              style: TextStyle(fontSize: 9, color: colors.onPrimary),
            ),
            isLabelVisible: unreadOrderUpdates > 0,
            backgroundColor: colors.error,
            child: const Icon(Icons.receipt_long_outlined),
          ),
          selectedIcon: Badge(
            label: Text(
              unreadOrderUpdates > 99 ? '99+' : unreadOrderUpdates.toString(),
              style: TextStyle(fontSize: 9, color: colors.onPrimary),
            ),
            isLabelVisible: unreadOrderUpdates > 0,
            backgroundColor: colors.error,
            child: const Icon(Icons.receipt_long),
          ),
          label: const Text('Orders'),
        ),
      ],
    );
  }
}

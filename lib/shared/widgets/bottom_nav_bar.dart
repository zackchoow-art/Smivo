import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:smivo/core/router/app_routes.dart';
import 'package:smivo/core/theme/theme_extensions.dart';
import 'package:smivo/features/chat/providers/chat_provider.dart';
import 'package:smivo/features/orders/providers/orders_provider.dart';

class BottomNavBar extends ConsumerWidget {
  const BottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final totalUnreadAsync = ref.watch(chatTotalUnreadProvider);
    final totalUnread = totalUnreadAsync.valueOrNull ?? 0;
    final unreadOrderUpdatesAsync = ref.watch(unreadOrderUpdatesCountProvider);
    final unreadOrderUpdates = unreadOrderUpdatesAsync.valueOrNull ?? 0;
    final colors = context.smivoColors;
    final radius = context.smivoRadius;
    final shadows = context.smivoShadows;

    return Container(
      decoration: BoxDecoration(
        color: colors.surfaceContainerLowest,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(radius.bottomSheet),
          topRight: Radius.circular(radius.bottomSheet),
        ),
        boxShadow: shadows.bottomNav,
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _NavBarItem(
                icon: Icons.home,
                outlinedIcon: Icons.home_outlined,
                label: 'Home',
                isSelected: currentIndex == 0,
                onTap: () => onTap(0),
              ),
               _NavBarItem(
                icon: Icons.chat_bubble,
                outlinedIcon: Icons.chat_bubble_outline,
                label: 'Chat',
                isSelected: currentIndex == 1,
                onTap: () => onTap(1),
                unreadCount: totalUnread,
              ),
              _NavBarItem(
                icon: Icons.add_circle_outline,
                outlinedIcon: Icons.add_circle_outline,
                label: 'Post',
                isSelected: false,
                onTap: () {
                  context.pushNamed(AppRoutes.createListing);
                },
              ),
              _NavBarItem(
                icon: Icons.receipt_long,
                outlinedIcon: Icons.receipt_long_outlined,
                label: 'Orders',
                isSelected: currentIndex == 2,
                onTap: () => onTap(2),
                unreadCount: unreadOrderUpdates,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavBarItem extends StatelessWidget {
  final IconData icon;
  final IconData outlinedIcon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final int unreadCount;

  const _NavBarItem({
    required this.icon,
    required this.outlinedIcon,
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.unreadCount = 0,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.smivoColors;
    final typo = context.smivoTypo;
    // NOTE: Active item uses navActiveIcon; inactive uses onSurfaceVariant.
    final color = isSelected ? colors.navActiveIcon : colors.onSurfaceVariant;
    
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: 64, // Touch target
        padding: const EdgeInsets.symmetric(vertical: 4),
        decoration: isSelected
            ? BoxDecoration(
                color: colors.navActiveBackground,
                borderRadius: context.smivoRadius.circularFull(),
              )
            : null,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Badge(
              label: Text(
                unreadCount > 99 ? '99+' : unreadCount.toString(),
                style: TextStyle(
                  fontSize: 10,
                  color: colors.onPrimary,
                ),
              ),
              isLabelVisible: unreadCount > 0,
              backgroundColor: colors.error,
              child: Icon(
                isSelected ? icon : outlinedIcon,
                color: color,
                size: 26,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: typo.labelSmall.copyWith(
                color: color,
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w700,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

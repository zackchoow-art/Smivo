import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:smivo/core/router/app_routes.dart';
import 'package:smivo/core/theme/app_text_styles.dart';
import 'package:smivo/features/chat/providers/chat_provider.dart';

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

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
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
                label: 'HOME',
                isSelected: currentIndex == 0,
                onTap: () => onTap(0),
              ),
               _NavBarItem(
                icon: Icons.chat_bubble,
                outlinedIcon: Icons.chat_bubble_outline,
                label: 'CHAT',
                isSelected: currentIndex == 1,
                onTap: () => onTap(1),
                unreadCount: totalUnread,
              ),
              _NavBarItem(
                icon: Icons.add_circle_outline,
                outlinedIcon: Icons.add_circle_outline,
                label: 'POST',
                isSelected: false,
                onTap: () {
                  context.pushNamed(AppRoutes.createListing);
                },
              ),
              _NavBarItem(
                icon: Icons.receipt_long,
                outlinedIcon: Icons.receipt_long_outlined,
                label: 'ORDERS',
                isSelected: currentIndex == 2,
                onTap: () => onTap(2),
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
    final color = isSelected ? const Color(0xFF013DFD) : const Color(0xFF546387);
    
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: 64, // Touch target
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Badge(
              label: Text(
                unreadCount > 99 ? '99+' : unreadCount.toString(),
                style: const TextStyle(fontSize: 10, color: Colors.white),
              ),
              isLabelVisible: unreadCount > 0,
              backgroundColor: Colors.red,
              child: Icon(
                isSelected ? icon : outlinedIcon,
                color: color,
                size: 26,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: AppTextStyles.labelSmall.copyWith(
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

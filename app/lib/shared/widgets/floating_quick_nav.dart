import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:smivo/core/providers/preferences_provider.dart';
import 'package:smivo/core/router/app_routes.dart';
import 'package:smivo/core/theme/theme_extensions.dart';

/// A speed-dial floating action button that provides quick access to the
/// four main navigation destinations.
///
/// Shown only on mobile (< 600 px) when [showFloatingNavProvider] is true.
/// Users can hide it from System Settings.
///
/// NOTE: The dial auto-collapses when the user taps any item or taps
/// outside the overlay (handled by the scrim).
class FloatingQuickNav extends ConsumerStatefulWidget {
  const FloatingQuickNav({super.key});

  @override
  ConsumerState<FloatingQuickNav> createState() => _FloatingQuickNavState();
}

class _FloatingQuickNavState extends ConsumerState<FloatingQuickNav>
    with SingleTickerProviderStateMixin {
  bool _isOpen = false;
  late final AnimationController _controller;
  late final Animation<double> _expandAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 220),
      vsync: this,
    );
    _expandAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() {
      _isOpen = !_isOpen;
      if (_isOpen) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }

  void _close() {
    if (_isOpen) _toggle();
  }

  void _navigateTo(String routeName) {
    _close();
    context.goNamed(routeName);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.smivoColors;
    final typo = context.smivoTypo;

    return Stack(
      alignment: Alignment.bottomRight,
      clipBehavior: Clip.none,
      children: [
        // Scrim: tapping outside collapses the dial
        if (_isOpen)
          Positioned.fill(
            child: GestureDetector(
              onTap: _close,
              child: Container(color: Colors.black26),
            ),
          ),

        // Speed-dial items (rendered bottom-to-top)
        ..._buildItems(colors, typo),

        // Main FAB toggle button
        Padding(
          padding: const EdgeInsets.only(right: 16, bottom: 100),
          child: AnimatedBuilder(
            animation: _expandAnimation,
            builder: (context, child) => FloatingActionButton(
              heroTag: 'floating_quick_nav_main',
              backgroundColor: colors.primary,
              foregroundColor: colors.onPrimary,
              elevation: _isOpen ? 6 : 4,
              onPressed: _toggle,
              child: AnimatedRotation(
                turns: _isOpen ? 0.125 : 0,
                duration: const Duration(milliseconds: 220),
                child: const Icon(Icons.apps_rounded, size: 26),
              ),
            ),
          ),
        ),
      ],
    );
  }

  List<Widget> _buildItems(SmivoColors colors, SmivoTypography typo) {
    // Items rendered from bottom to top — first item appears closest to FAB.
    // NOTE: Offsets are spaced 64px apart for comfortable thumb reach.
    final items = [
      _DialItem(
        icon: Icons.home_rounded,
        label: 'Home',
        onTap: () => _navigateTo(AppRoutes.home),
        bottomOffset: 172,
      ),
      _DialItem(
        icon: Icons.chat_bubble_rounded,
        label: 'Chat',
        onTap: () => _navigateTo(AppRoutes.chatList),
        bottomOffset: 236,
      ),
      _DialItem(
        icon: Icons.add_box_rounded,
        label: 'Post',
        onTap: () => _navigateTo(AppRoutes.createListing),
        bottomOffset: 300,
      ),
      _DialItem(
        icon: Icons.receipt_long_rounded,
        label: 'Orders',
        onTap: () => _navigateTo(AppRoutes.orders),
        bottomOffset: 364,
      ),
    ];

    return items.map((item) {
      return Positioned(
        right: 16,
        bottom: item.bottomOffset,
        child: AnimatedBuilder(
          animation: _expandAnimation,
          builder: (_, __) => Opacity(
            opacity: _expandAnimation.value,
            child: Transform.scale(
              scale: 0.7 + 0.3 * _expandAnimation.value,
              alignment: Alignment.bottomRight,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Label chip
                  Material(
                    color: colors.surface,
                    elevation: 2,
                    borderRadius: BorderRadius.circular(20),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 6,
                      ),
                      child: Text(
                        item.label,
                        style: typo.labelLarge.copyWith(
                          color: colors.onSurface,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  // Mini FAB
                  FloatingActionButton.small(
                    heroTag: 'floating_quick_nav_${item.label}',
                    backgroundColor: colors.primaryContainer,
                    foregroundColor: colors.primary,
                    elevation: 2,
                    onPressed: item.onTap,
                    child: Icon(item.icon, size: 22),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }).toList();
  }
}

/// Data class for a single speed-dial item.
class _DialItem {
  const _DialItem({
    required this.icon,
    required this.label,
    required this.onTap,
    required this.bottomOffset,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final double bottomOffset;
}

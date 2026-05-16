import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smivo/core/router/app_routes.dart';
import 'package:smivo/core/router/router.dart';
import 'package:smivo/core/theme/theme_extensions.dart';

/// A draggable speed-dial button that fans out navigation shortcuts.
///
/// - Draggable to any screen position; snaps to nearest horizontal edge.
/// - Tap to toggle a radial fan of mini icons (Home, Orders, Chat).
/// - Fan direction auto-adapts so items always point toward screen center.
/// - Shown only on mobile (< 600 px) when [showFloatingNavProvider] is true.
class FloatingQuickNav extends ConsumerStatefulWidget {
  const FloatingQuickNav({super.key});

  @override
  ConsumerState<FloatingQuickNav> createState() => _FloatingQuickNavState();
}

class _FloatingQuickNavState extends ConsumerState<FloatingQuickNav>
    with SingleTickerProviderStateMixin {
  // ── Layout constants ──────────────────────────────────────────
  static const double _fabSize = 48;
  static const double _miniFabSize = 40;
  static const double _fanRadius = 76;
  // NOTE: 90° arc gives comfortable spacing for 3 items.
  static const double _fanSpread = math.pi / 2;

  // ── State ─────────────────────────────────────────────────────
  // NOTE: Static so position survives widget rebuilds caused by
  // route changes in the ValueListenableBuilder.
  static Offset _savedPosition = const Offset(12, 100);
  late Offset _position;
  bool _isOpen = false;

  late final AnimationController _controller;
  late final Animation<double> _expandAnimation;

  // Navigation destinations.
  static const _items = [
    _NavItem(
      icon: Icons.home_rounded,
      label: 'Home',
      routeName: AppRoutes.home,
    ),
    _NavItem(
      icon: Icons.receipt_long_rounded,
      label: 'Orders',
      routeName: AppRoutes.orders,
    ),
    _NavItem(
      icon: Icons.chat_bubble_rounded,
      label: 'Chat',
      routeName: AppRoutes.chatList,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _position = _savedPosition;
    _controller = AnimationController(
      duration: const Duration(milliseconds: 250),
      vsync: this,
    );
    _expandAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
      reverseCurve: Curves.easeInCubic,
    );
    // Rebuild whenever the animation ticks so fan items animate smoothly.
    _controller.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    // Persist position for next mount.
    _savedPosition = _position;
    _controller.dispose();
    super.dispose();
  }

  // ── Gesture helpers ───────────────────────────────────────────

  void _toggle() {
    _isOpen = !_isOpen;
    if (_isOpen) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
  }

  void _close() {
    if (_isOpen) _toggle();
  }

  void _navigateTo(String routeName) {
    _close();
    // NOTE: FloatingQuickNav lives above GoRouter in the widget tree
    // (inside MaterialApp.builder), so context.goNamed() can't find
    // the Router ancestor. Use the router provider directly instead.
    ref.read(routerProvider).goNamed(routeName);
  }

  Offset _clamp(Offset pos, Size screen) {
    final safePadding = MediaQuery.of(context).padding;
    return Offset(
      pos.dx.clamp(4, screen.width - _fabSize - 4),
      pos.dy.clamp(
        safePadding.top + 4,
        screen.height - _fabSize - safePadding.bottom - 4,
      ),
    );
  }

  void _snapToEdge(Size screen) {
    final centerX = _position.dx + _fabSize / 2;
    final snapLeft = centerX < screen.width / 2;
    setState(() {
      _position = Offset(
        snapLeft ? 12 : screen.width - _fabSize - 12,
        _position.dy,
      );
      _savedPosition = _position;
    });
  }

  /// Angle from FAB center toward screen center — the fan opens this way.
  double _baseAngle(Size screen) {
    final fab = Offset(
      _position.dx + _fabSize / 2,
      _position.dy + _fabSize / 2,
    );
    final center = Offset(screen.width / 2, screen.height / 2);
    return math.atan2(center.dy - fab.dy, center.dx - fab.dx);
  }

  // ── Build ─────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final colors = context.smivoColors;
    final screen = MediaQuery.of(context).size;
    final angle = _baseAngle(screen);

    // NOTE: Use a SizedBox.expand so the Stack fills the parent,
    // fixing the old bug where the Stack was only as large as the FAB.
    return SizedBox.expand(
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // ── Scrim ──────────────────────────────────────────────
          if (_isOpen)
            Positioned.fill(
              child: GestureDetector(
                onTap: _close,
                behavior: HitTestBehavior.opaque,
                child: ColoredBox(color: colors.shadow.withValues(alpha: 0.25)),
              ),
            ),

          // ── Fan items ──────────────────────────────────────────
          ..._buildFanItems(colors, angle),

          // ── Main FAB (draggable) ───────────────────────────────
          Positioned(
            left: _position.dx,
            top: _position.dy,
            child: GestureDetector(
              onTap: _toggle,
              onPanUpdate: (d) {
                if (_isOpen) _close();
                setState(() {
                  _position = _clamp(_position + d.delta, screen);
                });
              },
              onPanEnd: (_) => _snapToEdge(screen),
              child: _MainFab(isOpen: _isOpen, colors: colors, size: _fabSize),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildFanItems(SmivoColors colors, double baseAngle) {
    // Skip rendering when fully collapsed for performance.
    if (!_isOpen && _controller.isDismissed) return [];

    final fabCenter = Offset(
      _position.dx + _fabSize / 2,
      _position.dy + _fabSize / 2,
    );
    final count = _items.length;
    final halfSpread = _fanSpread / 2;
    final t = _expandAnimation.value;

    return List.generate(count, (i) {
      final item = _items[i];

      // Distribute evenly across the arc.
      final angleOffset =
          count == 1 ? 0.0 : -halfSpread + (i / (count - 1)) * _fanSpread;
      final angle = baseAngle + angleOffset;

      // Lerp from FAB center to target position.
      final targetX =
          fabCenter.dx + _fanRadius * math.cos(angle) - _miniFabSize / 2;
      final targetY =
          fabCenter.dy + _fanRadius * math.sin(angle) - _miniFabSize / 2;
      final originX = fabCenter.dx - _miniFabSize / 2;
      final originY = fabCenter.dy - _miniFabSize / 2;

      return Positioned(
        left: originX + (targetX - originX) * t,
        top: originY + (targetY - originY) * t,
        child: Opacity(
          // NOTE: easeOutBack overshoots past 1.0; clamp to avoid
          // Opacity assertion failure (red screen flash).
          opacity: t.clamp(0.0, 1.0),
          child: Transform.scale(
            scale: 0.4 + 0.6 * t,
            child: _MiniFab(
              icon: item.icon,
              label: item.label,
              colors: colors,
              size: _miniFabSize,
              onTap: () => _navigateTo(item.routeName),
            ),
          ),
        ),
      );
    });
  }
}

// ── Sub-widgets ──────────────────────────────────────────────────

class _MainFab extends StatelessWidget {
  const _MainFab({
    required this.isOpen,
    required this.colors,
    required this.size,
  });

  final bool isOpen;
  final SmivoColors colors;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: colors.primary,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: colors.primary.withValues(alpha: 0.35),
            blurRadius: isOpen ? 14 : 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: AnimatedRotation(
        turns: isOpen ? 0.125 : 0,
        duration: const Duration(milliseconds: 220),
        child: Icon(Icons.apps_rounded, color: colors.onPrimary, size: 24),
      ),
    );
  }
}

class _MiniFab extends StatelessWidget {
  const _MiniFab({
    required this.icon,
    required this.label,
    required this.colors,
    required this.size,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final SmivoColors colors;
  final double size;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: label,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: colors.primaryContainer,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: colors.shadow.withValues(alpha: 0.15),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Icon(icon, color: colors.primary, size: 20),
        ),
      ),
    );
  }
}

// ── Data class ───────────────────────────────────────────────────

class _NavItem {
  const _NavItem({
    required this.icon,
    required this.label,
    required this.routeName,
  });

  final IconData icon;
  final String label;
  final String routeName;
}

import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smivo/core/router/app_routes.dart';
import 'package:smivo/core/router/router.dart';
import 'package:smivo/core/theme/theme_extensions.dart';

/// A draggable speed-dial button that fans out navigation shortcuts.
///
/// - Draggable to any screen position; snaps to nearest horizontal edge.
/// - Tap to toggle a radial fan of mini icons (Home, Chat, Carpool, Orders).
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
  static const double _fanRadius = 84;

  // NOTE: 4 items spread over 120° → 40° between each button.
  // halfSpread = 60°. For a left-edge FAB, the base angle is clamped
  // to [-30°, +30°] so all items remain in the right half-plane.
  static const double _fanSpread = math.pi * 2 / 3; // 120°

  // ── State ─────────────────────────────────────────────────────
  static Offset _savedPosition = const Offset(12, 100);
  late Offset _position;
  bool _isOpen = false;

  late final AnimationController _controller;
  late final Animation<double> _expandAnimation;

  static const _items = [
    _NavItem(icon: Icons.home_rounded, label: 'Home', routeName: AppRoutes.home),
    _NavItem(icon: Icons.chat_bubble_rounded, label: 'Chat', routeName: AppRoutes.chatList),
    _NavItem(icon: Icons.directions_car_rounded, label: 'Carpool', routeName: AppRoutes.carpoolList),
    _NavItem(icon: Icons.receipt_long_rounded, label: 'Orders', routeName: AppRoutes.orders),
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
    _controller.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _savedPosition = _position;
    _controller.dispose();
    super.dispose();
  }

  void _toggle() {
    _isOpen = !_isOpen;
    _isOpen ? _controller.forward() : _controller.reverse();
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

  /// Computes the ideal angle from the FAB center toward screen center,
  /// then clamps it so ALL fan items stay within the visible screen area.
  ///
  /// NOTE: The FAB only snaps to left or right edges. We use this to
  /// constrain the base angle to the matching open half-plane. This keeps
  /// the fan's arc shape intact (no per-item radius distortion) while
  /// preventing any button from going off-screen in corner positions.
  double _safeBaseAngle(Size screen) {
    final padding = MediaQuery.of(context).padding;
    final fabCx = _position.dx + _fabSize / 2;
    final fabCy = _position.dy + _fabSize / 2;
    final halfSpread = _fanSpread / 2; // 60°
    final r = _fanRadius;
    const itemHalf = _miniFabSize / 2 + 6.0; // item radius + margin

    // Ideal angle: from FAB center toward screen center.
    final screenCenter = Offset(screen.width / 2, screen.height / 2);
    double base = math.atan2(
      screenCenter.dy - fabCy,
      screenCenter.dx - fabCx,
    );

    // ── Horizontal constraint ────────────────────────────────────
    // FAB snaps left or right. Clamp the base angle so all items stay
    // in the half-plane that has room. With halfSpread = 60°:
    //   • Left edge: all items must have cos(angle) ≥ 0
    //     → base ∈ [-90°+60°, +90°-60°] = [-30°, +30°]
    //   • Right edge: all items must have cos(angle) ≤ 0
    //     → base ∈ [150°, 210°]
    final onLeft = fabCx < screen.width / 2;
    if (onLeft) {
      base = base.clamp(-math.pi / 2 + halfSpread, math.pi / 2 - halfSpread);
    } else {
      // Normalize to [0, 2π] for right-side clamping.
      if (base < 0) base += 2 * math.pi;
      base = base.clamp(math.pi / 2 + halfSpread, 3 * math.pi / 2 - halfSpread);
    }

    // ── Vertical constraint ─────────────────────────────────────
    // After horizontal clamping, nudge base if the topmost or bottommost
    // item would still clip a vertical edge (corner positions).
    final safeTop = padding.top + itemHalf;
    final safeBottom = screen.height - padding.bottom - itemHalf;

    // Top-most item has the most negative sin → angle = base - halfSpread.
    final topY = fabCy + r * math.sin(base - halfSpread);
    if (topY < safeTop) {
      // Push base down until topmost item is at safeTop.
      final needed = math.asin(((safeTop - fabCy) / r).clamp(-1.0, 1.0));
      base = needed + halfSpread;
    }

    // Bottom-most item has the most positive sin → angle = base + halfSpread.
    final botY = fabCy + r * math.sin(base + halfSpread);
    if (botY > safeBottom) {
      // Push base up until bottommost item is at safeBottom.
      final needed = math.asin(((safeBottom - fabCy) / r).clamp(-1.0, 1.0));
      base = needed - halfSpread;
    }

    return base;
  }

  // ── Build ─────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final colors = context.smivoColors;
    final screen = MediaQuery.of(context).size;
    final angle = _safeBaseAngle(screen);

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
                child: ColoredBox(
                  color: colors.shadow.withValues(alpha: 0.25),
                ),
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
      final angleOffset =
          count == 1 ? 0.0 : -halfSpread + (i / (count - 1)) * _fanSpread;
      final angle = baseAngle + angleOffset;

      final targetX = fabCenter.dx + _fanRadius * math.cos(angle) - _miniFabSize / 2;
      final targetY = fabCenter.dy + _fanRadius * math.sin(angle) - _miniFabSize / 2;
      final originX = fabCenter.dx - _miniFabSize / 2;
      final originY = fabCenter.dy - _miniFabSize / 2;

      return Positioned(
        left: originX + (targetX - originX) * t,
        top: originY + (targetY - originY) * t,
        child: Opacity(
          // NOTE: easeOutBack overshoots past 1.0; clamp to avoid assertion.
          opacity: t.clamp(0.0, 1.0),
          child: Transform.scale(
            scale: 0.4 + 0.6 * t,
            child: _MiniFab(
              icon: item.icon,
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
  const _MainFab({required this.isOpen, required this.colors, required this.size});

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
    required this.colors,
    required this.size,
    required this.onTap,
  });

  final IconData icon;
  final SmivoColors colors;
  final double size;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    // NOTE: Tooltip is intentionally absent. FloatingQuickNav lives inside
    // MaterialApp.builder in a Stack parallel to the GoRouter Navigator.
    // RawTooltip requires an Overlay ancestor inside Navigator — not reachable
    // from this position in the tree, causing "No Overlay found" in debug mode.
    return GestureDetector(
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
    );
  }
}

// ── Data ─────────────────────────────────────────────────────────

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

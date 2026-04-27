import 'package:flutter/material.dart';

/// Constrains child content to a maximum width, centered horizontally.
///
/// Use this in screens that should not stretch edge-to-edge on wide
/// displays (tablet/desktop). On mobile the constraint has no effect
/// because screen width is already narrower than [maxWidth].
class ContentWidthConstraint extends StatelessWidget {
  const ContentWidthConstraint({
    super.key,
    required this.child,
    // NOTE: 640px is the default — suitable for forms and detail pages.
    // Override per screen: 768 for detail, 960 for lists, 1280 for grids.
    this.maxWidth = 640,
    this.padding,
  });

  final Widget child;
  final double maxWidth;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: padding != null
            ? Padding(padding: padding!, child: child)
            : child,
      ),
    );
  }
}

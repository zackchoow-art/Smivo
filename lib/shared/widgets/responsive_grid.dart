import 'package:flutter/material.dart';
import 'package:smivo/core/theme/breakpoints.dart';

/// Adaptive grid that automatically adjusts column count based on
/// available width using [Breakpoints].
///
/// - Mobile (< 600px): [mobileColumns] columns (default 2)
/// - Tablet (600–1024px): [tabletColumns] columns (default 3)
/// - Desktop (> 1024px): [desktopColumns] columns (default 4)
///
/// Returns a [SliverGrid] so it can be used inside a [CustomScrollView].
class ResponsiveGrid extends StatelessWidget {
  const ResponsiveGrid({
    super.key,
    required this.itemCount,
    required this.itemBuilder,
    this.mobileColumns = 2,
    this.tabletColumns = 3,
    this.desktopColumns = 4,
    this.crossAxisSpacing = 12,
    this.mainAxisSpacing = 12,
    this.childAspectRatio = 1.0,
  });

  final int itemCount;
  final Widget Function(BuildContext context, int index) itemBuilder;
  final int mobileColumns;
  final int tabletColumns;
  final int desktopColumns;
  final double crossAxisSpacing;
  final double mainAxisSpacing;
  final double childAspectRatio;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        // NOTE: Column count scales with available width so items
        // stay a reasonable size on every device class.
        final columns = Breakpoints.isDesktop(width)
            ? desktopColumns
            : Breakpoints.isTablet(width)
                ? tabletColumns
                : mobileColumns;

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            crossAxisSpacing: crossAxisSpacing,
            mainAxisSpacing: mainAxisSpacing,
            childAspectRatio: childAspectRatio,
          ),
          itemCount: itemCount,
          itemBuilder: itemBuilder,
        );
      },
    );
  }
}

/// Sliver version of [ResponsiveGrid] for use inside [CustomScrollView].
class SliverResponsiveGrid extends StatelessWidget {
  const SliverResponsiveGrid({
    super.key,
    required this.itemCount,
    required this.itemBuilder,
    this.mobileColumns = 2,
    this.tabletColumns = 3,
    this.desktopColumns = 4,
    this.crossAxisSpacing = 12,
    this.mainAxisSpacing = 12,
    this.childAspectRatio = 1.0,
  });

  final int itemCount;
  final Widget Function(BuildContext context, int index) itemBuilder;
  final int mobileColumns;
  final int tabletColumns;
  final int desktopColumns;
  final double crossAxisSpacing;
  final double mainAxisSpacing;
  final double childAspectRatio;

  /// Resolves column count based on screen width.
  int _resolveColumns(double width) {
    if (Breakpoints.isDesktop(width)) return desktopColumns;
    if (Breakpoints.isTablet(width)) return tabletColumns;
    return mobileColumns;
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final columns = _resolveColumns(width);

    return SliverGrid(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columns,
        crossAxisSpacing: crossAxisSpacing,
        mainAxisSpacing: mainAxisSpacing,
        childAspectRatio: childAspectRatio,
      ),
      delegate: SliverChildBuilderDelegate(
        itemBuilder,
        childCount: itemCount,
      ),
    );
  }
}

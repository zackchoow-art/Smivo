import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:smivo/core/theme/theme_extensions.dart';

class CollapsingTitleAppBar extends StatelessWidget {
  final String title;
  final String subtitle;

  const CollapsingTitleAppBar({
    super.key,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.smivoColors;
    final typo = context.smivoTypo;

    return SliverAppBar(
      expandedHeight: 160.0,
      pinned: true,
      backgroundColor: colors.surfaceContainerLowest,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        icon: Icon(Icons.arrow_back_ios_new, color: colors.onSurface, size: 20),
        onPressed: () {
          if (context.canPop()) {
            context.pop();
          }
        },
      ),
      flexibleSpace: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          final currentHeight = constraints.biggest.height;
          final minHeight = MediaQuery.of(context).padding.top + kToolbarHeight;
          final maxHeight = 160.0 + MediaQuery.of(context).padding.top;

          final t = (currentHeight - minHeight) / (maxHeight - minHeight);
          // Big title fades out as it scrolls up (t: 1.0 -> 0.3)
          final expandedOpacity = ((t - 0.3) / 0.7).clamp(0.0, 1.0);
          // Small title only fades in at the very end (t: 0.3 -> 0.0)
          final collapsedOpacity = ((0.3 - t) / 0.3).clamp(0.0, 1.0);

          return Stack(
            fit: StackFit.expand,
            children: [
              // Expanded background
              Opacity(
                opacity: expandedOpacity,
                child: Padding(
                  padding: EdgeInsets.only(top: minHeight - 20, left: 24, right: 24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title,
                          style: typo.headlineLarge.copyWith(
                              color: colors.onSurface,
                              fontWeight: FontWeight.w900)),
                      const SizedBox(height: 8),
                      Text(
                        subtitle,
                        textAlign: TextAlign.left,
                        style: typo.bodyMedium.copyWith(
                            color: colors.onSurfaceVariant, height: 1.4),
                      ),
                    ],
                  ),
                ),
              ),
              // Collapsed title
              Positioned(
                bottom: 16,
                left: 0,
                right: 0,
                child: Opacity(
                  opacity: collapsedOpacity,
                  child: Center(
                    child: Text(title,
                        style: typo.headlineSmall.copyWith(
                            color: colors.onSurface,
                            fontSize: 18,
                            fontWeight: FontWeight.w800)),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

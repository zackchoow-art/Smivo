import 'package:flutter/material.dart';
import 'package:smivo/core/theme/breakpoints.dart';
import 'package:smivo/core/theme/theme_extensions.dart';

/// A unified page header used on iPad/Desktop layouts 
/// to replace the standard AppBar for a cleaner, consistent look.
class UnifiedPageHeader extends StatelessWidget {
  const UnifiedPageHeader({
    super.key,
    required this.title,
  });

  final String title;

  @override
  Widget build(BuildContext context) {
    if (Breakpoints.isMobile(MediaQuery.of(context).size.width)) {
      return const SizedBox.shrink();
    }

    final typo = context.smivoTypo;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Text(
        title,
        style: typo.headlineLarge.copyWith(
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

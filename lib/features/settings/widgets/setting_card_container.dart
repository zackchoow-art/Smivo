import 'package:flutter/material.dart';
import 'package:smivo/core/theme/theme_extensions.dart';

class SettingCardContainer extends StatelessWidget {
  final Widget child;

  const SettingCardContainer({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.smivoColors;
    final radius = context.smivoRadius;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.settingsIconBg,
        borderRadius: BorderRadius.circular(radius.md),
      ),
      child: child,
    );
  }
}

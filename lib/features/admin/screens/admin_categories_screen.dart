import 'package:flutter/material.dart';
import 'package:smivo/core/theme/theme_extensions.dart';

class AdminCategoriesScreen extends StatelessWidget {
  const AdminCategoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.smivoColors;
    final typo = context.smivoTypo;

    return Center(
      child: Text(
        'Admin Categories\n(Coming Soon)',
        textAlign: TextAlign.center,
        style: typo.headlineSmall.copyWith(color: colors.onSurfaceVariant),
      ),
    );
  }
}

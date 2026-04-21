import 'package:flutter/material.dart';

import 'package:smivo/core/theme/app_colors.dart';

/// Displays a verified badge next to a user's name.
///
/// Shows a small checkmark icon indicating the user has verified
/// their .edu email. Trust signal per project brief.
class VerifiedBadge extends StatelessWidget {
  const VerifiedBadge({this.size = 16, super.key});

  /// Icon size in logical pixels.
  final double size;

  @override
  Widget build(BuildContext context) {
    return Icon(
      Icons.verified,
      size: size,
      color: AppColors.primary,
      semanticLabel: 'Verified user',
    );
  }
}

import 'package:flutter/material.dart';

/// Consistent loading indicator used across all screens.
///
/// Provides a centered circular progress indicator with the
/// app's primary color. Use this instead of raw CircularProgressIndicator
/// to ensure visual consistency.
class AppLoadingIndicator extends StatelessWidget {
  const AppLoadingIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(child: CircularProgressIndicator.adaptive());
  }
}

import 'package:flutter/material.dart';

class SettingCardContainer extends StatelessWidget {
  final Widget child;

  const SettingCardContainer({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF2EFFF),
        borderRadius: BorderRadius.circular(12),
      ),
      child: child,
    );
  }
}

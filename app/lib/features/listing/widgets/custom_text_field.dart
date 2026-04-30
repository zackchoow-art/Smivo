import 'package:flutter/material.dart';
import 'package:smivo/core/theme/theme_extensions.dart';
import 'package:flutter/services.dart';

class CustomTextField extends StatelessWidget {
  const CustomTextField({
    super.key,
    required this.label,
    required this.hintText,
    this.maxLines = 1,
    this.prefixText,
    this.keyboardType,
    this.inputFormatters,
    this.controller,
  });

  final String label;
  final String hintText;
  final int maxLines;
  final String? prefixText;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final TextEditingController? controller;

  @override
  Widget build(BuildContext context) {
    final colors = context.smivoColors;
    final typo = context.smivoTypo;
    final radius = context.smivoRadius;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: typo.labelLarge.copyWith(
            fontWeight: FontWeight.bold,
            color: colors.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          style: typo.bodyLarge.copyWith(color: colors.onSurface),
          decoration: InputDecoration(
            hintText: hintText,
            prefixText: prefixText != null ? '$prefixText ' : null,
            prefixStyle: typo.bodyLarge.copyWith(
              color: colors.onSurface,
              fontWeight: FontWeight.bold,
            ),
            hintStyle: typo.bodyLarge.copyWith(
              color: colors.onSurfaceVariant.withValues(alpha: 0.6),
            ),
            filled: true,
            fillColor: colors.surfaceContainerLow,
            contentPadding: const EdgeInsets.all(12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(radius.input),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }
}

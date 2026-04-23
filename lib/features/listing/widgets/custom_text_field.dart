import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:smivo/core/theme/app_spacing.dart';
import 'package:smivo/core/theme/app_text_styles.dart';

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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.labelLarge.copyWith(
            fontWeight: FontWeight.bold,
            color: const Color(0xFF2B2A51), // Dark blue
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        TextField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          style: AppTextStyles.bodyLarge.copyWith(
            color: const Color(0xFF2B2A51),
          ),
          decoration: InputDecoration(
            hintText: hintText,
            prefixText: prefixText != null ? '$prefixText ' : null,
            prefixStyle: AppTextStyles.bodyLarge.copyWith(
              color: const Color(0xFF2B2A51),
              fontWeight: FontWeight.bold,
            ),
            hintStyle: AppTextStyles.bodyLarge.copyWith(
              color: const Color(0xFF585781).withValues(alpha: 0.6),
            ),
            filled: true,
            fillColor: const Color(0xFFF2EFFF), // Light purple
            contentPadding: const EdgeInsets.all(AppSpacing.md),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }
}

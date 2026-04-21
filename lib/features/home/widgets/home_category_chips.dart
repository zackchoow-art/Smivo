import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smivo/core/constants/app_constants.dart';
import 'package:smivo/core/theme/app_colors.dart';
import 'package:smivo/core/theme/app_spacing.dart';
import 'package:smivo/core/theme/app_text_styles.dart';
import 'package:smivo/features/home/providers/home_provider.dart';

class HomeCategoryChips extends ConsumerWidget {
  const HomeCategoryChips({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedCategory = ref.watch(selectedCategoryProvider);
    
    // Prepend 'All' to the list of categories
    final categories = ['All', ...AppConstants.categories];

    return SizedBox(
      height: 40,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        separatorBuilder: (context, index) => const SizedBox(width: AppSpacing.sm),
        itemBuilder: (context, index) {
          final category = categories[index];
          final isSelected = selectedCategory == category;
          
          return GestureDetector(
            onTap: () => ref.read(selectedCategoryProvider.notifier).setCategory(category),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                // In screenshot, selected is blue-ish, unselected is light purple-ish.
                // We'll use primary for selected and inputBackground for unselected, matching our color scheme.
                color: isSelected ? const Color(0xFF0546ED) : const Color(0xFFE2E0FF),
                borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
              ),
              child: Text(
                category[0].toUpperCase() + category.substring(1), // Capitalize
                style: AppTextStyles.labelLarge.copyWith(
                  color: isSelected ? AppColors.onPrimary : const Color(0xFF2B2A51),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

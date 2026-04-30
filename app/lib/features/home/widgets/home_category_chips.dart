import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smivo/core/theme/theme_extensions.dart';
import 'package:smivo/features/home/providers/home_provider.dart';
import 'package:smivo/core/providers/theme_provider.dart';
import 'package:smivo/core/theme/theme_variant.dart';
import 'package:smivo/features/shared/providers/school_data_provider.dart';

class HomeCategoryChips extends ConsumerWidget {
  const HomeCategoryChips({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedCategory = ref.watch(selectedCategoryProvider);
    final themeVariant = ref.watch(themeNotifierProvider);
    final colors = context.smivoColors;
    final typo = context.smivoTypo;
    final radius = context.smivoRadius;
    final categoriesAsync = ref.watch(mySchoolCategoriesProvider);

    // NOTE: Build category slug list from DB, with 'All' prepended
    final categories = categoriesAsync.when(
      data: (cats) => ['All', ...cats.map((c) => c.slug)],
      loading: () => ['All'],
      error: (_, __) => ['All'],
    );

    // Build a display name lookup map for pretty labels
    final nameMap = <String, String>{'All': 'All'};
    if (categoriesAsync.hasValue) {
      for (final cat in categoriesAsync.value!) {
        nameMap[cat.slug] = cat.name;
      }
    }

    if (themeVariant == SmivoThemeVariant.teal) {
      final initialIndex = categories.indexOf(selectedCategory);
      return DefaultTabController(
        length: categories.length,
        initialIndex: initialIndex != -1 ? initialIndex : 0,
        child: SizedBox(
          height: 48,
          child: TabBar(
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            onTap:
                (index) => ref
                    .read(selectedCategoryProvider.notifier)
                    .setCategory(categories[index]),
            labelColor: colors.primary,
            unselectedLabelColor: colors.onSurfaceVariant,
            indicatorColor: colors.primary,
            dividerColor: Colors.transparent,
            tabs: categories.map((c) => Tab(text: nameMap[c] ?? c)).toList(),
          ),
        ),
      );
    }

    // IKEA Theme: Keep current chips style
    return SizedBox(
      height: 40,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final category = categories[index];
          final isSelected = selectedCategory == category;

          return GestureDetector(
            onTap:
                () => ref
                    .read(selectedCategoryProvider.notifier)
                    .setCategory(category),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color:
                    isSelected ? colors.primary : colors.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(radius.chip),
              ),
              child: Text(
                nameMap[category] ?? category,
                style: typo.labelLarge.copyWith(
                  color: isSelected ? colors.onPrimary : colors.onSurface,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

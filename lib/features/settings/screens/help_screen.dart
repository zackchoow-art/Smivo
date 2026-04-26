import 'package:flutter/material.dart';
import 'package:smivo/core/theme/theme_extensions.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smivo/data/models/faq.dart';
import 'package:smivo/features/settings/providers/help_provider.dart';
import 'package:smivo/shared/widgets/custom_app_bar.dart';
import 'package:collection/collection.dart'; // For groupBy

class HelpScreen extends ConsumerStatefulWidget {
  const HelpScreen({super.key});

  @override
  ConsumerState<HelpScreen> createState() => _HelpScreenState();
}

class _HelpScreenState extends ConsumerState<HelpScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  final Set<String> _expandedCategories = {};

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final allFaqsAsync = ref.watch(helpFaqsProvider);
    final expandedQuestion = ref.watch(expandedFaqStateProvider);
    final colors = context.smivoColors;
    final typo = context.smivoTypo;
    final radius = context.smivoRadius;

    return Scaffold(
      backgroundColor: colors.surfaceContainerLowest,
      appBar: const CustomAppBar(showActions: false),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text('Help', style: typo.headlineLarge.copyWith(color: colors.onSurface, fontWeight: FontWeight.w900)),
              const SizedBox(height: 16),
              Text('Find answers to common questions\nabout campus trading.',
                textAlign: TextAlign.center,
                style: typo.bodyMedium.copyWith(color: colors.onSurfaceVariant, height: 1.4)),
              const SizedBox(height: 32),
              Container(
                decoration: BoxDecoration(color: colors.settingsIconBg, borderRadius: BorderRadius.circular(radius.card)),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: TextField(
                  controller: _searchController,
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                  style: typo.bodyLarge.copyWith(color: colors.onSurface),
                  decoration: InputDecoration(
                    icon: Icon(Icons.search, color: colors.onSurface.withValues(alpha: 0.5)),
                    hintText: 'Search for help...',
                    hintStyle: typo.bodyLarge.copyWith(color: colors.onSurface.withValues(alpha: 0.5)),
                    border: InputBorder.none,
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: Icon(Icons.clear, color: colors.onSurface.withValues(alpha: 0.5)),
                            onPressed: () {
                              _searchController.clear();
                              setState(() {
                                _searchQuery = '';
                              });
                            },
                          )
                        : null,
                  ),
                ),
              ),
              const SizedBox(height: 32),
              
              allFaqsAsync.when(
                loading: () => const Padding(
                  padding: EdgeInsets.only(top: 64),
                  child: Center(child: CircularProgressIndicator()),
                ),
                error: (e, st) => Padding(
                  padding: const EdgeInsets.only(top: 64),
                  child: Center(
                    child: Text('Failed to load FAQs.', style: typo.bodyMedium.copyWith(color: colors.error)),
                  ),
                ),
                data: (faqs) {
                  final filteredFaqs = _searchQuery.isEmpty
                      ? faqs
                      : faqs.where((faq) {
                          final query = _searchQuery.toLowerCase();
                          return faq.question.toLowerCase().contains(query) ||
                                faq.answer.toLowerCase().contains(query) ||
                                faq.category.toLowerCase().contains(query);
                        }).toList();

                  if (filteredFaqs.isEmpty) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 32),
                      child: Text(
                        'No matching questions found',
                        style: typo.bodyMedium.copyWith(color: colors.onSurfaceVariant),
                      ),
                    );
                  }

                  // Group by category
                  final groupedFaqs = groupBy<Faq, String>(filteredFaqs, (faq) => faq.category);

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: groupedFaqs.entries.map((entry) {
                      final category = entry.key;
                      final categoryFaqs = entry.value;

                      final isCategoryExpanded = _searchQuery.isNotEmpty || _expandedCategories.contains(category);

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          InkWell(
                            onTap: () {
                              setState(() {
                                if (_expandedCategories.contains(category)) {
                                  _expandedCategories.remove(category);
                                } else {
                                  _expandedCategories.add(category);
                                }
                              });
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              child: Row(
                                children: [
                                  Icon(
                                    isCategoryExpanded ? Icons.keyboard_arrow_down : Icons.keyboard_arrow_right,
                                    color: colors.primary,
                                    size: 24,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      category,
                                      style: typo.headlineSmall.copyWith(
                                        color: colors.primary,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: colors.primary.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Text(
                                      categoryFaqs.length.toString(),
                                      style: typo.labelSmall.copyWith(
                                        color: colors.primary,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          if (isCategoryExpanded)
                            ...categoryFaqs.map((faq) {
                              final isExpanded = faq.question == expandedQuestion;
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 16),
                                child: GestureDetector(
                                  onTap: () => ref.read(expandedFaqStateProvider.notifier).toggle(faq.question),
                                  child: Container(
                                  decoration: BoxDecoration(
                                    color: colors.surfaceContainerLowest,
                                    borderRadius: BorderRadius.circular(radius.sm),
                                    border: Border.all(color: isExpanded ? colors.settingsIcon : Colors.transparent, width: 1.5),
                                    boxShadow: [BoxShadow(color: colors.shadow, blurRadius: 10, offset: const Offset(0, 4))],
                                  ),
                                  child: Column(children: [
                                    Padding(
                                      padding: const EdgeInsets.all(20),
                                      child: Row(children: [
                                        Expanded(child: Text(faq.question, style: typo.titleMedium.copyWith(color: colors.onSurface, fontWeight: FontWeight.w800))),
                                        Icon(isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                                          color: isExpanded ? colors.settingsIcon : colors.onSurface.withValues(alpha: 0.5)),
                                      ]),
                                    ),
                                    if (isExpanded)
                                      Padding(
                                        padding: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
                                        child: Text(faq.answer, style: typo.bodyMedium.copyWith(color: colors.onSurfaceVariant, height: 1.4)),
                                      ),
                                  ]),
                                ),
                              ),
                            );
                          }),
                        ],
                      );
                    }).toList(),
                  );
                },
              ),
              const SizedBox(height: 48),
            ],
          ),
        ),
      ),
    );
  }
}

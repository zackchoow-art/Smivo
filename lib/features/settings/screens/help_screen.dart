import 'package:flutter/material.dart';
import 'package:smivo/core/theme/theme_extensions.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smivo/features/settings/providers/help_provider.dart';
import 'package:smivo/shared/widgets/custom_app_bar.dart';

class HelpScreen extends ConsumerStatefulWidget {
  const HelpScreen({super.key});

  @override
  ConsumerState<HelpScreen> createState() => _HelpScreenState();
}

class _HelpScreenState extends ConsumerState<HelpScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final allFaqs = ref.watch(helpFaqsProvider);
    final expandedQuestion = ref.watch(expandedFaqStateProvider);
    final colors = context.smivoColors;
    final typo = context.smivoTypo;
    final radius = context.smivoRadius;

    final filteredFaqs = _searchQuery.isEmpty
        ? allFaqs
        : allFaqs.where((faq) {
            final query = _searchQuery.toLowerCase();
            return faq.question.toLowerCase().contains(query) ||
                   faq.answer.toLowerCase().contains(query);
          }).toList();

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
              if (filteredFaqs.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 32),
                  child: Text(
                    'No matching questions found',
                    style: typo.bodyMedium.copyWith(color: colors.onSurfaceVariant),
                  ),
                )
              else
                ...filteredFaqs.map((faq) {
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
              const SizedBox(height: 48),
            ],
          ),
        ),
      ),
    );
  }
}

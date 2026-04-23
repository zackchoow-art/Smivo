import 'package:flutter/material.dart';
import 'package:smivo/core/theme/theme_extensions.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smivo/features/settings/providers/help_provider.dart';
import 'package:smivo/shared/widgets/custom_app_bar.dart';

class HelpScreen extends ConsumerWidget {
  const HelpScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final faqs = ref.watch(helpFaqsProvider);
    final expandedQuestion = ref.watch(expandedFaqStateProvider);
    final colors = context.smivoColors;
    final typo = context.smivoTypo;
    final radius = context.smivoRadius;

    return Scaffold(
      backgroundColor: colors.surfaceContainerLowest,
      appBar: const CustomAppBar(),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text('Help', style: typo.headlineLarge.copyWith(color: colors.settingsText, fontWeight: FontWeight.w900)),
              const SizedBox(height: 16),
              Text('Find answers to common questions\nabout campus trading.',
                textAlign: TextAlign.center,
                style: typo.bodyMedium.copyWith(color: colors.settingsTextSecondary, height: 1.4)),
              const SizedBox(height: 32),
              Container(
                decoration: BoxDecoration(color: colors.settingsIconBg, borderRadius: BorderRadius.circular(radius.card)),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: TextField(
                  style: typo.bodyLarge.copyWith(color: colors.settingsText),
                  decoration: InputDecoration(
                    icon: Icon(Icons.search, color: colors.settingsText.withValues(alpha: 0.5)),
                    hintText: 'Search for help...',
                    hintStyle: typo.bodyLarge.copyWith(color: colors.settingsText.withValues(alpha: 0.5)),
                    border: InputBorder.none,
                  ),
                ),
              ),
              const SizedBox(height: 32),
              ...faqs.map((faq) {
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
                            Expanded(child: Text(faq.question, style: typo.titleMedium.copyWith(color: colors.settingsText, fontWeight: FontWeight.w800))),
                            Icon(isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                              color: isExpanded ? colors.settingsIcon : colors.settingsText.withValues(alpha: 0.5)),
                          ]),
                        ),
                        if (isExpanded)
                          Padding(
                            padding: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
                            child: Text(faq.answer, style: typo.bodyMedium.copyWith(color: colors.settingsTextSecondary, height: 1.4)),
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

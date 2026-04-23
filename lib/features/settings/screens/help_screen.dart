import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:smivo/core/theme/app_colors.dart';
import 'package:smivo/core/theme/app_text_styles.dart';
import 'package:smivo/features/settings/providers/help_provider.dart';
import 'package:smivo/shared/widgets/custom_app_bar.dart';

class HelpScreen extends ConsumerWidget {
  const HelpScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final faqs = ref.watch(helpFaqsProvider);
    final expandedQuestion = ref.watch(expandedFaqStateProvider);

    return Scaffold(
      backgroundColor: AppColors.surfaceContainerLowest,
      appBar: const CustomAppBar(),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'Help',
                style: AppTextStyles.headlineLarge.copyWith(
                  color: const Color(0xFF2B2A51),
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Find answers to common questions\nabout campus trading.',
                textAlign: TextAlign.center,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: const Color(0xFF2B2A51).withValues(alpha: 0.7),
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 32),
              
              // Search Bar
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFF2EFFF),
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: TextField(
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: const Color(0xFF2B2A51),
                  ),
                  decoration: InputDecoration(
                    icon: Icon(Icons.search, color: const Color(0xFF2B2A51).withValues(alpha: 0.5)),
                    hintText: 'Search for help...',
                    hintStyle: AppTextStyles.bodyLarge.copyWith(
                      color: const Color(0xFF2B2A51).withValues(alpha: 0.5),
                    ),
                    border: InputBorder.none,
                  ),
                ),
              ),
              const SizedBox(height: 32),
              
              // FAQs list
              ...faqs.map((faq) {
                final isExpanded = faq.question == expandedQuestion;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: GestureDetector(
                    onTap: () => ref.read(expandedFaqStateProvider.notifier).toggle(faq.question),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: isExpanded ? Border.all(color: const Color(0xFF013DFD), width: 1.5) : Border.all(color: Colors.transparent, width: 1.5),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.02),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(20),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    faq.question,
                                    style: AppTextStyles.titleMedium.copyWith(
                                      color: const Color(0xFF2B2A51),
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ),
                                Icon(
                                  isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                                  color: isExpanded ? const Color(0xFF013DFD) : const Color(0xFF2B2A51).withValues(alpha: 0.5),
                                ),
                              ],
                            ),
                          ),
                          if (isExpanded)
                            Padding(
                              padding: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
                              child: Text(
                                faq.answer,
                                style: AppTextStyles.bodyMedium.copyWith(
                                  color: const Color(0xFF2B2A51).withValues(alpha: 0.7),
                                  height: 1.4,
                                ),
                              ),
                            ),
                        ],
                      ),
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

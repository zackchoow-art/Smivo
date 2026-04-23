import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'help_provider.g.dart';

class HelpFaq {
  final String question;
  final String answer;

  const HelpFaq({
    required this.question,
    required this.answer,
  });
}

final _faqs = [
  const HelpFaq(
    question: 'How do I pick up items?',
    answer: 'Arrange a safe meeting spot on campus through the in-app chat. We recommend well-lit, public areas like the student union, library, or designated campus exchange zones.',
  ),
  const HelpFaq(
    question: 'Is my .edu email required?',
    answer: 'Yes, to ensure a safe and exclusive campus community, all users must verify a valid university email address before transacting.',
  ),
  const HelpFaq(
    question: 'How do rentals work?',
    answer: 'When renting, you agree to a specific return date. The item remains the seller\'s property and must be returned in its original condition.',
  ),
  const HelpFaq(
    question: 'Are payments secure?',
    answer: 'Currently, payments are handled between students directly (e.g. Venmo, Zelle, or cash). Never send money before seeing the item.',
  ),
  const HelpFaq(
    question: 'What if an item is not as described?',
    answer: 'Please contact the seller through chat to resolve the issue. If you cannot reach an agreement, you can report the listing to our support team.',
  ),
];

@riverpod
class ExpandedFaqState extends _$ExpandedFaqState {
  @override
  String? build() {
    return _faqs.first.question; // First one expanded by default
  }

  void toggle(String question) {
    if (state == question) {
      state = null;
    } else {
      state = question;
    }
  }
}

@riverpod
List<HelpFaq> helpFaqs(Ref ref) {
  return _faqs;
}

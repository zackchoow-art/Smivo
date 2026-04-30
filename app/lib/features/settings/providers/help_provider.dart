import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:smivo/data/models/faq.dart';
import 'package:smivo/data/repositories/faq_repository.dart';

part 'help_provider.g.dart';

@riverpod
Future<List<Faq>> helpFaqs(Ref ref) async {
  return ref.watch(faqRepositoryProvider).fetchFaqs();
}

@riverpod
class ExpandedFaqState extends _$ExpandedFaqState {
  @override
  String? build() {
    return null; // None expanded by default
  }

  void toggle(String question) {
    if (state == question) {
      state = null;
    } else {
      state = question;
    }
  }
}

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:smivo/core/providers/supabase_provider.dart';
import 'package:smivo/data/models/faq.dart';

part 'help_provider.g.dart';

@riverpod
Future<List<Faq>> helpFaqs(Ref ref) async {
  final client = ref.watch(supabaseClientProvider);
  final data = await client
      .from('faqs')
      .select()
      .order('display_order', ascending: true);
      
  return data.map((json) => Faq.fromJson(json)).toList();
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

import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:smivo/core/exceptions/app_exception.dart';
import 'package:smivo/core/providers/supabase_provider.dart';
import 'package:smivo/data/models/faq.dart';

part 'faq_repository.g.dart';

@riverpod
FaqRepository faqRepository(Ref ref) {
  return FaqRepository(ref.watch(supabaseClientProvider));
}

class FaqRepository {
  final SupabaseClient _client;

  FaqRepository(this._client);

  Future<List<Faq>> fetchFaqs() async {
    try {
      final response = await _client
          .from('faqs')
          .select()
          .order('display_order', ascending: true);
      return response.map((json) => Faq.fromJson(json)).toList();
    } on PostgrestException catch (e) {
      throw DatabaseException(e.message);
    } catch (e) {
      throw NetworkException(e.toString());
    }
  }

  /// Fetch FAQs for a specific school, including global (school_id IS NULL).
  Future<List<Faq>> fetchFaqsBySchool(String schoolId) async {
    try {
      final response = await _client
          .from('faqs')
          .select()
          .or('school_id.eq.$schoolId,school_id.is.null')
          .order('display_order', ascending: true);
      return response.map((json) => Faq.fromJson(json)).toList();
    } on PostgrestException catch (e) {
      throw DatabaseException(e.message);
    } catch (e) {
      throw NetworkException(e.toString());
    }
  }

  Future<Faq> createFaq(Faq faq) async {
    try {
      final response =
          await _client
              .from('faqs')
              .insert(faq.toJson()..remove('id')) // DB auto-generates uuid
              .select()
              .single();
      return Faq.fromJson(response);
    } on PostgrestException catch (e) {
      throw DatabaseException(e.message);
    } catch (e) {
      throw NetworkException(e.toString());
    }
  }

  Future<Faq> updateFaq(Faq faq) async {
    try {
      final response =
          await _client
              .from('faqs')
              .update({
                'category': faq.category,
                'question': faq.question,
                'answer': faq.answer,
                'display_order': faq.displayOrder,
                'updated_at': DateTime.now().toIso8601String(),
              })
              .eq('id', faq.id)
              .select()
              .single();
      return Faq.fromJson(response);
    } on PostgrestException catch (e) {
      throw DatabaseException(e.message);
    } catch (e) {
      throw NetworkException(e.toString());
    }
  }

  Future<void> deleteFaq(String id) async {
    try {
      await _client.from('faqs').delete().eq('id', id);
    } on PostgrestException catch (e) {
      throw DatabaseException(e.message);
    } catch (e) {
      throw NetworkException(e.toString());
    }
  }
}

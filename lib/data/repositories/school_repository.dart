import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:smivo/core/exceptions/app_exception.dart';
import 'package:smivo/core/providers/supabase_provider.dart';
import 'package:smivo/data/models/school.dart';

part 'school_repository.g.dart';

/// Handles school-related Supabase operations.
class SchoolRepository {
  const SchoolRepository(this._client);

  final SupabaseClient _client;

  /// Fetches all active schools, used for displaying lists 
  /// and matching email domains at registration.
  ///
  /// Excludes pseudo-schools with slug starting with 
  /// 'smivo-dev' (debug-only domains).
  Future<List<School>> fetchActiveSchools() async {
    try {
      final data = await _client
          .from('schools')
          .select()
          .eq('is_active', true)
          .not('slug', 'like', 'smivo-%')
          .order('name');
      return data.map((json) => School.fromJson(json)).toList();
    } on PostgrestException catch (e) {
      throw DatabaseException(e.message, e);
    }
  }

  /// Fetches a single school by its id.
  Future<School> fetchSchool(String id) async {
    try {
      final data = await _client
          .from('schools')
          .select()
          .eq('id', id)
          .single();
      return School.fromJson(data);
    } on PostgrestException catch (e) {
      throw DatabaseException(e.message, e);
    }
  }
}

@riverpod
SchoolRepository schoolRepository(Ref ref) =>
    SchoolRepository(ref.watch(supabaseClientProvider));

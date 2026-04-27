import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:smivo/core/exceptions/app_exception.dart';
import 'package:smivo/core/providers/supabase_provider.dart';
import 'package:smivo/data/models/pickup_location.dart';
import 'package:smivo/data/models/school_category.dart';
import 'package:smivo/data/models/school_condition.dart';
import 'package:smivo/data/models/system_dictionary.dart';

part 'school_data_repository.g.dart';
@riverpod
SchoolDataRepository schoolDataRepository(Ref ref) {
  return SchoolDataRepository(ref.watch(supabaseClientProvider));
}

/// Repository for school sub-entities: categories, conditions,
/// admins, and system dictionaries. All CRUD operations.
class SchoolDataRepository {
  final SupabaseClient _client;

  SchoolDataRepository(this._client);

  // ── School Categories ──────────────────────────────────────

  Future<List<SchoolCategory>> fetchCategories(String schoolId) async {
    try {
      final data = await _client
          .from('school_categories')
          .select()
          .eq('school_id', schoolId)
          .order('display_order');
      return data.map((e) => SchoolCategory.fromJson(e)).toList();
    } on PostgrestException catch (e) {
      throw DatabaseException(e.message);
    }
  }

  Future<SchoolCategory> upsertCategory(SchoolCategory category) async {
    try {
      final json = category.toJson()
        ..remove('id')
        ..remove('created_at')
        ..remove('updated_at');

      if (category.id.isEmpty) {
        final data = await _client
            .from('school_categories')
            .insert(json)
            .select()
            .single();
        return SchoolCategory.fromJson(data);
      } else {
        final data = await _client
            .from('school_categories')
            .update(json)
            .eq('id', category.id)
            .select()
            .single();
        return SchoolCategory.fromJson(data);
      }
    } on PostgrestException catch (e) {
      throw DatabaseException(e.message);
    }
  }

  Future<void> deleteCategory(String id) async {
    try {
      await _client.from('school_categories').delete().eq('id', id);
    } on PostgrestException catch (e) {
      throw DatabaseException(e.message);
    }
  }

  // ── School Conditions ──────────────────────────────────────

  Future<List<SchoolCondition>> fetchConditions(String schoolId) async {
    try {
      final data = await _client
          .from('school_conditions')
          .select()
          .eq('school_id', schoolId)
          .order('display_order');
      return data.map((e) => SchoolCondition.fromJson(e)).toList();
    } on PostgrestException catch (e) {
      throw DatabaseException(e.message);
    }
  }

  Future<SchoolCondition> upsertCondition(SchoolCondition condition) async {
    try {
      final json = condition.toJson()
        ..remove('id')
        ..remove('created_at')
        ..remove('updated_at');

      if (condition.id.isEmpty) {
        final data = await _client
            .from('school_conditions')
            .insert(json)
            .select()
            .single();
        return SchoolCondition.fromJson(data);
      } else {
        final data = await _client
            .from('school_conditions')
            .update(json)
            .eq('id', condition.id)
            .select()
            .single();
        return SchoolCondition.fromJson(data);
      }
    } on PostgrestException catch (e) {
      throw DatabaseException(e.message);
    }
  }

  Future<void> deleteCondition(String id) async {
    try {
      await _client.from('school_conditions').delete().eq('id', id);
    } on PostgrestException catch (e) {
      throw DatabaseException(e.message);
    }
  }

  // ── School Admins ──────────────────────────────────────────

  Future<List<Map<String, dynamic>>> fetchSchoolAdmins(String schoolId) async {
    try {
      // Fetch admins with user profile info
      final data = await _client
          .from('school_admins')
          .select('*, user:user_profiles(id, email, display_name, avatar_url)')
          .eq('school_id', schoolId)
          .order('created_at');
      return List<Map<String, dynamic>>.from(data);
    } on PostgrestException catch (e) {
      throw DatabaseException(e.message);
    }
  }

  Future<void> addSchoolAdmin({
    required String schoolId,
    required String userId,
    String role = 'admin',
  }) async {
    try {
      await _client.from('school_admins').insert({
        'school_id': schoolId,
        'user_id': userId,
        'role': role,
      });
    } on PostgrestException catch (e) {
      throw DatabaseException(e.message);
    }
  }

  Future<void> removeSchoolAdmin(String id) async {
    try {
      await _client.from('school_admins').delete().eq('id', id);
    } on PostgrestException catch (e) {
      throw DatabaseException(e.message);
    }
  }

  // ── System Dictionaries ────────────────────────────────────

  Future<List<SystemDictionary>> fetchDictionaries({String? dictType}) async {
    try {
      var query = _client
          .from('system_dictionaries')
          .select()
          .order('dict_type')
          .order('display_order');

      if (dictType != null) {
        query = _client
            .from('system_dictionaries')
            .select()
            .eq('dict_type', dictType)
            .order('display_order');
      }

      final data = await query;
      return data.map((e) => SystemDictionary.fromJson(e)).toList();
    } on PostgrestException catch (e) {
      throw DatabaseException(e.message);
    }
  }

  Future<SystemDictionary> upsertDictionary(SystemDictionary dict) async {
    try {
      final json = dict.toJson()
        ..remove('id')
        ..remove('created_at')
        ..remove('updated_at');

      if (dict.id.isEmpty) {
        final data = await _client
            .from('system_dictionaries')
            .insert(json)
            .select()
            .single();
        return SystemDictionary.fromJson(data);
      } else {
        final data = await _client
            .from('system_dictionaries')
            .update(json)
            .eq('id', dict.id)
            .select()
            .single();
        return SystemDictionary.fromJson(data);
      }
    } on PostgrestException catch (e) {
      throw DatabaseException(e.message);
    }
  }

  Future<void> deleteDictionary(String id) async {
    try {
      await _client.from('system_dictionaries').delete().eq('id', id);
    } on PostgrestException catch (e) {
      throw DatabaseException(e.message);
    }
  }

  // ── Pickup Locations ─────────────────────────────────────────

  Future<List<PickupLocation>> fetchPickupLocations(String schoolId) async {
    try {
      final data = await _client
          .from('pickup_locations')
          .select()
          .eq('school_id', schoolId)
          .order('display_order');
      return data.map((e) => PickupLocation.fromJson(e)).toList();
    } on PostgrestException catch (e) {
      throw DatabaseException(e.message);
    }
  }

  Future<PickupLocation> upsertPickupLocation(PickupLocation location) async {
    try {
      final json = location.toJson()
        ..remove('id')
        ..remove('created_at')
        ..remove('updated_at');

      if (location.id.isEmpty) {
        final data = await _client
            .from('pickup_locations')
            .insert(json)
            .select()
            .single();
        return PickupLocation.fromJson(data);
      } else {
        final data = await _client
            .from('pickup_locations')
            .update(json)
            .eq('id', location.id)
            .select()
            .single();
        return PickupLocation.fromJson(data);
      }
    } on PostgrestException catch (e) {
      throw DatabaseException(e.message);
    }
  }

  Future<void> deletePickupLocation(String id) async {
    try {
      await _client.from('pickup_locations').delete().eq('id', id);
    } on PostgrestException catch (e) {
      throw DatabaseException(e.message);
    }
  }

  // ── Seed Defaults RPC ──────────────────────────────────────

  /// Call the seed_school_defaults() function to populate a new
  /// school with default categories, conditions, pickup locations,
  /// and FAQs.
  Future<void> seedSchoolDefaults(String schoolId) async {
    try {
      await _client.rpc('seed_school_defaults', params: {
        'p_school_id': schoolId,
      });
    } on PostgrestException catch (e) {
      throw DatabaseException(e.message);
    }
  }
}

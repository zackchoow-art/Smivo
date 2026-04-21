import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:smivo/core/exceptions/app_exception.dart';
import 'package:smivo/core/providers/supabase_provider.dart';
import 'package:smivo/data/models/pickup_location.dart';

part 'pickup_location_repository.g.dart';

/// Handles pickup location Supabase operations.
class PickupLocationRepository {
  const PickupLocationRepository(this._client);

  final SupabaseClient _client;

  /// Fetches active pickup locations for [schoolId], ordered by display_order.
  Future<List<PickupLocation>> fetchForSchool(String schoolId) async {
    try {
      final data = await _client
          .from('pickup_locations')
          .select()
          .eq('school_id', schoolId)
          .eq('is_active', true)
          .order('display_order');
      return data
          .map((json) => PickupLocation.fromJson(json))
          .toList();
    } on PostgrestException catch (e) {
      throw DatabaseException(e.message, e);
    }
  }
}

@riverpod
PickupLocationRepository pickupLocationRepository(Ref ref) =>
    PickupLocationRepository(ref.watch(supabaseClientProvider));

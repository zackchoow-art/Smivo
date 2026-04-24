import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:smivo/core/providers/supabase_provider.dart';
import 'package:smivo/data/models/rental_extension.dart';

part 'rental_extension_repository.g.dart';

class RentalExtensionRepository {
  RentalExtensionRepository(this._client);
  final SupabaseClient _client;

  /// Fetches all extension requests for an order, newest first.
  Future<List<RentalExtension>> fetchExtensions(String orderId) async {
    final response = await _client
        .from('rental_extensions')
        .select()
        .eq('order_id', orderId)
        .order('created_at', ascending: false);
    return response.map((e) => RentalExtension.fromJson(e)).toList();
  }

  /// Creates a new extension/shortening request.
  Future<RentalExtension> createExtension({
    required String orderId,
    required String requestedBy,
    required String requestType,
    required DateTime originalEndDate,
    required DateTime newEndDate,
    required double priceDiff,
    required double newTotal,
  }) async {
    final response = await _client
        .from('rental_extensions')
        .insert({
          'order_id': orderId,
          'requested_by': requestedBy,
          'request_type': requestType,
          'original_end_date': originalEndDate.toIso8601String(),
          'new_end_date': newEndDate.toIso8601String(),
          'price_diff': priceDiff,
          'new_total': newTotal,
        })
        .select()
        .single();
    return RentalExtension.fromJson(response);
  }

  /// Seller approves an extension request.
  Future<void> approveExtension(String extensionId) async {
    await _client
        .from('rental_extensions')
        .update({'status': 'approved'})
        .eq('id', extensionId);
  }

  /// Seller rejects an extension request.
  Future<void> rejectExtension(String extensionId, {String? note}) async {
    await _client
        .from('rental_extensions')
        .update({
          'status': 'rejected',
          if (note != null) 'rejection_note': note,
        })
        .eq('id', extensionId);
  }
}

@riverpod
RentalExtensionRepository rentalExtensionRepository(Ref ref) =>
    RentalExtensionRepository(ref.watch(supabaseClientProvider));

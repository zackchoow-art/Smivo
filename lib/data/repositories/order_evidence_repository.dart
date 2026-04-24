import 'dart:typed_data';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:smivo/core/constants/app_constants.dart';
import 'package:smivo/core/exceptions/app_exception.dart';
import 'package:smivo/core/providers/supabase_provider.dart';
import 'package:smivo/data/models/order_evidence.dart';

part 'order_evidence_repository.g.dart';

class OrderEvidenceRepository {
  const OrderEvidenceRepository(this._client);
  final SupabaseClient _client;

  /// Fetches all evidence photos for an order.
  Future<List<OrderEvidence>> fetchEvidence(String orderId) async {
    try {
      final data = await _client
          .from(AppConstants.tableOrderEvidence)
          .select('*, uploader:user_profiles!uploader_id(*)')
          .eq('order_id', orderId)
          .order('created_at', ascending: true);
      return data.map((json) => OrderEvidence.fromJson(json)).toList();
    } on PostgrestException catch (e) {
      throw DatabaseException(e.message, e);
    }
  }

  /// Uploads an evidence photo and creates a record.
  Future<OrderEvidence> uploadEvidence({
    required String orderId,
    required String uploaderId,
    required Uint8List imageBytes,
    required String fileName,
    String evidenceType = 'delivery',
    String? caption,
  }) async {
    try {
      // Upload to storage: {orderId}/evidence/{evidenceType}/{uploaderId}/{fileName}
      final path = '$orderId/evidence/$evidenceType/$uploaderId/$fileName';
      await _client.storage
          .from(AppConstants.bucketOrderFiles)
          .uploadBinary(path, imageBytes);

      final imageUrl = _client.storage
          .from(AppConstants.bucketOrderFiles)
          .getPublicUrl(path);

      // Create DB record
      final data = await _client
          .from(AppConstants.tableOrderEvidence)
          .insert({
            'order_id': orderId,
            'uploader_id': uploaderId,
            'image_url': imageUrl,
            'evidence_type': evidenceType,
            'caption': caption,
          })
          .select()
          .single();
      return OrderEvidence.fromJson(data);
    } on PostgrestException catch (e) {
      throw DatabaseException(e.message, e);
    } on StorageException catch (e) {
      throw AppStorageException(e.message, e);
    }
  }
}

@riverpod
OrderEvidenceRepository orderEvidenceRepository(Ref ref) =>
    OrderEvidenceRepository(ref.watch(supabaseClientProvider));

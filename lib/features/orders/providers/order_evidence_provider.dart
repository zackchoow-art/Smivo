import 'dart:typed_data';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:smivo/data/models/order_evidence.dart';
import 'package:smivo/data/repositories/order_evidence_repository.dart';
import 'package:smivo/features/auth/providers/auth_provider.dart';

part 'order_evidence_provider.g.dart';

/// Fetches evidence photos for a specific order.
@riverpod
Future<List<OrderEvidence>> orderEvidence(Ref ref, String orderId) async {
  final repo = ref.watch(orderEvidenceRepositoryProvider);
  return repo.fetchEvidence(orderId);
}

/// Mutation provider for uploading evidence.
@riverpod
class EvidenceUploader extends _$EvidenceUploader {
  @override
  AsyncValue<void> build() => const AsyncValue.data(null);

  Future<void> upload({
    required String orderId,
    required Uint8List imageBytes,
    required String fileName,
    String evidenceType = 'delivery',
    String? caption,
  }) async {
    state = const AsyncValue.loading();
    try {
      final user = ref.read(authStateProvider).valueOrNull;
      if (user == null) throw StateError('Must be logged in');

      final repo = ref.read(orderEvidenceRepositoryProvider);
      await repo.uploadEvidence(
        orderId: orderId,
        uploaderId: user.id,
        imageBytes: imageBytes,
        fileName: fileName,
        evidenceType: evidenceType,
        caption: caption,
      );

      // Refresh the evidence list
      ref.invalidate(orderEvidenceProvider(orderId));
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:smivo/data/models/rental_extension.dart';
import 'package:smivo/data/repositories/rental_extension_repository.dart';
import 'package:smivo/features/orders/providers/orders_provider.dart';

part 'rental_extension_provider.g.dart';

/// Fetches all extension requests for a given order.
@riverpod
Future<List<RentalExtension>> orderExtensions(Ref ref, String orderId) async {
  final repo = ref.watch(rentalExtensionRepositoryProvider);
  return repo.fetchExtensions(orderId);
}

/// Handles extension request actions (create, approve, reject).
@riverpod
class RentalExtensionActions extends _$RentalExtensionActions {
  @override
  FutureOr<void> build() {}

  Future<void> requestExtension({
    required String orderId,
    required String requestedBy,
    required String requestType,
    required DateTime originalEndDate,
    required DateTime newEndDate,
    required double priceDiff,
    required double newTotal,
  }) async {
    state = const AsyncValue.loading();
    try {
      await ref.read(rentalExtensionRepositoryProvider).createExtension(
        orderId: orderId,
        requestedBy: requestedBy,
        requestType: requestType,
        originalEndDate: originalEndDate,
        newEndDate: newEndDate,
        priceDiff: priceDiff,
        newTotal: newTotal,
      );
      state = const AsyncValue.data(null);
      ref.invalidate(orderExtensionsProvider(orderId));
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> approveExtension(String extensionId, String orderId) async {
    state = const AsyncValue.loading();
    try {
      await ref.read(rentalExtensionRepositoryProvider).approveExtension(extensionId);
      state = const AsyncValue.data(null);
      // Refresh both extensions list and order detail (dates/price updated)
      ref.invalidate(orderExtensionsProvider(orderId));
      ref.invalidate(orderDetailProvider(orderId));
      ref.invalidate(allOrdersProvider);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> rejectExtension(String extensionId, String orderId, {String? note}) async {
    state = const AsyncValue.loading();
    try {
      await ref.read(rentalExtensionRepositoryProvider).rejectExtension(extensionId, note: note);
      state = const AsyncValue.data(null);
      ref.invalidate(orderExtensionsProvider(orderId));
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

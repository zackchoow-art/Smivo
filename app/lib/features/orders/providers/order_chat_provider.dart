import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:smivo/data/models/message.dart';
import 'package:smivo/data/repositories/chat_repository.dart';

part 'order_chat_provider.g.dart';

/// Fetches the chat history for a specific chat room.
@riverpod
Future<List<Message>> orderChatMessages(Ref ref, String chatRoomId) async {
  final repo = ref.watch(chatRepositoryProvider);
  return repo.fetchMessages(chatRoomId);
}

/// Finds the chat room for a listing between buyer and seller.
///
/// NOTE: Queries both buyer's and seller's chat rooms to ensure
/// visibility regardless of which party is viewing the order.
@riverpod
Future<String?> orderChatRoomId(
  Ref ref, {
  required String listingId,
  required String buyerId,
  required String sellerId,
}) async {
  final repo = ref.watch(chatRepositoryProvider);
  try {
    // Try buyer's rooms first
    final buyerRooms = await repo.fetchChatRooms(buyerId);
    final match =
        buyerRooms
            .where((r) => r.listingId == listingId && r.sellerId == sellerId)
            .firstOrNull;
    if (match != null) return match.id;

    // Fallback: try seller's rooms (covers case when current user is seller)
    final sellerRooms = await repo.fetchChatRooms(sellerId);
    final sellerMatch =
        sellerRooms
            .where((r) => r.listingId == listingId && r.buyerId == buyerId)
            .firstOrNull;
    return sellerMatch?.id;
  } catch (_) {
    return null;
  }
}

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:smivo/data/models/message.dart';
import 'package:smivo/data/repositories/chat_repository.dart';

part 'order_chat_provider.g.dart';

/// Fetches the chat history for a specific chat room.
@riverpod
Future<List<Message>> orderChatMessages(
  Ref ref,
  String chatRoomId,
) async {
  final repo = ref.watch(chatRepositoryProvider);
  return repo.fetchMessages(chatRoomId);
}

/// Finds the chat room for a listing between buyer and seller.
@riverpod
Future<String?> orderChatRoomId(
  Ref ref, {
  required String listingId,
  required String buyerId,
  required String sellerId,
}) async {
  final repo = ref.watch(chatRepositoryProvider);
  try {
    final rooms = await repo.fetchChatRooms(buyerId);
    final match = rooms.where(
        (r) => r.listingId == listingId && 
               r.sellerId == sellerId).firstOrNull;
    return match?.id;
  } catch (_) {
    return null;
  }
}

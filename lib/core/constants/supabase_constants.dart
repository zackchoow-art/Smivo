/// Supabase-specific constants for column names and storage paths.
///
/// Keeps all Supabase schema references in one place so column renames
/// only require a single edit.
class SupabaseConstants {
  SupabaseConstants._();

  // ── Common Columns ─────────────────────────────────────────
  static const String colId = 'id';
  static const String colCreatedAt = 'created_at';
  static const String colUpdatedAt = 'updated_at';

  // ── user_profiles ──────────────────────────────────────────
  static const String colEmail = 'email';
  static const String colDisplayName = 'display_name';
  static const String colAvatarUrl = 'avatar_url';
  static const String colSchool = 'school';
  static const String colIsVerified = 'is_verified';

  // ── listings ───────────────────────────────────────────────
  static const String colSellerId = 'seller_id';
  static const String colTitle = 'title';
  static const String colDescription = 'description';
  static const String colCategory = 'category';
  static const String colPrice = 'price';
  static const String colTransactionType = 'transaction_type';
  static const String colStatus = 'status';
  static const String colViewCount = 'view_count';

  // ── listing_images ─────────────────────────────────────────
  static const String colListingId = 'listing_id';
  static const String colImageUrl = 'image_url';
  static const String colSortOrder = 'sort_order';

  // ── saved_listings ─────────────────────────────────────────
  static const String colUserId = 'user_id';

  // ── orders ─────────────────────────────────────────────────
  static const String colBuyerId = 'buyer_id';
  static const String colOrderType = 'order_type';
  static const String colRentalStartDate = 'rental_start_date';
  static const String colRentalEndDate = 'rental_end_date';
  static const String colReturnConfirmedAt = 'return_confirmed_at';
  static const String colTotalPrice = 'total_price';

  // ── chat_rooms ─────────────────────────────────────────────
  static const String colLastMessageAt = 'last_message_at';

  // ── messages ───────────────────────────────────────────────
  static const String colChatRoomId = 'chat_room_id';
  static const String colSenderId = 'sender_id';
  static const String colContent = 'content';
  static const String colIsRead = 'is_read';

  // ── Storage Paths ──────────────────────────────────────────
  static const String storageListingPath = 'listings';
  static const String storageAvatarPath = 'avatars';
}

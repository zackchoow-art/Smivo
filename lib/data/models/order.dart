// ignore_for_file: invalid_annotation_target
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:smivo/data/models/user_profile.dart';
import 'package:smivo/data/models/chat_listing_preview.dart';

part 'order.freezed.dart';
part 'order.g.dart';

/// Represents a purchase or rental order.
///
/// Maps to the `orders` table. Rental orders include date range
/// and return confirmation fields.
@freezed
abstract class Order with _$Order {
  const factory Order({
    required String id,
    @JsonKey(name: 'listing_id') required String listingId,
    @JsonKey(name: 'buyer_id') required String buyerId,
    @JsonKey(name: 'seller_id') required String sellerId,
    @JsonKey(name: 'order_type') required String orderType,
    @Default('pending') String status,
    @JsonKey(name: 'school') @Default('Smith College') String school,
    @JsonKey(name: 'rental_start_date') DateTime? rentalStartDate,
    @JsonKey(name: 'rental_end_date') DateTime? rentalEndDate,
    // NOTE: Using DateTime? instead of bool so we record WHEN the item
    // was returned, not just whether it was. null = not yet returned.
    @JsonKey(name: 'return_confirmed_at') DateTime? returnConfirmedAt,
    @JsonKey(name: 'transaction_snapshot_url') String? transactionSnapshotUrl,
    @JsonKey(name: 'delivery_confirmed_by_buyer') @Default(false) bool deliveryConfirmedByBuyer,
    @JsonKey(name: 'delivery_confirmed_by_seller') @Default(false) bool deliveryConfirmedBySeller,
    @JsonKey(name: 'delivery_photo_url') String? deliveryPhotoUrl,
    @JsonKey(name: 'delivery_note') String? deliveryNote,
    @JsonKey(name: 'total_price') required double totalPrice,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    @JsonKey(name: 'updated_at') required DateTime updatedAt,
    
    // Nested join data — populated only by specific join queries
    UserProfile? buyer,
    UserProfile? seller,
    ChatListingPreview? listing,
  }) = _Order;

  factory Order.fromJson(Map<String, dynamic> json) =>
      _$OrderFromJson(json);
}

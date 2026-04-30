// ignore_for_file: invalid_annotation_target
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:smivo/data/models/user_profile.dart';
import 'package:smivo/data/models/order_listing_preview.dart';
import 'package:smivo/data/models/pickup_location.dart';

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
    @JsonKey(name: 'delivery_confirmed_by_buyer')
    @Default(false)
    bool deliveryConfirmedByBuyer,
    @JsonKey(name: 'delivery_confirmed_by_seller')
    @Default(false)
    bool deliveryConfirmedBySeller,
    @JsonKey(name: 'delivery_photo_url') String? deliveryPhotoUrl,
    @JsonKey(name: 'delivery_note') String? deliveryNote,
    @JsonKey(name: 'total_price') required double totalPrice,
    @JsonKey(name: 'deposit_amount') @Default(0.0) double depositAmount,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    @JsonKey(name: 'updated_at') required DateTime updatedAt,
    @JsonKey(name: 'pickup_location_id') String? pickupLocationId,
    @JsonKey(name: 'rental_status') String? rentalStatus,
    @JsonKey(name: 'deposit_refunded_at') DateTime? depositRefundedAt,
    @JsonKey(name: 'return_requested_at') DateTime? returnRequestedAt,

    // Rental reminder preferences
    @JsonKey(name: 'reminder_days_before') @Default(1) int reminderDaysBefore,
    @JsonKey(name: 'reminder_email') @Default(false) bool reminderEmail,
    @JsonKey(name: 'reminder_sent') @Default(false) bool reminderSent,

    // Nested join data — populated only by specific join queries
    UserProfile? buyer,
    UserProfile? seller,
    OrderListingPreview? listing,
    @JsonKey(name: 'pickup_location') PickupLocation? pickupLocation,
  }) = _Order;

  factory Order.fromJson(Map<String, dynamic> json) => _$OrderFromJson(json);
}

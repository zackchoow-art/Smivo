import 'package:freezed_annotation/freezed_annotation.dart';

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
    required String listingId,
    required String buyerId,
    required String sellerId,
    required String orderType,
    @Default('pending') String status,
    DateTime? rentalStartDate,
    DateTime? rentalEndDate,
    // NOTE: Using DateTime? instead of bool so we record WHEN the item
    // was returned, not just whether it was. null = not yet returned.
    DateTime? returnConfirmedAt,
    String? transactionSnapshotUrl,
    @Default(false) bool deliveryConfirmedByBuyer,
    @Default(false) bool deliveryConfirmedBySeller,
    String? deliveryPhotoUrl,
    String? deliveryNote,
    required double totalPrice,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _Order;

  factory Order.fromJson(Map<String, dynamic> json) =>
      _$OrderFromJson(json);
}

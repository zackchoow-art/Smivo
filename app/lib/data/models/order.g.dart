// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'order.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Order _$OrderFromJson(Map<String, dynamic> json) => _Order(
  id: json['id'] as String,
  listingId: json['listing_id'] as String,
  buyerId: json['buyer_id'] as String,
  sellerId: json['seller_id'] as String,
  orderType: json['order_type'] as String,
  status: json['status'] as String? ?? 'pending',
  school: json['school'] as String? ?? 'Smith College',
  rentalStartDate:
      json['rental_start_date'] == null
          ? null
          : DateTime.parse(json['rental_start_date'] as String),
  rentalEndDate:
      json['rental_end_date'] == null
          ? null
          : DateTime.parse(json['rental_end_date'] as String),
  returnConfirmedAt:
      json['return_confirmed_at'] == null
          ? null
          : DateTime.parse(json['return_confirmed_at'] as String),
  transactionSnapshotUrl: json['transaction_snapshot_url'] as String?,
  deliveryConfirmedByBuyer:
      json['delivery_confirmed_by_buyer'] as bool? ?? false,
  deliveryConfirmedBySeller:
      json['delivery_confirmed_by_seller'] as bool? ?? false,
  deliveryPhotoUrl: json['delivery_photo_url'] as String?,
  deliveryNote: json['delivery_note'] as String?,
  totalPrice: (json['total_price'] as num).toDouble(),
  depositAmount: (json['deposit_amount'] as num?)?.toDouble() ?? 0.0,
  createdAt: DateTime.parse(json['created_at'] as String),
  updatedAt: DateTime.parse(json['updated_at'] as String),
  pickupLocationId: json['pickup_location_id'] as String?,
  rentalStatus: json['rental_status'] as String?,
  depositRefundedAt:
      json['deposit_refunded_at'] == null
          ? null
          : DateTime.parse(json['deposit_refunded_at'] as String),
  returnRequestedAt:
      json['return_requested_at'] == null
          ? null
          : DateTime.parse(json['return_requested_at'] as String),
  reminderDaysBefore: (json['reminder_days_before'] as num?)?.toInt() ?? 1,
  reminderEmail: json['reminder_email'] as bool? ?? false,
  reminderSent: json['reminder_sent'] as bool? ?? false,
  buyer:
      json['buyer'] == null
          ? null
          : UserProfile.fromJson(json['buyer'] as Map<String, dynamic>),
  seller:
      json['seller'] == null
          ? null
          : UserProfile.fromJson(json['seller'] as Map<String, dynamic>),
  listing:
      json['listing'] == null
          ? null
          : OrderListingPreview.fromJson(
            json['listing'] as Map<String, dynamic>,
          ),
  pickupLocation:
      json['pickup_location'] == null
          ? null
          : PickupLocation.fromJson(
            json['pickup_location'] as Map<String, dynamic>,
          ),
);

Map<String, dynamic> _$OrderToJson(_Order instance) => <String, dynamic>{
  'id': instance.id,
  'listing_id': instance.listingId,
  'buyer_id': instance.buyerId,
  'seller_id': instance.sellerId,
  'order_type': instance.orderType,
  'status': instance.status,
  'school': instance.school,
  'rental_start_date': instance.rentalStartDate?.toIso8601String(),
  'rental_end_date': instance.rentalEndDate?.toIso8601String(),
  'return_confirmed_at': instance.returnConfirmedAt?.toIso8601String(),
  'transaction_snapshot_url': instance.transactionSnapshotUrl,
  'delivery_confirmed_by_buyer': instance.deliveryConfirmedByBuyer,
  'delivery_confirmed_by_seller': instance.deliveryConfirmedBySeller,
  'delivery_photo_url': instance.deliveryPhotoUrl,
  'delivery_note': instance.deliveryNote,
  'total_price': instance.totalPrice,
  'deposit_amount': instance.depositAmount,
  'created_at': instance.createdAt.toIso8601String(),
  'updated_at': instance.updatedAt.toIso8601String(),
  'pickup_location_id': instance.pickupLocationId,
  'rental_status': instance.rentalStatus,
  'deposit_refunded_at': instance.depositRefundedAt?.toIso8601String(),
  'return_requested_at': instance.returnRequestedAt?.toIso8601String(),
  'reminder_days_before': instance.reminderDaysBefore,
  'reminder_email': instance.reminderEmail,
  'reminder_sent': instance.reminderSent,
  'buyer': instance.buyer,
  'seller': instance.seller,
  'listing': instance.listing,
  'pickup_location': instance.pickupLocation,
};

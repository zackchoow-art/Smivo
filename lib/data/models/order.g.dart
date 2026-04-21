// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'order.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Order _$OrderFromJson(Map<String, dynamic> json) => _Order(
  id: json['id'] as String,
  listingId: json['listingId'] as String,
  buyerId: json['buyerId'] as String,
  sellerId: json['sellerId'] as String,
  orderType: json['orderType'] as String,
  status: json['status'] as String? ?? 'pending',
  rentalStartDate:
      json['rentalStartDate'] == null
          ? null
          : DateTime.parse(json['rentalStartDate'] as String),
  rentalEndDate:
      json['rentalEndDate'] == null
          ? null
          : DateTime.parse(json['rentalEndDate'] as String),
  returnConfirmedAt:
      json['returnConfirmedAt'] == null
          ? null
          : DateTime.parse(json['returnConfirmedAt'] as String),
  transactionSnapshotUrl: json['transactionSnapshotUrl'] as String?,
  deliveryConfirmedByBuyer: json['deliveryConfirmedByBuyer'] as bool? ?? false,
  deliveryConfirmedBySeller:
      json['deliveryConfirmedBySeller'] as bool? ?? false,
  deliveryPhotoUrl: json['deliveryPhotoUrl'] as String?,
  deliveryNote: json['deliveryNote'] as String?,
  totalPrice: (json['totalPrice'] as num).toDouble(),
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$OrderToJson(_Order instance) => <String, dynamic>{
  'id': instance.id,
  'listingId': instance.listingId,
  'buyerId': instance.buyerId,
  'sellerId': instance.sellerId,
  'orderType': instance.orderType,
  'status': instance.status,
  'rentalStartDate': instance.rentalStartDate?.toIso8601String(),
  'rentalEndDate': instance.rentalEndDate?.toIso8601String(),
  'returnConfirmedAt': instance.returnConfirmedAt?.toIso8601String(),
  'transactionSnapshotUrl': instance.transactionSnapshotUrl,
  'deliveryConfirmedByBuyer': instance.deliveryConfirmedByBuyer,
  'deliveryConfirmedBySeller': instance.deliveryConfirmedBySeller,
  'deliveryPhotoUrl': instance.deliveryPhotoUrl,
  'deliveryNote': instance.deliveryNote,
  'totalPrice': instance.totalPrice,
  'createdAt': instance.createdAt.toIso8601String(),
  'updatedAt': instance.updatedAt.toIso8601String(),
};

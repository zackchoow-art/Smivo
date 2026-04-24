// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'rental_extension.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_RentalExtension _$RentalExtensionFromJson(Map<String, dynamic> json) =>
    _RentalExtension(
      id: json['id'] as String,
      orderId: json['order_id'] as String,
      requestedBy: json['requested_by'] as String,
      requestType: json['request_type'] as String,
      originalEndDate: DateTime.parse(json['original_end_date'] as String),
      newEndDate: DateTime.parse(json['new_end_date'] as String),
      priceDiff: (json['price_diff'] as num?)?.toDouble() ?? 0.0,
      newTotal: (json['new_total'] as num).toDouble(),
      status: json['status'] as String? ?? 'pending',
      respondedAt:
          json['responded_at'] == null
              ? null
              : DateTime.parse(json['responded_at'] as String),
      rejectionNote: json['rejection_note'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );

Map<String, dynamic> _$RentalExtensionToJson(_RentalExtension instance) =>
    <String, dynamic>{
      'id': instance.id,
      'order_id': instance.orderId,
      'requested_by': instance.requestedBy,
      'request_type': instance.requestType,
      'original_end_date': instance.originalEndDate.toIso8601String(),
      'new_end_date': instance.newEndDate.toIso8601String(),
      'price_diff': instance.priceDiff,
      'new_total': instance.newTotal,
      'status': instance.status,
      'responded_at': instance.respondedAt?.toIso8601String(),
      'rejection_note': instance.rejectionNote,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
    };

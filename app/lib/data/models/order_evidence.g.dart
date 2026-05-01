// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'order_evidence.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_OrderEvidence _$OrderEvidenceFromJson(Map<String, dynamic> json) =>
    _OrderEvidence(
      id: json['id'] as String,
      orderId: json['order_id'] as String,
      uploaderId: json['uploader_id'] as String,
      imageUrl: json['image_url'] as String,
      evidenceType: json['evidence_type'] as String? ?? 'delivery',
      caption: json['caption'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      uploader:
          json['uploader'] == null
              ? null
              : UserProfile.fromJson(json['uploader'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$OrderEvidenceToJson(_OrderEvidence instance) =>
    <String, dynamic>{
      'id': instance.id,
      'order_id': instance.orderId,
      'uploader_id': instance.uploaderId,
      'image_url': instance.imageUrl,
      'evidence_type': instance.evidenceType,
      'caption': instance.caption,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
      'uploader': instance.uploader,
    };

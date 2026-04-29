// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'listing_image.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ListingImage _$ListingImageFromJson(Map<String, dynamic> json) =>
    _ListingImage(
      id: json['id'] as String,
      listingId: json['listing_id'] as String,
      imageUrl: json['image_url'] as String,
      sortOrder: (json['sort_order'] as num?)?.toInt() ?? 0,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );

Map<String, dynamic> _$ListingImageToJson(_ListingImage instance) =>
    <String, dynamic>{
      'id': instance.id,
      'listing_id': instance.listingId,
      'image_url': instance.imageUrl,
      'sort_order': instance.sortOrder,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
    };

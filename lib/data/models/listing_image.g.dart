// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'listing_image.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ListingImage _$ListingImageFromJson(Map<String, dynamic> json) =>
    _ListingImage(
      id: json['id'] as String,
      listingId: json['listingId'] as String,
      imageUrl: json['imageUrl'] as String,
      sortOrder: (json['sortOrder'] as num?)?.toInt() ?? 0,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$ListingImageToJson(_ListingImage instance) =>
    <String, dynamic>{
      'id': instance.id,
      'listingId': instance.listingId,
      'imageUrl': instance.imageUrl,
      'sortOrder': instance.sortOrder,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };

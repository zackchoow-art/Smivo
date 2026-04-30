// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_listing_preview.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ChatListingPreview _$ChatListingPreviewFromJson(Map<String, dynamic> json) =>
    _ChatListingPreview(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      images:
          (json['images'] as List<dynamic>?)
              ?.map((e) => ChatListingImage.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );

Map<String, dynamic> _$ChatListingPreviewToJson(_ChatListingPreview instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'description': instance.description,
      'price': instance.price,
      'images': instance.images,
    };

_ChatListingImage _$ChatListingImageFromJson(Map<String, dynamic> json) =>
    _ChatListingImage(imageUrl: json['image_url'] as String);

Map<String, dynamic> _$ChatListingImageToJson(_ChatListingImage instance) =>
    <String, dynamic>{'image_url': instance.imageUrl};

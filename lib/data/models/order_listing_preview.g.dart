// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'order_listing_preview.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_OrderListingPreview _$OrderListingPreviewFromJson(Map<String, dynamic> json) =>
    _OrderListingPreview(
      id: json['id'] as String,
      title: json['title'] as String,
      images:
          (json['images'] as List<dynamic>?)
              ?.map(
                (e) => OrderListingImage.fromJson(e as Map<String, dynamic>),
              )
              .toList() ??
          const [],
      rentalDailyPrice: (json['rental_daily_price'] as num?)?.toDouble(),
      rentalWeeklyPrice: (json['rental_weekly_price'] as num?)?.toDouble(),
      rentalMonthlyPrice: (json['rental_monthly_price'] as num?)?.toDouble(),
      depositAmount: (json['deposit_amount'] as num?)?.toDouble() ?? 0.0,
    );

Map<String, dynamic> _$OrderListingPreviewToJson(
  _OrderListingPreview instance,
) => <String, dynamic>{
  'id': instance.id,
  'title': instance.title,
  'images': instance.images,
  'rental_daily_price': instance.rentalDailyPrice,
  'rental_weekly_price': instance.rentalWeeklyPrice,
  'rental_monthly_price': instance.rentalMonthlyPrice,
  'deposit_amount': instance.depositAmount,
};

_OrderListingImage _$OrderListingImageFromJson(Map<String, dynamic> json) =>
    _OrderListingImage(imageUrl: json['image_url'] as String);

Map<String, dynamic> _$OrderListingImageToJson(_OrderListingImage instance) =>
    <String, dynamic>{'image_url': instance.imageUrl};

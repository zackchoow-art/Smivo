// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'listing.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Listing _$ListingFromJson(Map<String, dynamic> json) => _Listing(
  id: json['id'] as String,
  sellerId: json['seller_id'] as String,
  title: json['title'] as String,
  description: json['description'] as String?,
  category: json['category'] as String,
  price: (json['price'] as num).toDouble(),
  transactionType: json['transaction_type'] as String,
  status: json['status'] as String? ?? 'active',
  viewCount: (json['view_count'] as num?)?.toInt() ?? 0,
  saveCount: (json['save_count'] as num?)?.toInt() ?? 0,
  inquiryCount: (json['inquiry_count'] as num?)?.toInt() ?? 0,
  allowPickupChange: json['allow_pickup_change'] as bool? ?? false,
  rentalDailyPrice: (json['rental_daily_price'] as num?)?.toDouble(),
  rentalWeeklyPrice: (json['rental_weekly_price'] as num?)?.toDouble(),
  rentalMonthlyPrice: (json['rental_monthly_price'] as num?)?.toDouble(),
  isPinned: json['is_pinned'] as bool? ?? false,
  pinnedDays: (json['pinned_days'] as num?)?.toInt(),
  images:
      (json['images'] as List<dynamic>?)
          ?.map((e) => ListingImage.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  seller:
      json['seller'] == null
          ? null
          : UserProfile.fromJson(json['seller'] as Map<String, dynamic>),
  createdAt: DateTime.parse(json['created_at'] as String),
  updatedAt: DateTime.parse(json['updated_at'] as String),
);

Map<String, dynamic> _$ListingToJson(_Listing instance) => <String, dynamic>{
  'id': instance.id,
  'seller_id': instance.sellerId,
  'title': instance.title,
  'description': instance.description,
  'category': instance.category,
  'price': instance.price,
  'transaction_type': instance.transactionType,
  'status': instance.status,
  'view_count': instance.viewCount,
  'save_count': instance.saveCount,
  'inquiry_count': instance.inquiryCount,
  'allow_pickup_change': instance.allowPickupChange,
  'rental_daily_price': instance.rentalDailyPrice,
  'rental_weekly_price': instance.rentalWeeklyPrice,
  'rental_monthly_price': instance.rentalMonthlyPrice,
  'is_pinned': instance.isPinned,
  'pinned_days': instance.pinnedDays,
  'images': instance.images,
  'seller': instance.seller,
  'created_at': instance.createdAt.toIso8601String(),
  'updated_at': instance.updatedAt.toIso8601String(),
};

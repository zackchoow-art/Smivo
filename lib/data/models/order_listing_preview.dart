// ignore_for_file: invalid_annotation_target
import 'package:freezed_annotation/freezed_annotation.dart';

part 'order_listing_preview.freezed.dart';
part 'order_listing_preview.g.dart';

/// Listing data embedded in Order for order detail display.
///
/// Includes rental pricing fields so the order detail screen
/// can show which rental rate options are available.
@freezed
abstract class OrderListingPreview with _$OrderListingPreview {
  const factory OrderListingPreview({
    required String id,
    required String title,
    @Default([]) List<OrderListingImage> images,
    @JsonKey(name: 'rental_daily_price') double? rentalDailyPrice,
    @JsonKey(name: 'rental_weekly_price') double? rentalWeeklyPrice,
    @JsonKey(name: 'rental_monthly_price') double? rentalMonthlyPrice,
    @JsonKey(name: 'deposit_amount') @Default(0.0) double depositAmount,
  }) = _OrderListingPreview;

  factory OrderListingPreview.fromJson(Map<String, dynamic> json) =>
      _$OrderListingPreviewFromJson(json);
}

@freezed
abstract class OrderListingImage with _$OrderListingImage {
  const factory OrderListingImage({
    @JsonKey(name: 'image_url') required String imageUrl,
  }) = _OrderListingImage;

  factory OrderListingImage.fromJson(Map<String, dynamic> json) =>
      _$OrderListingImageFromJson(json);
}

// ignore_for_file: invalid_annotation_target
import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:smivo/data/models/listing_image.dart';
import 'package:smivo/data/models/pickup_location.dart';
import 'package:smivo/data/models/user_profile.dart';

part 'listing.freezed.dart';
part 'listing.g.dart';

/// Represents a marketplace listing (sale or rental).
///
/// Maps to the `listings` table. [images] is populated when the
/// query uses a join (e.g., fetchListings or fetchListing).
/// [seller] is only populated on the detail fetch.
@freezed
abstract class Listing with _$Listing {
  const factory Listing({
    required String id,
    @JsonKey(name: 'seller_id') required String sellerId,
    required String title,
    String? description,
    required String category,
    required double price,
    @JsonKey(name: 'transaction_type') required String transactionType,
    @Default('good') String condition,
    @Default('active') String status,
    @JsonKey(name: 'view_count') @Default(0) int viewCount,
    // NOTE: save_count and inquiry_count are server-managed counters;
    // the client reads them but never writes directly.
    @JsonKey(name: 'save_count') @Default(0) int saveCount,
    @JsonKey(name: 'inquiry_count') @Default(0) int inquiryCount,
    @JsonKey(name: 'allow_pickup_change') @Default(false) bool allowPickupChange,
    @JsonKey(name: 'rental_daily_price') double? rentalDailyPrice,
    @JsonKey(name: 'rental_weekly_price') double? rentalWeeklyPrice,
    @JsonKey(name: 'rental_monthly_price') double? rentalMonthlyPrice,
    @JsonKey(name: 'deposit_amount') @Default(0.0) double depositAmount,
    @JsonKey(name: 'is_pinned') @Default(false) bool isPinned,
    @JsonKey(name: 'pinned_days') int? pinnedDays,
    @JsonKey(name: 'school_id') required String schoolId,
    @JsonKey(name: 'pickup_location_id') String? pickupLocationId,
    // NOTE: images is populated from the listing_images join;
    // defaults to empty list when only the listing row is fetched.
    @Default([]) List<ListingImage> images,
    // NOTE: seller is only present on detail fetches that join user_profiles.
    // It is intentionally nullable to support list-view queries.
    UserProfile? seller,
    // Nested join — populated by joining pickup_locations
    @JsonKey(name: 'pickup_location') PickupLocation? pickupLocation,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    @JsonKey(name: 'updated_at') required DateTime updatedAt,
  }) = _Listing;

  factory Listing.fromJson(Map<String, dynamic> json) =>
      _$ListingFromJson(json);
}

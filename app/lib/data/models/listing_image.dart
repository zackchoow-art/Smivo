// ignore_for_file: invalid_annotation_target

import 'package:freezed_annotation/freezed_annotation.dart';

part 'listing_image.freezed.dart';
part 'listing_image.g.dart';

/// Represents a single image attached to a listing.
///
/// Maps to the `listing_images` table. Multiple images per listing,
/// ordered by [sortOrder].
@freezed
abstract class ListingImage with _$ListingImage {
  const factory ListingImage({
    required String id,
    @JsonKey(name: 'listing_id') required String listingId,
    @JsonKey(name: 'image_url') required String imageUrl,
    @JsonKey(name: 'sort_order') @Default(0) int sortOrder,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    @JsonKey(name: 'updated_at') required DateTime updatedAt,
  }) = _ListingImage;

  factory ListingImage.fromJson(Map<String, dynamic> json) =>
      _$ListingImageFromJson(json);
}

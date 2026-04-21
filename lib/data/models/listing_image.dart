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
    required String listingId,
    required String imageUrl,
    @Default(0) int sortOrder,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _ListingImage;

  factory ListingImage.fromJson(Map<String, dynamic> json) =>
      _$ListingImageFromJson(json);
}

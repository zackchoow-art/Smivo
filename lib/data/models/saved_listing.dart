import 'package:freezed_annotation/freezed_annotation.dart';

part 'saved_listing.freezed.dart';
part 'saved_listing.g.dart';

/// Represents a user's saved/bookmarked listing.
///
/// Maps to the `saved_listings` table. Junction table with a
/// unique constraint on (user_id, listing_id).
@freezed
abstract class SavedListing with _$SavedListing {
  const factory SavedListing({
    required String id,
    required String userId,
    required String listingId,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _SavedListing;

  factory SavedListing.fromJson(Map<String, dynamic> json) =>
      _$SavedListingFromJson(json);
}

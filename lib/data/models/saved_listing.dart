// ignore_for_file: invalid_annotation_target
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:smivo/data/models/user_profile.dart';

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
    @JsonKey(name: 'user_id') required String userId,
    @JsonKey(name: 'listing_id') required String listingId,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    @JsonKey(name: 'updated_at') required DateTime updatedAt,
    UserProfile? user,
  }) = _SavedListing;

  factory SavedListing.fromJson(Map<String, dynamic> json) =>
      _$SavedListingFromJson(json);
}

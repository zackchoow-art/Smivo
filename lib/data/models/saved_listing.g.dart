// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'saved_listing.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_SavedListing _$SavedListingFromJson(Map<String, dynamic> json) =>
    _SavedListing(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      listingId: json['listing_id'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      user:
          json['user'] == null
              ? null
              : UserProfile.fromJson(json['user'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$SavedListingToJson(_SavedListing instance) =>
    <String, dynamic>{
      'id': instance.id,
      'user_id': instance.userId,
      'listing_id': instance.listingId,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
      'user': instance.user,
    };

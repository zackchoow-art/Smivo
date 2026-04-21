// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'saved_listing.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_SavedListing _$SavedListingFromJson(Map<String, dynamic> json) =>
    _SavedListing(
      id: json['id'] as String,
      userId: json['userId'] as String,
      listingId: json['listingId'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$SavedListingToJson(_SavedListing instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'listingId': instance.listingId,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };

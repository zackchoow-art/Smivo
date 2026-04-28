// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'content_report.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ContentReport _$ContentReportFromJson(Map<String, dynamic> json) =>
    _ContentReport(
      id: json['id'] as String,
      reporterId: json['reporter_id'] as String,
      reportedUserId: json['reported_user_id'] as String,
      listingId: json['listing_id'] as String?,
      chatRoomId: json['chat_room_id'] as String?,
      reason: json['reason'] as String,
      status: json['status'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      reportedUser:
          json['reported_user'] == null
              ? null
              : UserProfile.fromJson(
                json['reported_user'] as Map<String, dynamic>,
              ),
      listing:
          json['listing'] == null
              ? null
              : Listing.fromJson(json['listing'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$ContentReportToJson(_ContentReport instance) =>
    <String, dynamic>{
      'id': instance.id,
      'reporter_id': instance.reporterId,
      'reported_user_id': instance.reportedUserId,
      'listing_id': instance.listingId,
      'chat_room_id': instance.chatRoomId,
      'reason': instance.reason,
      'status': instance.status,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
      'reported_user': instance.reportedUser,
      'listing': instance.listing,
    };

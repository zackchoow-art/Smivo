// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'carpool_trip.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_CarpoolTrip _$CarpoolTripFromJson(Map<String, dynamic> json) => _CarpoolTrip(
  id: json['id'] as String,
  creatorId: json['creator_id'] as String,
  schoolId: json['school_id'] as String,
  role: json['role'] as String,
  departureAddress: json['departure_address'] as String,
  departureLat: (json['departure_lat'] as num?)?.toDouble(),
  departureLng: (json['departure_lng'] as num?)?.toDouble(),
  departurePlaceId: json['departure_place_id'] as String?,
  destinationAddress: json['destination_address'] as String,
  destinationLat: (json['destination_lat'] as num?)?.toDouble(),
  destinationLng: (json['destination_lng'] as num?)?.toDouble(),
  destinationPlaceId: json['destination_place_id'] as String?,
  departureTime: DateTime.parse(json['departure_time'] as String),
  estimatedArrivalTime:
      json['estimated_arrival_time'] == null
          ? null
          : DateTime.parse(json['estimated_arrival_time'] as String),
  totalSeats: (json['total_seats'] as num).toInt(),
  availableSeats: (json['available_seats'] as num).toInt(),
  luggageLimit: json['luggage_limit'] as String?,
  approvalMode: json['approval_mode'] as String? ?? 'manual',
  status: json['status'] as String? ?? 'active',
  closingTime:
      json['closing_time'] == null
          ? null
          : DateTime.parse(json['closing_time'] as String),
  note: json['note'] as String?,
  departureDescription: json['departure_description'] as String?,
  destinationDescription: json['destination_description'] as String?,
  estimatedTotalPrice: (json['estimated_total_price'] as num?)?.toDouble(),
  createdAt: DateTime.parse(json['created_at'] as String),
  updatedAt: DateTime.parse(json['updated_at'] as String),
  creator:
      json['creator'] == null
          ? null
          : UserProfile.fromJson(json['creator'] as Map<String, dynamic>),
  members:
      (json['members'] as List<dynamic>?)
          ?.map((e) => CarpoolMember.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
);

Map<String, dynamic> _$CarpoolTripToJson(
  _CarpoolTrip instance,
) => <String, dynamic>{
  'id': instance.id,
  'creator_id': instance.creatorId,
  'school_id': instance.schoolId,
  'role': instance.role,
  'departure_address': instance.departureAddress,
  'departure_lat': instance.departureLat,
  'departure_lng': instance.departureLng,
  'departure_place_id': instance.departurePlaceId,
  'destination_address': instance.destinationAddress,
  'destination_lat': instance.destinationLat,
  'destination_lng': instance.destinationLng,
  'destination_place_id': instance.destinationPlaceId,
  'departure_time': instance.departureTime.toIso8601String(),
  'estimated_arrival_time': instance.estimatedArrivalTime?.toIso8601String(),
  'total_seats': instance.totalSeats,
  'available_seats': instance.availableSeats,
  'luggage_limit': instance.luggageLimit,
  'approval_mode': instance.approvalMode,
  'status': instance.status,
  'closing_time': instance.closingTime?.toIso8601String(),
  'note': instance.note,
  'departure_description': instance.departureDescription,
  'destination_description': instance.destinationDescription,
  'estimated_total_price': instance.estimatedTotalPrice,
  'created_at': instance.createdAt.toIso8601String(),
  'updated_at': instance.updatedAt.toIso8601String(),
  'creator': instance.creator,
  'members': instance.members,
};

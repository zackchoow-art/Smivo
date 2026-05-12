// ignore_for_file: invalid_annotation_target
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:smivo/data/models/user_profile.dart';
import 'package:smivo/data/models/carpool_member.dart';

part 'carpool_trip.freezed.dart';
part 'carpool_trip.g.dart';

/// Represents a carpool trip posted by a creator.
///
/// Maps to the `carpool_trips` table. The [role] field indicates whether
/// the creator is driving ('driver') or simply organizing the group
/// without driving ('organizer'). [approvalMode] controls whether
/// join requests are auto-approved or require manual review.
@freezed
abstract class CarpoolTrip with _$CarpoolTrip {
  const factory CarpoolTrip({
    required String id,
    @JsonKey(name: 'creator_id') required String creatorId,
    @JsonKey(name: 'school_id') required String schoolId,
    // NOTE: 'driver' means the creator operates the vehicle;
    // 'organizer' coordinates passengers in a shared ride (e.g. Uber pool).
    required String role,
    @JsonKey(name: 'departure_address') required String departureAddress,
    @JsonKey(name: 'departure_lat') double? departureLat,
    @JsonKey(name: 'departure_lng') double? departureLng,
    @JsonKey(name: 'departure_place_id') String? departurePlaceId,
    @JsonKey(name: 'destination_address') required String destinationAddress,
    @JsonKey(name: 'destination_lat') double? destinationLat,
    @JsonKey(name: 'destination_lng') double? destinationLng,
    @JsonKey(name: 'destination_place_id') String? destinationPlaceId,
    @JsonKey(name: 'departure_time') required DateTime departureTime,
    @JsonKey(name: 'estimated_arrival_time') DateTime? estimatedArrivalTime,
    // NOTE: DB CHECK constraint enforces total_seats between 1 and 9.
    @JsonKey(name: 'total_seats') required int totalSeats,
    @JsonKey(name: 'available_seats') required int availableSeats,
    // NOTE: luggage_limit is advisory only — not enforced by the platform.
    @JsonKey(name: 'luggage_limit') String? luggageLimit,
    @JsonKey(name: 'approval_mode') @Default('manual') String approvalMode,
    @Default('active') String status,
    @JsonKey(name: 'closing_time') DateTime? closingTime,
    String? note,
    // V2 fields — short human-friendly labels for origin/destination
    @JsonKey(name: 'departure_description') String? departureDescription,
    @JsonKey(name: 'destination_description') String? destinationDescription,
    // V2 — estimated total cost for the entire trip
    @JsonKey(name: 'estimated_total_price') double? estimatedTotalPrice,
    // V2 — actual total cost recorded by creator after arrival
    @JsonKey(name: 'actual_total_cost') double? actualTotalCost,
    @JsonKey(name: 'settled_at') DateTime? settledAt,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    @JsonKey(name: 'updated_at') required DateTime updatedAt,

    // Nested join — populated only by specific join queries
    UserProfile? creator,
    @Default([]) List<CarpoolMember> members,
  }) = _CarpoolTrip;

  factory CarpoolTrip.fromJson(Map<String, dynamic> json) =>
      _$CarpoolTripFromJson(json);
}

// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'carpool_trip.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$CarpoolTrip {

 String get id;@JsonKey(name: 'creator_id') String get creatorId;@JsonKey(name: 'school_id') String get schoolId;// NOTE: 'driver' means the creator operates the vehicle;
// 'organizer' coordinates passengers in a shared ride (e.g. Uber pool).
 String get role;@JsonKey(name: 'departure_address') String get departureAddress;@JsonKey(name: 'departure_lat') double? get departureLat;@JsonKey(name: 'departure_lng') double? get departureLng;@JsonKey(name: 'departure_place_id') String? get departurePlaceId;@JsonKey(name: 'destination_address') String get destinationAddress;@JsonKey(name: 'destination_lat') double? get destinationLat;@JsonKey(name: 'destination_lng') double? get destinationLng;@JsonKey(name: 'destination_place_id') String? get destinationPlaceId;@JsonKey(name: 'departure_time') DateTime get departureTime;@JsonKey(name: 'estimated_arrival_time') DateTime? get estimatedArrivalTime;// NOTE: DB CHECK constraint enforces total_seats between 1 and 9.
@JsonKey(name: 'total_seats') int get totalSeats;@JsonKey(name: 'available_seats') int get availableSeats;// NOTE: luggage_limit is advisory only — not enforced by the platform.
@JsonKey(name: 'luggage_limit') String? get luggageLimit;@JsonKey(name: 'approval_mode') String get approvalMode; String get status;@JsonKey(name: 'closing_time') DateTime? get closingTime; String? get note;// V2 fields — short human-friendly labels for origin/destination
@JsonKey(name: 'departure_description') String? get departureDescription;@JsonKey(name: 'destination_description') String? get destinationDescription;// V2 — estimated total cost for the entire trip
@JsonKey(name: 'estimated_total_price') double? get estimatedTotalPrice;// V2 — actual total cost recorded by creator after arrival
@JsonKey(name: 'actual_total_cost') double? get actualTotalCost;@JsonKey(name: 'settled_at') DateTime? get settledAt;@JsonKey(name: 'created_at') DateTime get createdAt;@JsonKey(name: 'updated_at') DateTime get updatedAt;// Nested join — populated only by specific join queries
 UserProfile? get creator; List<CarpoolMember> get members;
/// Create a copy of CarpoolTrip
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CarpoolTripCopyWith<CarpoolTrip> get copyWith => _$CarpoolTripCopyWithImpl<CarpoolTrip>(this as CarpoolTrip, _$identity);

  /// Serializes this CarpoolTrip to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CarpoolTrip&&(identical(other.id, id) || other.id == id)&&(identical(other.creatorId, creatorId) || other.creatorId == creatorId)&&(identical(other.schoolId, schoolId) || other.schoolId == schoolId)&&(identical(other.role, role) || other.role == role)&&(identical(other.departureAddress, departureAddress) || other.departureAddress == departureAddress)&&(identical(other.departureLat, departureLat) || other.departureLat == departureLat)&&(identical(other.departureLng, departureLng) || other.departureLng == departureLng)&&(identical(other.departurePlaceId, departurePlaceId) || other.departurePlaceId == departurePlaceId)&&(identical(other.destinationAddress, destinationAddress) || other.destinationAddress == destinationAddress)&&(identical(other.destinationLat, destinationLat) || other.destinationLat == destinationLat)&&(identical(other.destinationLng, destinationLng) || other.destinationLng == destinationLng)&&(identical(other.destinationPlaceId, destinationPlaceId) || other.destinationPlaceId == destinationPlaceId)&&(identical(other.departureTime, departureTime) || other.departureTime == departureTime)&&(identical(other.estimatedArrivalTime, estimatedArrivalTime) || other.estimatedArrivalTime == estimatedArrivalTime)&&(identical(other.totalSeats, totalSeats) || other.totalSeats == totalSeats)&&(identical(other.availableSeats, availableSeats) || other.availableSeats == availableSeats)&&(identical(other.luggageLimit, luggageLimit) || other.luggageLimit == luggageLimit)&&(identical(other.approvalMode, approvalMode) || other.approvalMode == approvalMode)&&(identical(other.status, status) || other.status == status)&&(identical(other.closingTime, closingTime) || other.closingTime == closingTime)&&(identical(other.note, note) || other.note == note)&&(identical(other.departureDescription, departureDescription) || other.departureDescription == departureDescription)&&(identical(other.destinationDescription, destinationDescription) || other.destinationDescription == destinationDescription)&&(identical(other.estimatedTotalPrice, estimatedTotalPrice) || other.estimatedTotalPrice == estimatedTotalPrice)&&(identical(other.actualTotalCost, actualTotalCost) || other.actualTotalCost == actualTotalCost)&&(identical(other.settledAt, settledAt) || other.settledAt == settledAt)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.creator, creator) || other.creator == creator)&&const DeepCollectionEquality().equals(other.members, members));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,creatorId,schoolId,role,departureAddress,departureLat,departureLng,departurePlaceId,destinationAddress,destinationLat,destinationLng,destinationPlaceId,departureTime,estimatedArrivalTime,totalSeats,availableSeats,luggageLimit,approvalMode,status,closingTime,note,departureDescription,destinationDescription,estimatedTotalPrice,actualTotalCost,settledAt,createdAt,updatedAt,creator,const DeepCollectionEquality().hash(members)]);

@override
String toString() {
  return 'CarpoolTrip(id: $id, creatorId: $creatorId, schoolId: $schoolId, role: $role, departureAddress: $departureAddress, departureLat: $departureLat, departureLng: $departureLng, departurePlaceId: $departurePlaceId, destinationAddress: $destinationAddress, destinationLat: $destinationLat, destinationLng: $destinationLng, destinationPlaceId: $destinationPlaceId, departureTime: $departureTime, estimatedArrivalTime: $estimatedArrivalTime, totalSeats: $totalSeats, availableSeats: $availableSeats, luggageLimit: $luggageLimit, approvalMode: $approvalMode, status: $status, closingTime: $closingTime, note: $note, departureDescription: $departureDescription, destinationDescription: $destinationDescription, estimatedTotalPrice: $estimatedTotalPrice, actualTotalCost: $actualTotalCost, settledAt: $settledAt, createdAt: $createdAt, updatedAt: $updatedAt, creator: $creator, members: $members)';
}


}

/// @nodoc
abstract mixin class $CarpoolTripCopyWith<$Res>  {
  factory $CarpoolTripCopyWith(CarpoolTrip value, $Res Function(CarpoolTrip) _then) = _$CarpoolTripCopyWithImpl;
@useResult
$Res call({
 String id,@JsonKey(name: 'creator_id') String creatorId,@JsonKey(name: 'school_id') String schoolId, String role,@JsonKey(name: 'departure_address') String departureAddress,@JsonKey(name: 'departure_lat') double? departureLat,@JsonKey(name: 'departure_lng') double? departureLng,@JsonKey(name: 'departure_place_id') String? departurePlaceId,@JsonKey(name: 'destination_address') String destinationAddress,@JsonKey(name: 'destination_lat') double? destinationLat,@JsonKey(name: 'destination_lng') double? destinationLng,@JsonKey(name: 'destination_place_id') String? destinationPlaceId,@JsonKey(name: 'departure_time') DateTime departureTime,@JsonKey(name: 'estimated_arrival_time') DateTime? estimatedArrivalTime,@JsonKey(name: 'total_seats') int totalSeats,@JsonKey(name: 'available_seats') int availableSeats,@JsonKey(name: 'luggage_limit') String? luggageLimit,@JsonKey(name: 'approval_mode') String approvalMode, String status,@JsonKey(name: 'closing_time') DateTime? closingTime, String? note,@JsonKey(name: 'departure_description') String? departureDescription,@JsonKey(name: 'destination_description') String? destinationDescription,@JsonKey(name: 'estimated_total_price') double? estimatedTotalPrice,@JsonKey(name: 'actual_total_cost') double? actualTotalCost,@JsonKey(name: 'settled_at') DateTime? settledAt,@JsonKey(name: 'created_at') DateTime createdAt,@JsonKey(name: 'updated_at') DateTime updatedAt, UserProfile? creator, List<CarpoolMember> members
});


$UserProfileCopyWith<$Res>? get creator;

}
/// @nodoc
class _$CarpoolTripCopyWithImpl<$Res>
    implements $CarpoolTripCopyWith<$Res> {
  _$CarpoolTripCopyWithImpl(this._self, this._then);

  final CarpoolTrip _self;
  final $Res Function(CarpoolTrip) _then;

/// Create a copy of CarpoolTrip
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? creatorId = null,Object? schoolId = null,Object? role = null,Object? departureAddress = null,Object? departureLat = freezed,Object? departureLng = freezed,Object? departurePlaceId = freezed,Object? destinationAddress = null,Object? destinationLat = freezed,Object? destinationLng = freezed,Object? destinationPlaceId = freezed,Object? departureTime = null,Object? estimatedArrivalTime = freezed,Object? totalSeats = null,Object? availableSeats = null,Object? luggageLimit = freezed,Object? approvalMode = null,Object? status = null,Object? closingTime = freezed,Object? note = freezed,Object? departureDescription = freezed,Object? destinationDescription = freezed,Object? estimatedTotalPrice = freezed,Object? actualTotalCost = freezed,Object? settledAt = freezed,Object? createdAt = null,Object? updatedAt = null,Object? creator = freezed,Object? members = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,creatorId: null == creatorId ? _self.creatorId : creatorId // ignore: cast_nullable_to_non_nullable
as String,schoolId: null == schoolId ? _self.schoolId : schoolId // ignore: cast_nullable_to_non_nullable
as String,role: null == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as String,departureAddress: null == departureAddress ? _self.departureAddress : departureAddress // ignore: cast_nullable_to_non_nullable
as String,departureLat: freezed == departureLat ? _self.departureLat : departureLat // ignore: cast_nullable_to_non_nullable
as double?,departureLng: freezed == departureLng ? _self.departureLng : departureLng // ignore: cast_nullable_to_non_nullable
as double?,departurePlaceId: freezed == departurePlaceId ? _self.departurePlaceId : departurePlaceId // ignore: cast_nullable_to_non_nullable
as String?,destinationAddress: null == destinationAddress ? _self.destinationAddress : destinationAddress // ignore: cast_nullable_to_non_nullable
as String,destinationLat: freezed == destinationLat ? _self.destinationLat : destinationLat // ignore: cast_nullable_to_non_nullable
as double?,destinationLng: freezed == destinationLng ? _self.destinationLng : destinationLng // ignore: cast_nullable_to_non_nullable
as double?,destinationPlaceId: freezed == destinationPlaceId ? _self.destinationPlaceId : destinationPlaceId // ignore: cast_nullable_to_non_nullable
as String?,departureTime: null == departureTime ? _self.departureTime : departureTime // ignore: cast_nullable_to_non_nullable
as DateTime,estimatedArrivalTime: freezed == estimatedArrivalTime ? _self.estimatedArrivalTime : estimatedArrivalTime // ignore: cast_nullable_to_non_nullable
as DateTime?,totalSeats: null == totalSeats ? _self.totalSeats : totalSeats // ignore: cast_nullable_to_non_nullable
as int,availableSeats: null == availableSeats ? _self.availableSeats : availableSeats // ignore: cast_nullable_to_non_nullable
as int,luggageLimit: freezed == luggageLimit ? _self.luggageLimit : luggageLimit // ignore: cast_nullable_to_non_nullable
as String?,approvalMode: null == approvalMode ? _self.approvalMode : approvalMode // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,closingTime: freezed == closingTime ? _self.closingTime : closingTime // ignore: cast_nullable_to_non_nullable
as DateTime?,note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String?,departureDescription: freezed == departureDescription ? _self.departureDescription : departureDescription // ignore: cast_nullable_to_non_nullable
as String?,destinationDescription: freezed == destinationDescription ? _self.destinationDescription : destinationDescription // ignore: cast_nullable_to_non_nullable
as String?,estimatedTotalPrice: freezed == estimatedTotalPrice ? _self.estimatedTotalPrice : estimatedTotalPrice // ignore: cast_nullable_to_non_nullable
as double?,actualTotalCost: freezed == actualTotalCost ? _self.actualTotalCost : actualTotalCost // ignore: cast_nullable_to_non_nullable
as double?,settledAt: freezed == settledAt ? _self.settledAt : settledAt // ignore: cast_nullable_to_non_nullable
as DateTime?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,creator: freezed == creator ? _self.creator : creator // ignore: cast_nullable_to_non_nullable
as UserProfile?,members: null == members ? _self.members : members // ignore: cast_nullable_to_non_nullable
as List<CarpoolMember>,
  ));
}
/// Create a copy of CarpoolTrip
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$UserProfileCopyWith<$Res>? get creator {
    if (_self.creator == null) {
    return null;
  }

  return $UserProfileCopyWith<$Res>(_self.creator!, (value) {
    return _then(_self.copyWith(creator: value));
  });
}
}


/// Adds pattern-matching-related methods to [CarpoolTrip].
extension CarpoolTripPatterns on CarpoolTrip {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CarpoolTrip value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CarpoolTrip() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CarpoolTrip value)  $default,){
final _that = this;
switch (_that) {
case _CarpoolTrip():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CarpoolTrip value)?  $default,){
final _that = this;
switch (_that) {
case _CarpoolTrip() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'creator_id')  String creatorId, @JsonKey(name: 'school_id')  String schoolId,  String role, @JsonKey(name: 'departure_address')  String departureAddress, @JsonKey(name: 'departure_lat')  double? departureLat, @JsonKey(name: 'departure_lng')  double? departureLng, @JsonKey(name: 'departure_place_id')  String? departurePlaceId, @JsonKey(name: 'destination_address')  String destinationAddress, @JsonKey(name: 'destination_lat')  double? destinationLat, @JsonKey(name: 'destination_lng')  double? destinationLng, @JsonKey(name: 'destination_place_id')  String? destinationPlaceId, @JsonKey(name: 'departure_time')  DateTime departureTime, @JsonKey(name: 'estimated_arrival_time')  DateTime? estimatedArrivalTime, @JsonKey(name: 'total_seats')  int totalSeats, @JsonKey(name: 'available_seats')  int availableSeats, @JsonKey(name: 'luggage_limit')  String? luggageLimit, @JsonKey(name: 'approval_mode')  String approvalMode,  String status, @JsonKey(name: 'closing_time')  DateTime? closingTime,  String? note, @JsonKey(name: 'departure_description')  String? departureDescription, @JsonKey(name: 'destination_description')  String? destinationDescription, @JsonKey(name: 'estimated_total_price')  double? estimatedTotalPrice, @JsonKey(name: 'actual_total_cost')  double? actualTotalCost, @JsonKey(name: 'settled_at')  DateTime? settledAt, @JsonKey(name: 'created_at')  DateTime createdAt, @JsonKey(name: 'updated_at')  DateTime updatedAt,  UserProfile? creator,  List<CarpoolMember> members)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CarpoolTrip() when $default != null:
return $default(_that.id,_that.creatorId,_that.schoolId,_that.role,_that.departureAddress,_that.departureLat,_that.departureLng,_that.departurePlaceId,_that.destinationAddress,_that.destinationLat,_that.destinationLng,_that.destinationPlaceId,_that.departureTime,_that.estimatedArrivalTime,_that.totalSeats,_that.availableSeats,_that.luggageLimit,_that.approvalMode,_that.status,_that.closingTime,_that.note,_that.departureDescription,_that.destinationDescription,_that.estimatedTotalPrice,_that.actualTotalCost,_that.settledAt,_that.createdAt,_that.updatedAt,_that.creator,_that.members);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'creator_id')  String creatorId, @JsonKey(name: 'school_id')  String schoolId,  String role, @JsonKey(name: 'departure_address')  String departureAddress, @JsonKey(name: 'departure_lat')  double? departureLat, @JsonKey(name: 'departure_lng')  double? departureLng, @JsonKey(name: 'departure_place_id')  String? departurePlaceId, @JsonKey(name: 'destination_address')  String destinationAddress, @JsonKey(name: 'destination_lat')  double? destinationLat, @JsonKey(name: 'destination_lng')  double? destinationLng, @JsonKey(name: 'destination_place_id')  String? destinationPlaceId, @JsonKey(name: 'departure_time')  DateTime departureTime, @JsonKey(name: 'estimated_arrival_time')  DateTime? estimatedArrivalTime, @JsonKey(name: 'total_seats')  int totalSeats, @JsonKey(name: 'available_seats')  int availableSeats, @JsonKey(name: 'luggage_limit')  String? luggageLimit, @JsonKey(name: 'approval_mode')  String approvalMode,  String status, @JsonKey(name: 'closing_time')  DateTime? closingTime,  String? note, @JsonKey(name: 'departure_description')  String? departureDescription, @JsonKey(name: 'destination_description')  String? destinationDescription, @JsonKey(name: 'estimated_total_price')  double? estimatedTotalPrice, @JsonKey(name: 'actual_total_cost')  double? actualTotalCost, @JsonKey(name: 'settled_at')  DateTime? settledAt, @JsonKey(name: 'created_at')  DateTime createdAt, @JsonKey(name: 'updated_at')  DateTime updatedAt,  UserProfile? creator,  List<CarpoolMember> members)  $default,) {final _that = this;
switch (_that) {
case _CarpoolTrip():
return $default(_that.id,_that.creatorId,_that.schoolId,_that.role,_that.departureAddress,_that.departureLat,_that.departureLng,_that.departurePlaceId,_that.destinationAddress,_that.destinationLat,_that.destinationLng,_that.destinationPlaceId,_that.departureTime,_that.estimatedArrivalTime,_that.totalSeats,_that.availableSeats,_that.luggageLimit,_that.approvalMode,_that.status,_that.closingTime,_that.note,_that.departureDescription,_that.destinationDescription,_that.estimatedTotalPrice,_that.actualTotalCost,_that.settledAt,_that.createdAt,_that.updatedAt,_that.creator,_that.members);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id, @JsonKey(name: 'creator_id')  String creatorId, @JsonKey(name: 'school_id')  String schoolId,  String role, @JsonKey(name: 'departure_address')  String departureAddress, @JsonKey(name: 'departure_lat')  double? departureLat, @JsonKey(name: 'departure_lng')  double? departureLng, @JsonKey(name: 'departure_place_id')  String? departurePlaceId, @JsonKey(name: 'destination_address')  String destinationAddress, @JsonKey(name: 'destination_lat')  double? destinationLat, @JsonKey(name: 'destination_lng')  double? destinationLng, @JsonKey(name: 'destination_place_id')  String? destinationPlaceId, @JsonKey(name: 'departure_time')  DateTime departureTime, @JsonKey(name: 'estimated_arrival_time')  DateTime? estimatedArrivalTime, @JsonKey(name: 'total_seats')  int totalSeats, @JsonKey(name: 'available_seats')  int availableSeats, @JsonKey(name: 'luggage_limit')  String? luggageLimit, @JsonKey(name: 'approval_mode')  String approvalMode,  String status, @JsonKey(name: 'closing_time')  DateTime? closingTime,  String? note, @JsonKey(name: 'departure_description')  String? departureDescription, @JsonKey(name: 'destination_description')  String? destinationDescription, @JsonKey(name: 'estimated_total_price')  double? estimatedTotalPrice, @JsonKey(name: 'actual_total_cost')  double? actualTotalCost, @JsonKey(name: 'settled_at')  DateTime? settledAt, @JsonKey(name: 'created_at')  DateTime createdAt, @JsonKey(name: 'updated_at')  DateTime updatedAt,  UserProfile? creator,  List<CarpoolMember> members)?  $default,) {final _that = this;
switch (_that) {
case _CarpoolTrip() when $default != null:
return $default(_that.id,_that.creatorId,_that.schoolId,_that.role,_that.departureAddress,_that.departureLat,_that.departureLng,_that.departurePlaceId,_that.destinationAddress,_that.destinationLat,_that.destinationLng,_that.destinationPlaceId,_that.departureTime,_that.estimatedArrivalTime,_that.totalSeats,_that.availableSeats,_that.luggageLimit,_that.approvalMode,_that.status,_that.closingTime,_that.note,_that.departureDescription,_that.destinationDescription,_that.estimatedTotalPrice,_that.actualTotalCost,_that.settledAt,_that.createdAt,_that.updatedAt,_that.creator,_that.members);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CarpoolTrip implements CarpoolTrip {
  const _CarpoolTrip({required this.id, @JsonKey(name: 'creator_id') required this.creatorId, @JsonKey(name: 'school_id') required this.schoolId, required this.role, @JsonKey(name: 'departure_address') required this.departureAddress, @JsonKey(name: 'departure_lat') this.departureLat, @JsonKey(name: 'departure_lng') this.departureLng, @JsonKey(name: 'departure_place_id') this.departurePlaceId, @JsonKey(name: 'destination_address') required this.destinationAddress, @JsonKey(name: 'destination_lat') this.destinationLat, @JsonKey(name: 'destination_lng') this.destinationLng, @JsonKey(name: 'destination_place_id') this.destinationPlaceId, @JsonKey(name: 'departure_time') required this.departureTime, @JsonKey(name: 'estimated_arrival_time') this.estimatedArrivalTime, @JsonKey(name: 'total_seats') required this.totalSeats, @JsonKey(name: 'available_seats') required this.availableSeats, @JsonKey(name: 'luggage_limit') this.luggageLimit, @JsonKey(name: 'approval_mode') this.approvalMode = 'manual', this.status = 'active', @JsonKey(name: 'closing_time') this.closingTime, this.note, @JsonKey(name: 'departure_description') this.departureDescription, @JsonKey(name: 'destination_description') this.destinationDescription, @JsonKey(name: 'estimated_total_price') this.estimatedTotalPrice, @JsonKey(name: 'actual_total_cost') this.actualTotalCost, @JsonKey(name: 'settled_at') this.settledAt, @JsonKey(name: 'created_at') required this.createdAt, @JsonKey(name: 'updated_at') required this.updatedAt, this.creator, final  List<CarpoolMember> members = const []}): _members = members;
  factory _CarpoolTrip.fromJson(Map<String, dynamic> json) => _$CarpoolTripFromJson(json);

@override final  String id;
@override@JsonKey(name: 'creator_id') final  String creatorId;
@override@JsonKey(name: 'school_id') final  String schoolId;
// NOTE: 'driver' means the creator operates the vehicle;
// 'organizer' coordinates passengers in a shared ride (e.g. Uber pool).
@override final  String role;
@override@JsonKey(name: 'departure_address') final  String departureAddress;
@override@JsonKey(name: 'departure_lat') final  double? departureLat;
@override@JsonKey(name: 'departure_lng') final  double? departureLng;
@override@JsonKey(name: 'departure_place_id') final  String? departurePlaceId;
@override@JsonKey(name: 'destination_address') final  String destinationAddress;
@override@JsonKey(name: 'destination_lat') final  double? destinationLat;
@override@JsonKey(name: 'destination_lng') final  double? destinationLng;
@override@JsonKey(name: 'destination_place_id') final  String? destinationPlaceId;
@override@JsonKey(name: 'departure_time') final  DateTime departureTime;
@override@JsonKey(name: 'estimated_arrival_time') final  DateTime? estimatedArrivalTime;
// NOTE: DB CHECK constraint enforces total_seats between 1 and 9.
@override@JsonKey(name: 'total_seats') final  int totalSeats;
@override@JsonKey(name: 'available_seats') final  int availableSeats;
// NOTE: luggage_limit is advisory only — not enforced by the platform.
@override@JsonKey(name: 'luggage_limit') final  String? luggageLimit;
@override@JsonKey(name: 'approval_mode') final  String approvalMode;
@override@JsonKey() final  String status;
@override@JsonKey(name: 'closing_time') final  DateTime? closingTime;
@override final  String? note;
// V2 fields — short human-friendly labels for origin/destination
@override@JsonKey(name: 'departure_description') final  String? departureDescription;
@override@JsonKey(name: 'destination_description') final  String? destinationDescription;
// V2 — estimated total cost for the entire trip
@override@JsonKey(name: 'estimated_total_price') final  double? estimatedTotalPrice;
// V2 — actual total cost recorded by creator after arrival
@override@JsonKey(name: 'actual_total_cost') final  double? actualTotalCost;
@override@JsonKey(name: 'settled_at') final  DateTime? settledAt;
@override@JsonKey(name: 'created_at') final  DateTime createdAt;
@override@JsonKey(name: 'updated_at') final  DateTime updatedAt;
// Nested join — populated only by specific join queries
@override final  UserProfile? creator;
 final  List<CarpoolMember> _members;
@override@JsonKey() List<CarpoolMember> get members {
  if (_members is EqualUnmodifiableListView) return _members;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_members);
}


/// Create a copy of CarpoolTrip
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CarpoolTripCopyWith<_CarpoolTrip> get copyWith => __$CarpoolTripCopyWithImpl<_CarpoolTrip>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CarpoolTripToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CarpoolTrip&&(identical(other.id, id) || other.id == id)&&(identical(other.creatorId, creatorId) || other.creatorId == creatorId)&&(identical(other.schoolId, schoolId) || other.schoolId == schoolId)&&(identical(other.role, role) || other.role == role)&&(identical(other.departureAddress, departureAddress) || other.departureAddress == departureAddress)&&(identical(other.departureLat, departureLat) || other.departureLat == departureLat)&&(identical(other.departureLng, departureLng) || other.departureLng == departureLng)&&(identical(other.departurePlaceId, departurePlaceId) || other.departurePlaceId == departurePlaceId)&&(identical(other.destinationAddress, destinationAddress) || other.destinationAddress == destinationAddress)&&(identical(other.destinationLat, destinationLat) || other.destinationLat == destinationLat)&&(identical(other.destinationLng, destinationLng) || other.destinationLng == destinationLng)&&(identical(other.destinationPlaceId, destinationPlaceId) || other.destinationPlaceId == destinationPlaceId)&&(identical(other.departureTime, departureTime) || other.departureTime == departureTime)&&(identical(other.estimatedArrivalTime, estimatedArrivalTime) || other.estimatedArrivalTime == estimatedArrivalTime)&&(identical(other.totalSeats, totalSeats) || other.totalSeats == totalSeats)&&(identical(other.availableSeats, availableSeats) || other.availableSeats == availableSeats)&&(identical(other.luggageLimit, luggageLimit) || other.luggageLimit == luggageLimit)&&(identical(other.approvalMode, approvalMode) || other.approvalMode == approvalMode)&&(identical(other.status, status) || other.status == status)&&(identical(other.closingTime, closingTime) || other.closingTime == closingTime)&&(identical(other.note, note) || other.note == note)&&(identical(other.departureDescription, departureDescription) || other.departureDescription == departureDescription)&&(identical(other.destinationDescription, destinationDescription) || other.destinationDescription == destinationDescription)&&(identical(other.estimatedTotalPrice, estimatedTotalPrice) || other.estimatedTotalPrice == estimatedTotalPrice)&&(identical(other.actualTotalCost, actualTotalCost) || other.actualTotalCost == actualTotalCost)&&(identical(other.settledAt, settledAt) || other.settledAt == settledAt)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.creator, creator) || other.creator == creator)&&const DeepCollectionEquality().equals(other._members, _members));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,creatorId,schoolId,role,departureAddress,departureLat,departureLng,departurePlaceId,destinationAddress,destinationLat,destinationLng,destinationPlaceId,departureTime,estimatedArrivalTime,totalSeats,availableSeats,luggageLimit,approvalMode,status,closingTime,note,departureDescription,destinationDescription,estimatedTotalPrice,actualTotalCost,settledAt,createdAt,updatedAt,creator,const DeepCollectionEquality().hash(_members)]);

@override
String toString() {
  return 'CarpoolTrip(id: $id, creatorId: $creatorId, schoolId: $schoolId, role: $role, departureAddress: $departureAddress, departureLat: $departureLat, departureLng: $departureLng, departurePlaceId: $departurePlaceId, destinationAddress: $destinationAddress, destinationLat: $destinationLat, destinationLng: $destinationLng, destinationPlaceId: $destinationPlaceId, departureTime: $departureTime, estimatedArrivalTime: $estimatedArrivalTime, totalSeats: $totalSeats, availableSeats: $availableSeats, luggageLimit: $luggageLimit, approvalMode: $approvalMode, status: $status, closingTime: $closingTime, note: $note, departureDescription: $departureDescription, destinationDescription: $destinationDescription, estimatedTotalPrice: $estimatedTotalPrice, actualTotalCost: $actualTotalCost, settledAt: $settledAt, createdAt: $createdAt, updatedAt: $updatedAt, creator: $creator, members: $members)';
}


}

/// @nodoc
abstract mixin class _$CarpoolTripCopyWith<$Res> implements $CarpoolTripCopyWith<$Res> {
  factory _$CarpoolTripCopyWith(_CarpoolTrip value, $Res Function(_CarpoolTrip) _then) = __$CarpoolTripCopyWithImpl;
@override @useResult
$Res call({
 String id,@JsonKey(name: 'creator_id') String creatorId,@JsonKey(name: 'school_id') String schoolId, String role,@JsonKey(name: 'departure_address') String departureAddress,@JsonKey(name: 'departure_lat') double? departureLat,@JsonKey(name: 'departure_lng') double? departureLng,@JsonKey(name: 'departure_place_id') String? departurePlaceId,@JsonKey(name: 'destination_address') String destinationAddress,@JsonKey(name: 'destination_lat') double? destinationLat,@JsonKey(name: 'destination_lng') double? destinationLng,@JsonKey(name: 'destination_place_id') String? destinationPlaceId,@JsonKey(name: 'departure_time') DateTime departureTime,@JsonKey(name: 'estimated_arrival_time') DateTime? estimatedArrivalTime,@JsonKey(name: 'total_seats') int totalSeats,@JsonKey(name: 'available_seats') int availableSeats,@JsonKey(name: 'luggage_limit') String? luggageLimit,@JsonKey(name: 'approval_mode') String approvalMode, String status,@JsonKey(name: 'closing_time') DateTime? closingTime, String? note,@JsonKey(name: 'departure_description') String? departureDescription,@JsonKey(name: 'destination_description') String? destinationDescription,@JsonKey(name: 'estimated_total_price') double? estimatedTotalPrice,@JsonKey(name: 'actual_total_cost') double? actualTotalCost,@JsonKey(name: 'settled_at') DateTime? settledAt,@JsonKey(name: 'created_at') DateTime createdAt,@JsonKey(name: 'updated_at') DateTime updatedAt, UserProfile? creator, List<CarpoolMember> members
});


@override $UserProfileCopyWith<$Res>? get creator;

}
/// @nodoc
class __$CarpoolTripCopyWithImpl<$Res>
    implements _$CarpoolTripCopyWith<$Res> {
  __$CarpoolTripCopyWithImpl(this._self, this._then);

  final _CarpoolTrip _self;
  final $Res Function(_CarpoolTrip) _then;

/// Create a copy of CarpoolTrip
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? creatorId = null,Object? schoolId = null,Object? role = null,Object? departureAddress = null,Object? departureLat = freezed,Object? departureLng = freezed,Object? departurePlaceId = freezed,Object? destinationAddress = null,Object? destinationLat = freezed,Object? destinationLng = freezed,Object? destinationPlaceId = freezed,Object? departureTime = null,Object? estimatedArrivalTime = freezed,Object? totalSeats = null,Object? availableSeats = null,Object? luggageLimit = freezed,Object? approvalMode = null,Object? status = null,Object? closingTime = freezed,Object? note = freezed,Object? departureDescription = freezed,Object? destinationDescription = freezed,Object? estimatedTotalPrice = freezed,Object? actualTotalCost = freezed,Object? settledAt = freezed,Object? createdAt = null,Object? updatedAt = null,Object? creator = freezed,Object? members = null,}) {
  return _then(_CarpoolTrip(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,creatorId: null == creatorId ? _self.creatorId : creatorId // ignore: cast_nullable_to_non_nullable
as String,schoolId: null == schoolId ? _self.schoolId : schoolId // ignore: cast_nullable_to_non_nullable
as String,role: null == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as String,departureAddress: null == departureAddress ? _self.departureAddress : departureAddress // ignore: cast_nullable_to_non_nullable
as String,departureLat: freezed == departureLat ? _self.departureLat : departureLat // ignore: cast_nullable_to_non_nullable
as double?,departureLng: freezed == departureLng ? _self.departureLng : departureLng // ignore: cast_nullable_to_non_nullable
as double?,departurePlaceId: freezed == departurePlaceId ? _self.departurePlaceId : departurePlaceId // ignore: cast_nullable_to_non_nullable
as String?,destinationAddress: null == destinationAddress ? _self.destinationAddress : destinationAddress // ignore: cast_nullable_to_non_nullable
as String,destinationLat: freezed == destinationLat ? _self.destinationLat : destinationLat // ignore: cast_nullable_to_non_nullable
as double?,destinationLng: freezed == destinationLng ? _self.destinationLng : destinationLng // ignore: cast_nullable_to_non_nullable
as double?,destinationPlaceId: freezed == destinationPlaceId ? _self.destinationPlaceId : destinationPlaceId // ignore: cast_nullable_to_non_nullable
as String?,departureTime: null == departureTime ? _self.departureTime : departureTime // ignore: cast_nullable_to_non_nullable
as DateTime,estimatedArrivalTime: freezed == estimatedArrivalTime ? _self.estimatedArrivalTime : estimatedArrivalTime // ignore: cast_nullable_to_non_nullable
as DateTime?,totalSeats: null == totalSeats ? _self.totalSeats : totalSeats // ignore: cast_nullable_to_non_nullable
as int,availableSeats: null == availableSeats ? _self.availableSeats : availableSeats // ignore: cast_nullable_to_non_nullable
as int,luggageLimit: freezed == luggageLimit ? _self.luggageLimit : luggageLimit // ignore: cast_nullable_to_non_nullable
as String?,approvalMode: null == approvalMode ? _self.approvalMode : approvalMode // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,closingTime: freezed == closingTime ? _self.closingTime : closingTime // ignore: cast_nullable_to_non_nullable
as DateTime?,note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String?,departureDescription: freezed == departureDescription ? _self.departureDescription : departureDescription // ignore: cast_nullable_to_non_nullable
as String?,destinationDescription: freezed == destinationDescription ? _self.destinationDescription : destinationDescription // ignore: cast_nullable_to_non_nullable
as String?,estimatedTotalPrice: freezed == estimatedTotalPrice ? _self.estimatedTotalPrice : estimatedTotalPrice // ignore: cast_nullable_to_non_nullable
as double?,actualTotalCost: freezed == actualTotalCost ? _self.actualTotalCost : actualTotalCost // ignore: cast_nullable_to_non_nullable
as double?,settledAt: freezed == settledAt ? _self.settledAt : settledAt // ignore: cast_nullable_to_non_nullable
as DateTime?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,creator: freezed == creator ? _self.creator : creator // ignore: cast_nullable_to_non_nullable
as UserProfile?,members: null == members ? _self._members : members // ignore: cast_nullable_to_non_nullable
as List<CarpoolMember>,
  ));
}

/// Create a copy of CarpoolTrip
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$UserProfileCopyWith<$Res>? get creator {
    if (_self.creator == null) {
    return null;
  }

  return $UserProfileCopyWith<$Res>(_self.creator!, (value) {
    return _then(_self.copyWith(creator: value));
  });
}
}

// dart format on

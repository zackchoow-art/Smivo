// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'carpool_proposal.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$CarpoolProposal {

 String get id;@JsonKey(name: 'trip_id') String get tripId;@JsonKey(name: 'proposer_id') String get proposerId;// NOTE: proposal_type drives which fields are relevant:
//   'kick_member'       → target_user_id is required
//   'change_time'       → old_value/new_value are ISO-8601 strings
//   'change_departure'  → old_value/new_value are address strings
//   'change_destination'→ old_value/new_value are address strings
@JsonKey(name: 'proposal_type') String get proposalType;@JsonKey(name: 'old_value') String? get oldValue;@JsonKey(name: 'new_value') String? get newValue;@JsonKey(name: 'target_user_id') String? get targetUserId; String get status;@JsonKey(name: 'required_votes') int get requiredVotes;@JsonKey(name: 'current_votes') int get currentVotes;@JsonKey(name: 'expires_at') DateTime? get expiresAt;@JsonKey(name: 'created_at') DateTime get createdAt;@JsonKey(name: 'updated_at') DateTime get updatedAt;
/// Create a copy of CarpoolProposal
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CarpoolProposalCopyWith<CarpoolProposal> get copyWith => _$CarpoolProposalCopyWithImpl<CarpoolProposal>(this as CarpoolProposal, _$identity);

  /// Serializes this CarpoolProposal to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CarpoolProposal&&(identical(other.id, id) || other.id == id)&&(identical(other.tripId, tripId) || other.tripId == tripId)&&(identical(other.proposerId, proposerId) || other.proposerId == proposerId)&&(identical(other.proposalType, proposalType) || other.proposalType == proposalType)&&(identical(other.oldValue, oldValue) || other.oldValue == oldValue)&&(identical(other.newValue, newValue) || other.newValue == newValue)&&(identical(other.targetUserId, targetUserId) || other.targetUserId == targetUserId)&&(identical(other.status, status) || other.status == status)&&(identical(other.requiredVotes, requiredVotes) || other.requiredVotes == requiredVotes)&&(identical(other.currentVotes, currentVotes) || other.currentVotes == currentVotes)&&(identical(other.expiresAt, expiresAt) || other.expiresAt == expiresAt)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,tripId,proposerId,proposalType,oldValue,newValue,targetUserId,status,requiredVotes,currentVotes,expiresAt,createdAt,updatedAt);

@override
String toString() {
  return 'CarpoolProposal(id: $id, tripId: $tripId, proposerId: $proposerId, proposalType: $proposalType, oldValue: $oldValue, newValue: $newValue, targetUserId: $targetUserId, status: $status, requiredVotes: $requiredVotes, currentVotes: $currentVotes, expiresAt: $expiresAt, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $CarpoolProposalCopyWith<$Res>  {
  factory $CarpoolProposalCopyWith(CarpoolProposal value, $Res Function(CarpoolProposal) _then) = _$CarpoolProposalCopyWithImpl;
@useResult
$Res call({
 String id,@JsonKey(name: 'trip_id') String tripId,@JsonKey(name: 'proposer_id') String proposerId,@JsonKey(name: 'proposal_type') String proposalType,@JsonKey(name: 'old_value') String? oldValue,@JsonKey(name: 'new_value') String? newValue,@JsonKey(name: 'target_user_id') String? targetUserId, String status,@JsonKey(name: 'required_votes') int requiredVotes,@JsonKey(name: 'current_votes') int currentVotes,@JsonKey(name: 'expires_at') DateTime? expiresAt,@JsonKey(name: 'created_at') DateTime createdAt,@JsonKey(name: 'updated_at') DateTime updatedAt
});




}
/// @nodoc
class _$CarpoolProposalCopyWithImpl<$Res>
    implements $CarpoolProposalCopyWith<$Res> {
  _$CarpoolProposalCopyWithImpl(this._self, this._then);

  final CarpoolProposal _self;
  final $Res Function(CarpoolProposal) _then;

/// Create a copy of CarpoolProposal
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? tripId = null,Object? proposerId = null,Object? proposalType = null,Object? oldValue = freezed,Object? newValue = freezed,Object? targetUserId = freezed,Object? status = null,Object? requiredVotes = null,Object? currentVotes = null,Object? expiresAt = freezed,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,tripId: null == tripId ? _self.tripId : tripId // ignore: cast_nullable_to_non_nullable
as String,proposerId: null == proposerId ? _self.proposerId : proposerId // ignore: cast_nullable_to_non_nullable
as String,proposalType: null == proposalType ? _self.proposalType : proposalType // ignore: cast_nullable_to_non_nullable
as String,oldValue: freezed == oldValue ? _self.oldValue : oldValue // ignore: cast_nullable_to_non_nullable
as String?,newValue: freezed == newValue ? _self.newValue : newValue // ignore: cast_nullable_to_non_nullable
as String?,targetUserId: freezed == targetUserId ? _self.targetUserId : targetUserId // ignore: cast_nullable_to_non_nullable
as String?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,requiredVotes: null == requiredVotes ? _self.requiredVotes : requiredVotes // ignore: cast_nullable_to_non_nullable
as int,currentVotes: null == currentVotes ? _self.currentVotes : currentVotes // ignore: cast_nullable_to_non_nullable
as int,expiresAt: freezed == expiresAt ? _self.expiresAt : expiresAt // ignore: cast_nullable_to_non_nullable
as DateTime?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [CarpoolProposal].
extension CarpoolProposalPatterns on CarpoolProposal {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CarpoolProposal value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CarpoolProposal() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CarpoolProposal value)  $default,){
final _that = this;
switch (_that) {
case _CarpoolProposal():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CarpoolProposal value)?  $default,){
final _that = this;
switch (_that) {
case _CarpoolProposal() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'trip_id')  String tripId, @JsonKey(name: 'proposer_id')  String proposerId, @JsonKey(name: 'proposal_type')  String proposalType, @JsonKey(name: 'old_value')  String? oldValue, @JsonKey(name: 'new_value')  String? newValue, @JsonKey(name: 'target_user_id')  String? targetUserId,  String status, @JsonKey(name: 'required_votes')  int requiredVotes, @JsonKey(name: 'current_votes')  int currentVotes, @JsonKey(name: 'expires_at')  DateTime? expiresAt, @JsonKey(name: 'created_at')  DateTime createdAt, @JsonKey(name: 'updated_at')  DateTime updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CarpoolProposal() when $default != null:
return $default(_that.id,_that.tripId,_that.proposerId,_that.proposalType,_that.oldValue,_that.newValue,_that.targetUserId,_that.status,_that.requiredVotes,_that.currentVotes,_that.expiresAt,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'trip_id')  String tripId, @JsonKey(name: 'proposer_id')  String proposerId, @JsonKey(name: 'proposal_type')  String proposalType, @JsonKey(name: 'old_value')  String? oldValue, @JsonKey(name: 'new_value')  String? newValue, @JsonKey(name: 'target_user_id')  String? targetUserId,  String status, @JsonKey(name: 'required_votes')  int requiredVotes, @JsonKey(name: 'current_votes')  int currentVotes, @JsonKey(name: 'expires_at')  DateTime? expiresAt, @JsonKey(name: 'created_at')  DateTime createdAt, @JsonKey(name: 'updated_at')  DateTime updatedAt)  $default,) {final _that = this;
switch (_that) {
case _CarpoolProposal():
return $default(_that.id,_that.tripId,_that.proposerId,_that.proposalType,_that.oldValue,_that.newValue,_that.targetUserId,_that.status,_that.requiredVotes,_that.currentVotes,_that.expiresAt,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id, @JsonKey(name: 'trip_id')  String tripId, @JsonKey(name: 'proposer_id')  String proposerId, @JsonKey(name: 'proposal_type')  String proposalType, @JsonKey(name: 'old_value')  String? oldValue, @JsonKey(name: 'new_value')  String? newValue, @JsonKey(name: 'target_user_id')  String? targetUserId,  String status, @JsonKey(name: 'required_votes')  int requiredVotes, @JsonKey(name: 'current_votes')  int currentVotes, @JsonKey(name: 'expires_at')  DateTime? expiresAt, @JsonKey(name: 'created_at')  DateTime createdAt, @JsonKey(name: 'updated_at')  DateTime updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _CarpoolProposal() when $default != null:
return $default(_that.id,_that.tripId,_that.proposerId,_that.proposalType,_that.oldValue,_that.newValue,_that.targetUserId,_that.status,_that.requiredVotes,_that.currentVotes,_that.expiresAt,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CarpoolProposal implements CarpoolProposal {
  const _CarpoolProposal({required this.id, @JsonKey(name: 'trip_id') required this.tripId, @JsonKey(name: 'proposer_id') required this.proposerId, @JsonKey(name: 'proposal_type') required this.proposalType, @JsonKey(name: 'old_value') this.oldValue, @JsonKey(name: 'new_value') this.newValue, @JsonKey(name: 'target_user_id') this.targetUserId, this.status = 'pending', @JsonKey(name: 'required_votes') required this.requiredVotes, @JsonKey(name: 'current_votes') this.currentVotes = 0, @JsonKey(name: 'expires_at') this.expiresAt, @JsonKey(name: 'created_at') required this.createdAt, @JsonKey(name: 'updated_at') required this.updatedAt});
  factory _CarpoolProposal.fromJson(Map<String, dynamic> json) => _$CarpoolProposalFromJson(json);

@override final  String id;
@override@JsonKey(name: 'trip_id') final  String tripId;
@override@JsonKey(name: 'proposer_id') final  String proposerId;
// NOTE: proposal_type drives which fields are relevant:
//   'kick_member'       → target_user_id is required
//   'change_time'       → old_value/new_value are ISO-8601 strings
//   'change_departure'  → old_value/new_value are address strings
//   'change_destination'→ old_value/new_value are address strings
@override@JsonKey(name: 'proposal_type') final  String proposalType;
@override@JsonKey(name: 'old_value') final  String? oldValue;
@override@JsonKey(name: 'new_value') final  String? newValue;
@override@JsonKey(name: 'target_user_id') final  String? targetUserId;
@override@JsonKey() final  String status;
@override@JsonKey(name: 'required_votes') final  int requiredVotes;
@override@JsonKey(name: 'current_votes') final  int currentVotes;
@override@JsonKey(name: 'expires_at') final  DateTime? expiresAt;
@override@JsonKey(name: 'created_at') final  DateTime createdAt;
@override@JsonKey(name: 'updated_at') final  DateTime updatedAt;

/// Create a copy of CarpoolProposal
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CarpoolProposalCopyWith<_CarpoolProposal> get copyWith => __$CarpoolProposalCopyWithImpl<_CarpoolProposal>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CarpoolProposalToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CarpoolProposal&&(identical(other.id, id) || other.id == id)&&(identical(other.tripId, tripId) || other.tripId == tripId)&&(identical(other.proposerId, proposerId) || other.proposerId == proposerId)&&(identical(other.proposalType, proposalType) || other.proposalType == proposalType)&&(identical(other.oldValue, oldValue) || other.oldValue == oldValue)&&(identical(other.newValue, newValue) || other.newValue == newValue)&&(identical(other.targetUserId, targetUserId) || other.targetUserId == targetUserId)&&(identical(other.status, status) || other.status == status)&&(identical(other.requiredVotes, requiredVotes) || other.requiredVotes == requiredVotes)&&(identical(other.currentVotes, currentVotes) || other.currentVotes == currentVotes)&&(identical(other.expiresAt, expiresAt) || other.expiresAt == expiresAt)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,tripId,proposerId,proposalType,oldValue,newValue,targetUserId,status,requiredVotes,currentVotes,expiresAt,createdAt,updatedAt);

@override
String toString() {
  return 'CarpoolProposal(id: $id, tripId: $tripId, proposerId: $proposerId, proposalType: $proposalType, oldValue: $oldValue, newValue: $newValue, targetUserId: $targetUserId, status: $status, requiredVotes: $requiredVotes, currentVotes: $currentVotes, expiresAt: $expiresAt, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$CarpoolProposalCopyWith<$Res> implements $CarpoolProposalCopyWith<$Res> {
  factory _$CarpoolProposalCopyWith(_CarpoolProposal value, $Res Function(_CarpoolProposal) _then) = __$CarpoolProposalCopyWithImpl;
@override @useResult
$Res call({
 String id,@JsonKey(name: 'trip_id') String tripId,@JsonKey(name: 'proposer_id') String proposerId,@JsonKey(name: 'proposal_type') String proposalType,@JsonKey(name: 'old_value') String? oldValue,@JsonKey(name: 'new_value') String? newValue,@JsonKey(name: 'target_user_id') String? targetUserId, String status,@JsonKey(name: 'required_votes') int requiredVotes,@JsonKey(name: 'current_votes') int currentVotes,@JsonKey(name: 'expires_at') DateTime? expiresAt,@JsonKey(name: 'created_at') DateTime createdAt,@JsonKey(name: 'updated_at') DateTime updatedAt
});




}
/// @nodoc
class __$CarpoolProposalCopyWithImpl<$Res>
    implements _$CarpoolProposalCopyWith<$Res> {
  __$CarpoolProposalCopyWithImpl(this._self, this._then);

  final _CarpoolProposal _self;
  final $Res Function(_CarpoolProposal) _then;

/// Create a copy of CarpoolProposal
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? tripId = null,Object? proposerId = null,Object? proposalType = null,Object? oldValue = freezed,Object? newValue = freezed,Object? targetUserId = freezed,Object? status = null,Object? requiredVotes = null,Object? currentVotes = null,Object? expiresAt = freezed,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_CarpoolProposal(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,tripId: null == tripId ? _self.tripId : tripId // ignore: cast_nullable_to_non_nullable
as String,proposerId: null == proposerId ? _self.proposerId : proposerId // ignore: cast_nullable_to_non_nullable
as String,proposalType: null == proposalType ? _self.proposalType : proposalType // ignore: cast_nullable_to_non_nullable
as String,oldValue: freezed == oldValue ? _self.oldValue : oldValue // ignore: cast_nullable_to_non_nullable
as String?,newValue: freezed == newValue ? _self.newValue : newValue // ignore: cast_nullable_to_non_nullable
as String?,targetUserId: freezed == targetUserId ? _self.targetUserId : targetUserId // ignore: cast_nullable_to_non_nullable
as String?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,requiredVotes: null == requiredVotes ? _self.requiredVotes : requiredVotes // ignore: cast_nullable_to_non_nullable
as int,currentVotes: null == currentVotes ? _self.currentVotes : currentVotes // ignore: cast_nullable_to_non_nullable
as int,expiresAt: freezed == expiresAt ? _self.expiresAt : expiresAt // ignore: cast_nullable_to_non_nullable
as DateTime?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on

// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'carpool_member.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$CarpoolMember {

 String get id;@JsonKey(name: 'trip_id') String get tripId;@JsonKey(name: 'user_id') String get userId;// NOTE: 'creator' is set when the trip creator is added as a member
// automatically; 'member' is set for everyone who joins afterward.
 String get role;// NOTE: Default 'pending' supports manual approval mode.
// Auto-approval trips immediately set this to 'approved' via DB trigger.
 String get status;@JsonKey(name: 'joined_at') DateTime? get joinedAt;@JsonKey(name: 'created_at') DateTime get createdAt;// Nested join — populated only when queried with user join
 UserProfile? get user;
/// Create a copy of CarpoolMember
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CarpoolMemberCopyWith<CarpoolMember> get copyWith => _$CarpoolMemberCopyWithImpl<CarpoolMember>(this as CarpoolMember, _$identity);

  /// Serializes this CarpoolMember to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CarpoolMember&&(identical(other.id, id) || other.id == id)&&(identical(other.tripId, tripId) || other.tripId == tripId)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.role, role) || other.role == role)&&(identical(other.status, status) || other.status == status)&&(identical(other.joinedAt, joinedAt) || other.joinedAt == joinedAt)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.user, user) || other.user == user));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,tripId,userId,role,status,joinedAt,createdAt,user);

@override
String toString() {
  return 'CarpoolMember(id: $id, tripId: $tripId, userId: $userId, role: $role, status: $status, joinedAt: $joinedAt, createdAt: $createdAt, user: $user)';
}


}

/// @nodoc
abstract mixin class $CarpoolMemberCopyWith<$Res>  {
  factory $CarpoolMemberCopyWith(CarpoolMember value, $Res Function(CarpoolMember) _then) = _$CarpoolMemberCopyWithImpl;
@useResult
$Res call({
 String id,@JsonKey(name: 'trip_id') String tripId,@JsonKey(name: 'user_id') String userId, String role, String status,@JsonKey(name: 'joined_at') DateTime? joinedAt,@JsonKey(name: 'created_at') DateTime createdAt, UserProfile? user
});


$UserProfileCopyWith<$Res>? get user;

}
/// @nodoc
class _$CarpoolMemberCopyWithImpl<$Res>
    implements $CarpoolMemberCopyWith<$Res> {
  _$CarpoolMemberCopyWithImpl(this._self, this._then);

  final CarpoolMember _self;
  final $Res Function(CarpoolMember) _then;

/// Create a copy of CarpoolMember
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? tripId = null,Object? userId = null,Object? role = null,Object? status = null,Object? joinedAt = freezed,Object? createdAt = null,Object? user = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,tripId: null == tripId ? _self.tripId : tripId // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,role: null == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,joinedAt: freezed == joinedAt ? _self.joinedAt : joinedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,user: freezed == user ? _self.user : user // ignore: cast_nullable_to_non_nullable
as UserProfile?,
  ));
}
/// Create a copy of CarpoolMember
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$UserProfileCopyWith<$Res>? get user {
    if (_self.user == null) {
    return null;
  }

  return $UserProfileCopyWith<$Res>(_self.user!, (value) {
    return _then(_self.copyWith(user: value));
  });
}
}


/// Adds pattern-matching-related methods to [CarpoolMember].
extension CarpoolMemberPatterns on CarpoolMember {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CarpoolMember value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CarpoolMember() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CarpoolMember value)  $default,){
final _that = this;
switch (_that) {
case _CarpoolMember():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CarpoolMember value)?  $default,){
final _that = this;
switch (_that) {
case _CarpoolMember() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'trip_id')  String tripId, @JsonKey(name: 'user_id')  String userId,  String role,  String status, @JsonKey(name: 'joined_at')  DateTime? joinedAt, @JsonKey(name: 'created_at')  DateTime createdAt,  UserProfile? user)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CarpoolMember() when $default != null:
return $default(_that.id,_that.tripId,_that.userId,_that.role,_that.status,_that.joinedAt,_that.createdAt,_that.user);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'trip_id')  String tripId, @JsonKey(name: 'user_id')  String userId,  String role,  String status, @JsonKey(name: 'joined_at')  DateTime? joinedAt, @JsonKey(name: 'created_at')  DateTime createdAt,  UserProfile? user)  $default,) {final _that = this;
switch (_that) {
case _CarpoolMember():
return $default(_that.id,_that.tripId,_that.userId,_that.role,_that.status,_that.joinedAt,_that.createdAt,_that.user);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id, @JsonKey(name: 'trip_id')  String tripId, @JsonKey(name: 'user_id')  String userId,  String role,  String status, @JsonKey(name: 'joined_at')  DateTime? joinedAt, @JsonKey(name: 'created_at')  DateTime createdAt,  UserProfile? user)?  $default,) {final _that = this;
switch (_that) {
case _CarpoolMember() when $default != null:
return $default(_that.id,_that.tripId,_that.userId,_that.role,_that.status,_that.joinedAt,_that.createdAt,_that.user);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CarpoolMember implements CarpoolMember {
  const _CarpoolMember({required this.id, @JsonKey(name: 'trip_id') required this.tripId, @JsonKey(name: 'user_id') required this.userId, required this.role, this.status = 'pending', @JsonKey(name: 'joined_at') this.joinedAt, @JsonKey(name: 'created_at') required this.createdAt, this.user});
  factory _CarpoolMember.fromJson(Map<String, dynamic> json) => _$CarpoolMemberFromJson(json);

@override final  String id;
@override@JsonKey(name: 'trip_id') final  String tripId;
@override@JsonKey(name: 'user_id') final  String userId;
// NOTE: 'creator' is set when the trip creator is added as a member
// automatically; 'member' is set for everyone who joins afterward.
@override final  String role;
// NOTE: Default 'pending' supports manual approval mode.
// Auto-approval trips immediately set this to 'approved' via DB trigger.
@override@JsonKey() final  String status;
@override@JsonKey(name: 'joined_at') final  DateTime? joinedAt;
@override@JsonKey(name: 'created_at') final  DateTime createdAt;
// Nested join — populated only when queried with user join
@override final  UserProfile? user;

/// Create a copy of CarpoolMember
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CarpoolMemberCopyWith<_CarpoolMember> get copyWith => __$CarpoolMemberCopyWithImpl<_CarpoolMember>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CarpoolMemberToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CarpoolMember&&(identical(other.id, id) || other.id == id)&&(identical(other.tripId, tripId) || other.tripId == tripId)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.role, role) || other.role == role)&&(identical(other.status, status) || other.status == status)&&(identical(other.joinedAt, joinedAt) || other.joinedAt == joinedAt)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.user, user) || other.user == user));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,tripId,userId,role,status,joinedAt,createdAt,user);

@override
String toString() {
  return 'CarpoolMember(id: $id, tripId: $tripId, userId: $userId, role: $role, status: $status, joinedAt: $joinedAt, createdAt: $createdAt, user: $user)';
}


}

/// @nodoc
abstract mixin class _$CarpoolMemberCopyWith<$Res> implements $CarpoolMemberCopyWith<$Res> {
  factory _$CarpoolMemberCopyWith(_CarpoolMember value, $Res Function(_CarpoolMember) _then) = __$CarpoolMemberCopyWithImpl;
@override @useResult
$Res call({
 String id,@JsonKey(name: 'trip_id') String tripId,@JsonKey(name: 'user_id') String userId, String role, String status,@JsonKey(name: 'joined_at') DateTime? joinedAt,@JsonKey(name: 'created_at') DateTime createdAt, UserProfile? user
});


@override $UserProfileCopyWith<$Res>? get user;

}
/// @nodoc
class __$CarpoolMemberCopyWithImpl<$Res>
    implements _$CarpoolMemberCopyWith<$Res> {
  __$CarpoolMemberCopyWithImpl(this._self, this._then);

  final _CarpoolMember _self;
  final $Res Function(_CarpoolMember) _then;

/// Create a copy of CarpoolMember
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? tripId = null,Object? userId = null,Object? role = null,Object? status = null,Object? joinedAt = freezed,Object? createdAt = null,Object? user = freezed,}) {
  return _then(_CarpoolMember(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,tripId: null == tripId ? _self.tripId : tripId // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,role: null == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,joinedAt: freezed == joinedAt ? _self.joinedAt : joinedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,user: freezed == user ? _self.user : user // ignore: cast_nullable_to_non_nullable
as UserProfile?,
  ));
}

/// Create a copy of CarpoolMember
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$UserProfileCopyWith<$Res>? get user {
    if (_self.user == null) {
    return null;
  }

  return $UserProfileCopyWith<$Res>(_self.user!, (value) {
    return _then(_self.copyWith(user: value));
  });
}
}

// dart format on

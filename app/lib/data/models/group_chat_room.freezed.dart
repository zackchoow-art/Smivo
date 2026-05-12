// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'group_chat_room.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$GroupChatRoom {

 String get id;@JsonKey(name: 'trip_id') String get tripId; String get name;@JsonKey(name: 'created_by') String get createdBy;@JsonKey(name: 'created_at') DateTime get createdAt;@JsonKey(name: 'updated_at') DateTime get updatedAt;// Nested join — populated only when queried with members join
 List<GroupChatMember> get members;
/// Create a copy of GroupChatRoom
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GroupChatRoomCopyWith<GroupChatRoom> get copyWith => _$GroupChatRoomCopyWithImpl<GroupChatRoom>(this as GroupChatRoom, _$identity);

  /// Serializes this GroupChatRoom to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GroupChatRoom&&(identical(other.id, id) || other.id == id)&&(identical(other.tripId, tripId) || other.tripId == tripId)&&(identical(other.name, name) || other.name == name)&&(identical(other.createdBy, createdBy) || other.createdBy == createdBy)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&const DeepCollectionEquality().equals(other.members, members));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,tripId,name,createdBy,createdAt,updatedAt,const DeepCollectionEquality().hash(members));

@override
String toString() {
  return 'GroupChatRoom(id: $id, tripId: $tripId, name: $name, createdBy: $createdBy, createdAt: $createdAt, updatedAt: $updatedAt, members: $members)';
}


}

/// @nodoc
abstract mixin class $GroupChatRoomCopyWith<$Res>  {
  factory $GroupChatRoomCopyWith(GroupChatRoom value, $Res Function(GroupChatRoom) _then) = _$GroupChatRoomCopyWithImpl;
@useResult
$Res call({
 String id,@JsonKey(name: 'trip_id') String tripId, String name,@JsonKey(name: 'created_by') String createdBy,@JsonKey(name: 'created_at') DateTime createdAt,@JsonKey(name: 'updated_at') DateTime updatedAt, List<GroupChatMember> members
});




}
/// @nodoc
class _$GroupChatRoomCopyWithImpl<$Res>
    implements $GroupChatRoomCopyWith<$Res> {
  _$GroupChatRoomCopyWithImpl(this._self, this._then);

  final GroupChatRoom _self;
  final $Res Function(GroupChatRoom) _then;

/// Create a copy of GroupChatRoom
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? tripId = null,Object? name = null,Object? createdBy = null,Object? createdAt = null,Object? updatedAt = null,Object? members = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,tripId: null == tripId ? _self.tripId : tripId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,createdBy: null == createdBy ? _self.createdBy : createdBy // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,members: null == members ? _self.members : members // ignore: cast_nullable_to_non_nullable
as List<GroupChatMember>,
  ));
}

}


/// Adds pattern-matching-related methods to [GroupChatRoom].
extension GroupChatRoomPatterns on GroupChatRoom {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _GroupChatRoom value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _GroupChatRoom() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _GroupChatRoom value)  $default,){
final _that = this;
switch (_that) {
case _GroupChatRoom():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _GroupChatRoom value)?  $default,){
final _that = this;
switch (_that) {
case _GroupChatRoom() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'trip_id')  String tripId,  String name, @JsonKey(name: 'created_by')  String createdBy, @JsonKey(name: 'created_at')  DateTime createdAt, @JsonKey(name: 'updated_at')  DateTime updatedAt,  List<GroupChatMember> members)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _GroupChatRoom() when $default != null:
return $default(_that.id,_that.tripId,_that.name,_that.createdBy,_that.createdAt,_that.updatedAt,_that.members);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'trip_id')  String tripId,  String name, @JsonKey(name: 'created_by')  String createdBy, @JsonKey(name: 'created_at')  DateTime createdAt, @JsonKey(name: 'updated_at')  DateTime updatedAt,  List<GroupChatMember> members)  $default,) {final _that = this;
switch (_that) {
case _GroupChatRoom():
return $default(_that.id,_that.tripId,_that.name,_that.createdBy,_that.createdAt,_that.updatedAt,_that.members);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id, @JsonKey(name: 'trip_id')  String tripId,  String name, @JsonKey(name: 'created_by')  String createdBy, @JsonKey(name: 'created_at')  DateTime createdAt, @JsonKey(name: 'updated_at')  DateTime updatedAt,  List<GroupChatMember> members)?  $default,) {final _that = this;
switch (_that) {
case _GroupChatRoom() when $default != null:
return $default(_that.id,_that.tripId,_that.name,_that.createdBy,_that.createdAt,_that.updatedAt,_that.members);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _GroupChatRoom implements GroupChatRoom {
  const _GroupChatRoom({required this.id, @JsonKey(name: 'trip_id') required this.tripId, required this.name, @JsonKey(name: 'created_by') required this.createdBy, @JsonKey(name: 'created_at') required this.createdAt, @JsonKey(name: 'updated_at') required this.updatedAt, final  List<GroupChatMember> members = const []}): _members = members;
  factory _GroupChatRoom.fromJson(Map<String, dynamic> json) => _$GroupChatRoomFromJson(json);

@override final  String id;
@override@JsonKey(name: 'trip_id') final  String tripId;
@override final  String name;
@override@JsonKey(name: 'created_by') final  String createdBy;
@override@JsonKey(name: 'created_at') final  DateTime createdAt;
@override@JsonKey(name: 'updated_at') final  DateTime updatedAt;
// Nested join — populated only when queried with members join
 final  List<GroupChatMember> _members;
// Nested join — populated only when queried with members join
@override@JsonKey() List<GroupChatMember> get members {
  if (_members is EqualUnmodifiableListView) return _members;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_members);
}


/// Create a copy of GroupChatRoom
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GroupChatRoomCopyWith<_GroupChatRoom> get copyWith => __$GroupChatRoomCopyWithImpl<_GroupChatRoom>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$GroupChatRoomToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _GroupChatRoom&&(identical(other.id, id) || other.id == id)&&(identical(other.tripId, tripId) || other.tripId == tripId)&&(identical(other.name, name) || other.name == name)&&(identical(other.createdBy, createdBy) || other.createdBy == createdBy)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&const DeepCollectionEquality().equals(other._members, _members));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,tripId,name,createdBy,createdAt,updatedAt,const DeepCollectionEquality().hash(_members));

@override
String toString() {
  return 'GroupChatRoom(id: $id, tripId: $tripId, name: $name, createdBy: $createdBy, createdAt: $createdAt, updatedAt: $updatedAt, members: $members)';
}


}

/// @nodoc
abstract mixin class _$GroupChatRoomCopyWith<$Res> implements $GroupChatRoomCopyWith<$Res> {
  factory _$GroupChatRoomCopyWith(_GroupChatRoom value, $Res Function(_GroupChatRoom) _then) = __$GroupChatRoomCopyWithImpl;
@override @useResult
$Res call({
 String id,@JsonKey(name: 'trip_id') String tripId, String name,@JsonKey(name: 'created_by') String createdBy,@JsonKey(name: 'created_at') DateTime createdAt,@JsonKey(name: 'updated_at') DateTime updatedAt, List<GroupChatMember> members
});




}
/// @nodoc
class __$GroupChatRoomCopyWithImpl<$Res>
    implements _$GroupChatRoomCopyWith<$Res> {
  __$GroupChatRoomCopyWithImpl(this._self, this._then);

  final _GroupChatRoom _self;
  final $Res Function(_GroupChatRoom) _then;

/// Create a copy of GroupChatRoom
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? tripId = null,Object? name = null,Object? createdBy = null,Object? createdAt = null,Object? updatedAt = null,Object? members = null,}) {
  return _then(_GroupChatRoom(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,tripId: null == tripId ? _self.tripId : tripId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,createdBy: null == createdBy ? _self.createdBy : createdBy // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,members: null == members ? _self._members : members // ignore: cast_nullable_to_non_nullable
as List<GroupChatMember>,
  ));
}


}

// dart format on

// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'group_chat_member.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$GroupChatMember {

 String get id;@JsonKey(name: 'room_id') String get roomId;@JsonKey(name: 'user_id') String get userId;@JsonKey(name: 'joined_at') DateTime get joinedAt;// Tracks when the user last opened this group chat.
// Messages created after this timestamp are considered unread.
@JsonKey(name: 'last_read_at') DateTime? get lastReadAt;// NOTE: Per-member UI preferences — each member sets these independently.
// Mirrors is_pinned / is_archived / is_unread_override on chat_rooms.
@JsonKey(name: 'is_pinned') bool get isPinned;@JsonKey(name: 'is_archived') bool get isArchived;@JsonKey(name: 'is_unread_override') bool get isUnreadOverride;// Nested join — populated only when queried with user join
 UserProfile? get user;
/// Create a copy of GroupChatMember
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GroupChatMemberCopyWith<GroupChatMember> get copyWith => _$GroupChatMemberCopyWithImpl<GroupChatMember>(this as GroupChatMember, _$identity);

  /// Serializes this GroupChatMember to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GroupChatMember&&(identical(other.id, id) || other.id == id)&&(identical(other.roomId, roomId) || other.roomId == roomId)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.joinedAt, joinedAt) || other.joinedAt == joinedAt)&&(identical(other.lastReadAt, lastReadAt) || other.lastReadAt == lastReadAt)&&(identical(other.isPinned, isPinned) || other.isPinned == isPinned)&&(identical(other.isArchived, isArchived) || other.isArchived == isArchived)&&(identical(other.isUnreadOverride, isUnreadOverride) || other.isUnreadOverride == isUnreadOverride)&&(identical(other.user, user) || other.user == user));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,roomId,userId,joinedAt,lastReadAt,isPinned,isArchived,isUnreadOverride,user);

@override
String toString() {
  return 'GroupChatMember(id: $id, roomId: $roomId, userId: $userId, joinedAt: $joinedAt, lastReadAt: $lastReadAt, isPinned: $isPinned, isArchived: $isArchived, isUnreadOverride: $isUnreadOverride, user: $user)';
}


}

/// @nodoc
abstract mixin class $GroupChatMemberCopyWith<$Res>  {
  factory $GroupChatMemberCopyWith(GroupChatMember value, $Res Function(GroupChatMember) _then) = _$GroupChatMemberCopyWithImpl;
@useResult
$Res call({
 String id,@JsonKey(name: 'room_id') String roomId,@JsonKey(name: 'user_id') String userId,@JsonKey(name: 'joined_at') DateTime joinedAt,@JsonKey(name: 'last_read_at') DateTime? lastReadAt,@JsonKey(name: 'is_pinned') bool isPinned,@JsonKey(name: 'is_archived') bool isArchived,@JsonKey(name: 'is_unread_override') bool isUnreadOverride, UserProfile? user
});


$UserProfileCopyWith<$Res>? get user;

}
/// @nodoc
class _$GroupChatMemberCopyWithImpl<$Res>
    implements $GroupChatMemberCopyWith<$Res> {
  _$GroupChatMemberCopyWithImpl(this._self, this._then);

  final GroupChatMember _self;
  final $Res Function(GroupChatMember) _then;

/// Create a copy of GroupChatMember
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? roomId = null,Object? userId = null,Object? joinedAt = null,Object? lastReadAt = freezed,Object? isPinned = null,Object? isArchived = null,Object? isUnreadOverride = null,Object? user = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,roomId: null == roomId ? _self.roomId : roomId // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,joinedAt: null == joinedAt ? _self.joinedAt : joinedAt // ignore: cast_nullable_to_non_nullable
as DateTime,lastReadAt: freezed == lastReadAt ? _self.lastReadAt : lastReadAt // ignore: cast_nullable_to_non_nullable
as DateTime?,isPinned: null == isPinned ? _self.isPinned : isPinned // ignore: cast_nullable_to_non_nullable
as bool,isArchived: null == isArchived ? _self.isArchived : isArchived // ignore: cast_nullable_to_non_nullable
as bool,isUnreadOverride: null == isUnreadOverride ? _self.isUnreadOverride : isUnreadOverride // ignore: cast_nullable_to_non_nullable
as bool,user: freezed == user ? _self.user : user // ignore: cast_nullable_to_non_nullable
as UserProfile?,
  ));
}
/// Create a copy of GroupChatMember
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


/// Adds pattern-matching-related methods to [GroupChatMember].
extension GroupChatMemberPatterns on GroupChatMember {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _GroupChatMember value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _GroupChatMember() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _GroupChatMember value)  $default,){
final _that = this;
switch (_that) {
case _GroupChatMember():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _GroupChatMember value)?  $default,){
final _that = this;
switch (_that) {
case _GroupChatMember() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'room_id')  String roomId, @JsonKey(name: 'user_id')  String userId, @JsonKey(name: 'joined_at')  DateTime joinedAt, @JsonKey(name: 'last_read_at')  DateTime? lastReadAt, @JsonKey(name: 'is_pinned')  bool isPinned, @JsonKey(name: 'is_archived')  bool isArchived, @JsonKey(name: 'is_unread_override')  bool isUnreadOverride,  UserProfile? user)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _GroupChatMember() when $default != null:
return $default(_that.id,_that.roomId,_that.userId,_that.joinedAt,_that.lastReadAt,_that.isPinned,_that.isArchived,_that.isUnreadOverride,_that.user);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'room_id')  String roomId, @JsonKey(name: 'user_id')  String userId, @JsonKey(name: 'joined_at')  DateTime joinedAt, @JsonKey(name: 'last_read_at')  DateTime? lastReadAt, @JsonKey(name: 'is_pinned')  bool isPinned, @JsonKey(name: 'is_archived')  bool isArchived, @JsonKey(name: 'is_unread_override')  bool isUnreadOverride,  UserProfile? user)  $default,) {final _that = this;
switch (_that) {
case _GroupChatMember():
return $default(_that.id,_that.roomId,_that.userId,_that.joinedAt,_that.lastReadAt,_that.isPinned,_that.isArchived,_that.isUnreadOverride,_that.user);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id, @JsonKey(name: 'room_id')  String roomId, @JsonKey(name: 'user_id')  String userId, @JsonKey(name: 'joined_at')  DateTime joinedAt, @JsonKey(name: 'last_read_at')  DateTime? lastReadAt, @JsonKey(name: 'is_pinned')  bool isPinned, @JsonKey(name: 'is_archived')  bool isArchived, @JsonKey(name: 'is_unread_override')  bool isUnreadOverride,  UserProfile? user)?  $default,) {final _that = this;
switch (_that) {
case _GroupChatMember() when $default != null:
return $default(_that.id,_that.roomId,_that.userId,_that.joinedAt,_that.lastReadAt,_that.isPinned,_that.isArchived,_that.isUnreadOverride,_that.user);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _GroupChatMember implements GroupChatMember {
  const _GroupChatMember({required this.id, @JsonKey(name: 'room_id') required this.roomId, @JsonKey(name: 'user_id') required this.userId, @JsonKey(name: 'joined_at') required this.joinedAt, @JsonKey(name: 'last_read_at') this.lastReadAt, @JsonKey(name: 'is_pinned') this.isPinned = false, @JsonKey(name: 'is_archived') this.isArchived = false, @JsonKey(name: 'is_unread_override') this.isUnreadOverride = false, this.user});
  factory _GroupChatMember.fromJson(Map<String, dynamic> json) => _$GroupChatMemberFromJson(json);

@override final  String id;
@override@JsonKey(name: 'room_id') final  String roomId;
@override@JsonKey(name: 'user_id') final  String userId;
@override@JsonKey(name: 'joined_at') final  DateTime joinedAt;
// Tracks when the user last opened this group chat.
// Messages created after this timestamp are considered unread.
@override@JsonKey(name: 'last_read_at') final  DateTime? lastReadAt;
// NOTE: Per-member UI preferences — each member sets these independently.
// Mirrors is_pinned / is_archived / is_unread_override on chat_rooms.
@override@JsonKey(name: 'is_pinned') final  bool isPinned;
@override@JsonKey(name: 'is_archived') final  bool isArchived;
@override@JsonKey(name: 'is_unread_override') final  bool isUnreadOverride;
// Nested join — populated only when queried with user join
@override final  UserProfile? user;

/// Create a copy of GroupChatMember
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GroupChatMemberCopyWith<_GroupChatMember> get copyWith => __$GroupChatMemberCopyWithImpl<_GroupChatMember>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$GroupChatMemberToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _GroupChatMember&&(identical(other.id, id) || other.id == id)&&(identical(other.roomId, roomId) || other.roomId == roomId)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.joinedAt, joinedAt) || other.joinedAt == joinedAt)&&(identical(other.lastReadAt, lastReadAt) || other.lastReadAt == lastReadAt)&&(identical(other.isPinned, isPinned) || other.isPinned == isPinned)&&(identical(other.isArchived, isArchived) || other.isArchived == isArchived)&&(identical(other.isUnreadOverride, isUnreadOverride) || other.isUnreadOverride == isUnreadOverride)&&(identical(other.user, user) || other.user == user));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,roomId,userId,joinedAt,lastReadAt,isPinned,isArchived,isUnreadOverride,user);

@override
String toString() {
  return 'GroupChatMember(id: $id, roomId: $roomId, userId: $userId, joinedAt: $joinedAt, lastReadAt: $lastReadAt, isPinned: $isPinned, isArchived: $isArchived, isUnreadOverride: $isUnreadOverride, user: $user)';
}


}

/// @nodoc
abstract mixin class _$GroupChatMemberCopyWith<$Res> implements $GroupChatMemberCopyWith<$Res> {
  factory _$GroupChatMemberCopyWith(_GroupChatMember value, $Res Function(_GroupChatMember) _then) = __$GroupChatMemberCopyWithImpl;
@override @useResult
$Res call({
 String id,@JsonKey(name: 'room_id') String roomId,@JsonKey(name: 'user_id') String userId,@JsonKey(name: 'joined_at') DateTime joinedAt,@JsonKey(name: 'last_read_at') DateTime? lastReadAt,@JsonKey(name: 'is_pinned') bool isPinned,@JsonKey(name: 'is_archived') bool isArchived,@JsonKey(name: 'is_unread_override') bool isUnreadOverride, UserProfile? user
});


@override $UserProfileCopyWith<$Res>? get user;

}
/// @nodoc
class __$GroupChatMemberCopyWithImpl<$Res>
    implements _$GroupChatMemberCopyWith<$Res> {
  __$GroupChatMemberCopyWithImpl(this._self, this._then);

  final _GroupChatMember _self;
  final $Res Function(_GroupChatMember) _then;

/// Create a copy of GroupChatMember
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? roomId = null,Object? userId = null,Object? joinedAt = null,Object? lastReadAt = freezed,Object? isPinned = null,Object? isArchived = null,Object? isUnreadOverride = null,Object? user = freezed,}) {
  return _then(_GroupChatMember(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,roomId: null == roomId ? _self.roomId : roomId // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,joinedAt: null == joinedAt ? _self.joinedAt : joinedAt // ignore: cast_nullable_to_non_nullable
as DateTime,lastReadAt: freezed == lastReadAt ? _self.lastReadAt : lastReadAt // ignore: cast_nullable_to_non_nullable
as DateTime?,isPinned: null == isPinned ? _self.isPinned : isPinned // ignore: cast_nullable_to_non_nullable
as bool,isArchived: null == isArchived ? _self.isArchived : isArchived // ignore: cast_nullable_to_non_nullable
as bool,isUnreadOverride: null == isUnreadOverride ? _self.isUnreadOverride : isUnreadOverride // ignore: cast_nullable_to_non_nullable
as bool,user: freezed == user ? _self.user : user // ignore: cast_nullable_to_non_nullable
as UserProfile?,
  ));
}

/// Create a copy of GroupChatMember
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

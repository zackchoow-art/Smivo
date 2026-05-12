// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'group_message.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$GroupMessage {

 String get id;@JsonKey(name: 'room_id') String get roomId;@JsonKey(name: 'sender_id') String get senderId; String get content;// NOTE: 'system' messages have senderId set to a placeholder and are
// rendered differently in the UI (centered, dimmed text, no avatar).
@JsonKey(name: 'message_type') String get messageType;@JsonKey(name: 'image_url') String? get imageUrl;@JsonKey(name: 'created_at') DateTime get createdAt;// Nested join — populated only when queried with sender join
 UserProfile? get sender;
/// Create a copy of GroupMessage
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GroupMessageCopyWith<GroupMessage> get copyWith => _$GroupMessageCopyWithImpl<GroupMessage>(this as GroupMessage, _$identity);

  /// Serializes this GroupMessage to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GroupMessage&&(identical(other.id, id) || other.id == id)&&(identical(other.roomId, roomId) || other.roomId == roomId)&&(identical(other.senderId, senderId) || other.senderId == senderId)&&(identical(other.content, content) || other.content == content)&&(identical(other.messageType, messageType) || other.messageType == messageType)&&(identical(other.imageUrl, imageUrl) || other.imageUrl == imageUrl)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.sender, sender) || other.sender == sender));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,roomId,senderId,content,messageType,imageUrl,createdAt,sender);

@override
String toString() {
  return 'GroupMessage(id: $id, roomId: $roomId, senderId: $senderId, content: $content, messageType: $messageType, imageUrl: $imageUrl, createdAt: $createdAt, sender: $sender)';
}


}

/// @nodoc
abstract mixin class $GroupMessageCopyWith<$Res>  {
  factory $GroupMessageCopyWith(GroupMessage value, $Res Function(GroupMessage) _then) = _$GroupMessageCopyWithImpl;
@useResult
$Res call({
 String id,@JsonKey(name: 'room_id') String roomId,@JsonKey(name: 'sender_id') String senderId, String content,@JsonKey(name: 'message_type') String messageType,@JsonKey(name: 'image_url') String? imageUrl,@JsonKey(name: 'created_at') DateTime createdAt, UserProfile? sender
});


$UserProfileCopyWith<$Res>? get sender;

}
/// @nodoc
class _$GroupMessageCopyWithImpl<$Res>
    implements $GroupMessageCopyWith<$Res> {
  _$GroupMessageCopyWithImpl(this._self, this._then);

  final GroupMessage _self;
  final $Res Function(GroupMessage) _then;

/// Create a copy of GroupMessage
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? roomId = null,Object? senderId = null,Object? content = null,Object? messageType = null,Object? imageUrl = freezed,Object? createdAt = null,Object? sender = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,roomId: null == roomId ? _self.roomId : roomId // ignore: cast_nullable_to_non_nullable
as String,senderId: null == senderId ? _self.senderId : senderId // ignore: cast_nullable_to_non_nullable
as String,content: null == content ? _self.content : content // ignore: cast_nullable_to_non_nullable
as String,messageType: null == messageType ? _self.messageType : messageType // ignore: cast_nullable_to_non_nullable
as String,imageUrl: freezed == imageUrl ? _self.imageUrl : imageUrl // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,sender: freezed == sender ? _self.sender : sender // ignore: cast_nullable_to_non_nullable
as UserProfile?,
  ));
}
/// Create a copy of GroupMessage
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$UserProfileCopyWith<$Res>? get sender {
    if (_self.sender == null) {
    return null;
  }

  return $UserProfileCopyWith<$Res>(_self.sender!, (value) {
    return _then(_self.copyWith(sender: value));
  });
}
}


/// Adds pattern-matching-related methods to [GroupMessage].
extension GroupMessagePatterns on GroupMessage {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _GroupMessage value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _GroupMessage() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _GroupMessage value)  $default,){
final _that = this;
switch (_that) {
case _GroupMessage():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _GroupMessage value)?  $default,){
final _that = this;
switch (_that) {
case _GroupMessage() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'room_id')  String roomId, @JsonKey(name: 'sender_id')  String senderId,  String content, @JsonKey(name: 'message_type')  String messageType, @JsonKey(name: 'image_url')  String? imageUrl, @JsonKey(name: 'created_at')  DateTime createdAt,  UserProfile? sender)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _GroupMessage() when $default != null:
return $default(_that.id,_that.roomId,_that.senderId,_that.content,_that.messageType,_that.imageUrl,_that.createdAt,_that.sender);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'room_id')  String roomId, @JsonKey(name: 'sender_id')  String senderId,  String content, @JsonKey(name: 'message_type')  String messageType, @JsonKey(name: 'image_url')  String? imageUrl, @JsonKey(name: 'created_at')  DateTime createdAt,  UserProfile? sender)  $default,) {final _that = this;
switch (_that) {
case _GroupMessage():
return $default(_that.id,_that.roomId,_that.senderId,_that.content,_that.messageType,_that.imageUrl,_that.createdAt,_that.sender);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id, @JsonKey(name: 'room_id')  String roomId, @JsonKey(name: 'sender_id')  String senderId,  String content, @JsonKey(name: 'message_type')  String messageType, @JsonKey(name: 'image_url')  String? imageUrl, @JsonKey(name: 'created_at')  DateTime createdAt,  UserProfile? sender)?  $default,) {final _that = this;
switch (_that) {
case _GroupMessage() when $default != null:
return $default(_that.id,_that.roomId,_that.senderId,_that.content,_that.messageType,_that.imageUrl,_that.createdAt,_that.sender);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _GroupMessage implements GroupMessage {
  const _GroupMessage({required this.id, @JsonKey(name: 'room_id') required this.roomId, @JsonKey(name: 'sender_id') required this.senderId, required this.content, @JsonKey(name: 'message_type') this.messageType = 'text', @JsonKey(name: 'image_url') this.imageUrl, @JsonKey(name: 'created_at') required this.createdAt, this.sender});
  factory _GroupMessage.fromJson(Map<String, dynamic> json) => _$GroupMessageFromJson(json);

@override final  String id;
@override@JsonKey(name: 'room_id') final  String roomId;
@override@JsonKey(name: 'sender_id') final  String senderId;
@override final  String content;
// NOTE: 'system' messages have senderId set to a placeholder and are
// rendered differently in the UI (centered, dimmed text, no avatar).
@override@JsonKey(name: 'message_type') final  String messageType;
@override@JsonKey(name: 'image_url') final  String? imageUrl;
@override@JsonKey(name: 'created_at') final  DateTime createdAt;
// Nested join — populated only when queried with sender join
@override final  UserProfile? sender;

/// Create a copy of GroupMessage
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GroupMessageCopyWith<_GroupMessage> get copyWith => __$GroupMessageCopyWithImpl<_GroupMessage>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$GroupMessageToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _GroupMessage&&(identical(other.id, id) || other.id == id)&&(identical(other.roomId, roomId) || other.roomId == roomId)&&(identical(other.senderId, senderId) || other.senderId == senderId)&&(identical(other.content, content) || other.content == content)&&(identical(other.messageType, messageType) || other.messageType == messageType)&&(identical(other.imageUrl, imageUrl) || other.imageUrl == imageUrl)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.sender, sender) || other.sender == sender));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,roomId,senderId,content,messageType,imageUrl,createdAt,sender);

@override
String toString() {
  return 'GroupMessage(id: $id, roomId: $roomId, senderId: $senderId, content: $content, messageType: $messageType, imageUrl: $imageUrl, createdAt: $createdAt, sender: $sender)';
}


}

/// @nodoc
abstract mixin class _$GroupMessageCopyWith<$Res> implements $GroupMessageCopyWith<$Res> {
  factory _$GroupMessageCopyWith(_GroupMessage value, $Res Function(_GroupMessage) _then) = __$GroupMessageCopyWithImpl;
@override @useResult
$Res call({
 String id,@JsonKey(name: 'room_id') String roomId,@JsonKey(name: 'sender_id') String senderId, String content,@JsonKey(name: 'message_type') String messageType,@JsonKey(name: 'image_url') String? imageUrl,@JsonKey(name: 'created_at') DateTime createdAt, UserProfile? sender
});


@override $UserProfileCopyWith<$Res>? get sender;

}
/// @nodoc
class __$GroupMessageCopyWithImpl<$Res>
    implements _$GroupMessageCopyWith<$Res> {
  __$GroupMessageCopyWithImpl(this._self, this._then);

  final _GroupMessage _self;
  final $Res Function(_GroupMessage) _then;

/// Create a copy of GroupMessage
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? roomId = null,Object? senderId = null,Object? content = null,Object? messageType = null,Object? imageUrl = freezed,Object? createdAt = null,Object? sender = freezed,}) {
  return _then(_GroupMessage(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,roomId: null == roomId ? _self.roomId : roomId // ignore: cast_nullable_to_non_nullable
as String,senderId: null == senderId ? _self.senderId : senderId // ignore: cast_nullable_to_non_nullable
as String,content: null == content ? _self.content : content // ignore: cast_nullable_to_non_nullable
as String,messageType: null == messageType ? _self.messageType : messageType // ignore: cast_nullable_to_non_nullable
as String,imageUrl: freezed == imageUrl ? _self.imageUrl : imageUrl // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,sender: freezed == sender ? _self.sender : sender // ignore: cast_nullable_to_non_nullable
as UserProfile?,
  ));
}

/// Create a copy of GroupMessage
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$UserProfileCopyWith<$Res>? get sender {
    if (_self.sender == null) {
    return null;
  }

  return $UserProfileCopyWith<$Res>(_self.sender!, (value) {
    return _then(_self.copyWith(sender: value));
  });
}
}

// dart format on

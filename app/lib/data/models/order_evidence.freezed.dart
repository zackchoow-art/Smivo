// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'order_evidence.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$OrderEvidence {

 String get id;@JsonKey(name: 'order_id') String get orderId;@JsonKey(name: 'uploader_id') String get uploaderId;@JsonKey(name: 'image_url') String get imageUrl;@JsonKey(name: 'evidence_type') String get evidenceType; String? get caption;@JsonKey(name: 'created_at') DateTime get createdAt;@JsonKey(name: 'updated_at') DateTime get updatedAt; UserProfile? get uploader;
/// Create a copy of OrderEvidence
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$OrderEvidenceCopyWith<OrderEvidence> get copyWith => _$OrderEvidenceCopyWithImpl<OrderEvidence>(this as OrderEvidence, _$identity);

  /// Serializes this OrderEvidence to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is OrderEvidence&&(identical(other.id, id) || other.id == id)&&(identical(other.orderId, orderId) || other.orderId == orderId)&&(identical(other.uploaderId, uploaderId) || other.uploaderId == uploaderId)&&(identical(other.imageUrl, imageUrl) || other.imageUrl == imageUrl)&&(identical(other.evidenceType, evidenceType) || other.evidenceType == evidenceType)&&(identical(other.caption, caption) || other.caption == caption)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.uploader, uploader) || other.uploader == uploader));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,orderId,uploaderId,imageUrl,evidenceType,caption,createdAt,updatedAt,uploader);

@override
String toString() {
  return 'OrderEvidence(id: $id, orderId: $orderId, uploaderId: $uploaderId, imageUrl: $imageUrl, evidenceType: $evidenceType, caption: $caption, createdAt: $createdAt, updatedAt: $updatedAt, uploader: $uploader)';
}


}

/// @nodoc
abstract mixin class $OrderEvidenceCopyWith<$Res>  {
  factory $OrderEvidenceCopyWith(OrderEvidence value, $Res Function(OrderEvidence) _then) = _$OrderEvidenceCopyWithImpl;
@useResult
$Res call({
 String id,@JsonKey(name: 'order_id') String orderId,@JsonKey(name: 'uploader_id') String uploaderId,@JsonKey(name: 'image_url') String imageUrl,@JsonKey(name: 'evidence_type') String evidenceType, String? caption,@JsonKey(name: 'created_at') DateTime createdAt,@JsonKey(name: 'updated_at') DateTime updatedAt, UserProfile? uploader
});


$UserProfileCopyWith<$Res>? get uploader;

}
/// @nodoc
class _$OrderEvidenceCopyWithImpl<$Res>
    implements $OrderEvidenceCopyWith<$Res> {
  _$OrderEvidenceCopyWithImpl(this._self, this._then);

  final OrderEvidence _self;
  final $Res Function(OrderEvidence) _then;

/// Create a copy of OrderEvidence
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? orderId = null,Object? uploaderId = null,Object? imageUrl = null,Object? evidenceType = null,Object? caption = freezed,Object? createdAt = null,Object? updatedAt = null,Object? uploader = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,orderId: null == orderId ? _self.orderId : orderId // ignore: cast_nullable_to_non_nullable
as String,uploaderId: null == uploaderId ? _self.uploaderId : uploaderId // ignore: cast_nullable_to_non_nullable
as String,imageUrl: null == imageUrl ? _self.imageUrl : imageUrl // ignore: cast_nullable_to_non_nullable
as String,evidenceType: null == evidenceType ? _self.evidenceType : evidenceType // ignore: cast_nullable_to_non_nullable
as String,caption: freezed == caption ? _self.caption : caption // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,uploader: freezed == uploader ? _self.uploader : uploader // ignore: cast_nullable_to_non_nullable
as UserProfile?,
  ));
}
/// Create a copy of OrderEvidence
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$UserProfileCopyWith<$Res>? get uploader {
    if (_self.uploader == null) {
    return null;
  }

  return $UserProfileCopyWith<$Res>(_self.uploader!, (value) {
    return _then(_self.copyWith(uploader: value));
  });
}
}


/// Adds pattern-matching-related methods to [OrderEvidence].
extension OrderEvidencePatterns on OrderEvidence {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _OrderEvidence value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _OrderEvidence() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _OrderEvidence value)  $default,){
final _that = this;
switch (_that) {
case _OrderEvidence():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _OrderEvidence value)?  $default,){
final _that = this;
switch (_that) {
case _OrderEvidence() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'order_id')  String orderId, @JsonKey(name: 'uploader_id')  String uploaderId, @JsonKey(name: 'image_url')  String imageUrl, @JsonKey(name: 'evidence_type')  String evidenceType,  String? caption, @JsonKey(name: 'created_at')  DateTime createdAt, @JsonKey(name: 'updated_at')  DateTime updatedAt,  UserProfile? uploader)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _OrderEvidence() when $default != null:
return $default(_that.id,_that.orderId,_that.uploaderId,_that.imageUrl,_that.evidenceType,_that.caption,_that.createdAt,_that.updatedAt,_that.uploader);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'order_id')  String orderId, @JsonKey(name: 'uploader_id')  String uploaderId, @JsonKey(name: 'image_url')  String imageUrl, @JsonKey(name: 'evidence_type')  String evidenceType,  String? caption, @JsonKey(name: 'created_at')  DateTime createdAt, @JsonKey(name: 'updated_at')  DateTime updatedAt,  UserProfile? uploader)  $default,) {final _that = this;
switch (_that) {
case _OrderEvidence():
return $default(_that.id,_that.orderId,_that.uploaderId,_that.imageUrl,_that.evidenceType,_that.caption,_that.createdAt,_that.updatedAt,_that.uploader);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id, @JsonKey(name: 'order_id')  String orderId, @JsonKey(name: 'uploader_id')  String uploaderId, @JsonKey(name: 'image_url')  String imageUrl, @JsonKey(name: 'evidence_type')  String evidenceType,  String? caption, @JsonKey(name: 'created_at')  DateTime createdAt, @JsonKey(name: 'updated_at')  DateTime updatedAt,  UserProfile? uploader)?  $default,) {final _that = this;
switch (_that) {
case _OrderEvidence() when $default != null:
return $default(_that.id,_that.orderId,_that.uploaderId,_that.imageUrl,_that.evidenceType,_that.caption,_that.createdAt,_that.updatedAt,_that.uploader);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _OrderEvidence implements OrderEvidence {
  const _OrderEvidence({required this.id, @JsonKey(name: 'order_id') required this.orderId, @JsonKey(name: 'uploader_id') required this.uploaderId, @JsonKey(name: 'image_url') required this.imageUrl, @JsonKey(name: 'evidence_type') this.evidenceType = 'delivery', this.caption, @JsonKey(name: 'created_at') required this.createdAt, @JsonKey(name: 'updated_at') required this.updatedAt, this.uploader});
  factory _OrderEvidence.fromJson(Map<String, dynamic> json) => _$OrderEvidenceFromJson(json);

@override final  String id;
@override@JsonKey(name: 'order_id') final  String orderId;
@override@JsonKey(name: 'uploader_id') final  String uploaderId;
@override@JsonKey(name: 'image_url') final  String imageUrl;
@override@JsonKey(name: 'evidence_type') final  String evidenceType;
@override final  String? caption;
@override@JsonKey(name: 'created_at') final  DateTime createdAt;
@override@JsonKey(name: 'updated_at') final  DateTime updatedAt;
@override final  UserProfile? uploader;

/// Create a copy of OrderEvidence
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$OrderEvidenceCopyWith<_OrderEvidence> get copyWith => __$OrderEvidenceCopyWithImpl<_OrderEvidence>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$OrderEvidenceToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _OrderEvidence&&(identical(other.id, id) || other.id == id)&&(identical(other.orderId, orderId) || other.orderId == orderId)&&(identical(other.uploaderId, uploaderId) || other.uploaderId == uploaderId)&&(identical(other.imageUrl, imageUrl) || other.imageUrl == imageUrl)&&(identical(other.evidenceType, evidenceType) || other.evidenceType == evidenceType)&&(identical(other.caption, caption) || other.caption == caption)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.uploader, uploader) || other.uploader == uploader));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,orderId,uploaderId,imageUrl,evidenceType,caption,createdAt,updatedAt,uploader);

@override
String toString() {
  return 'OrderEvidence(id: $id, orderId: $orderId, uploaderId: $uploaderId, imageUrl: $imageUrl, evidenceType: $evidenceType, caption: $caption, createdAt: $createdAt, updatedAt: $updatedAt, uploader: $uploader)';
}


}

/// @nodoc
abstract mixin class _$OrderEvidenceCopyWith<$Res> implements $OrderEvidenceCopyWith<$Res> {
  factory _$OrderEvidenceCopyWith(_OrderEvidence value, $Res Function(_OrderEvidence) _then) = __$OrderEvidenceCopyWithImpl;
@override @useResult
$Res call({
 String id,@JsonKey(name: 'order_id') String orderId,@JsonKey(name: 'uploader_id') String uploaderId,@JsonKey(name: 'image_url') String imageUrl,@JsonKey(name: 'evidence_type') String evidenceType, String? caption,@JsonKey(name: 'created_at') DateTime createdAt,@JsonKey(name: 'updated_at') DateTime updatedAt, UserProfile? uploader
});


@override $UserProfileCopyWith<$Res>? get uploader;

}
/// @nodoc
class __$OrderEvidenceCopyWithImpl<$Res>
    implements _$OrderEvidenceCopyWith<$Res> {
  __$OrderEvidenceCopyWithImpl(this._self, this._then);

  final _OrderEvidence _self;
  final $Res Function(_OrderEvidence) _then;

/// Create a copy of OrderEvidence
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? orderId = null,Object? uploaderId = null,Object? imageUrl = null,Object? evidenceType = null,Object? caption = freezed,Object? createdAt = null,Object? updatedAt = null,Object? uploader = freezed,}) {
  return _then(_OrderEvidence(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,orderId: null == orderId ? _self.orderId : orderId // ignore: cast_nullable_to_non_nullable
as String,uploaderId: null == uploaderId ? _self.uploaderId : uploaderId // ignore: cast_nullable_to_non_nullable
as String,imageUrl: null == imageUrl ? _self.imageUrl : imageUrl // ignore: cast_nullable_to_non_nullable
as String,evidenceType: null == evidenceType ? _self.evidenceType : evidenceType // ignore: cast_nullable_to_non_nullable
as String,caption: freezed == caption ? _self.caption : caption // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,uploader: freezed == uploader ? _self.uploader : uploader // ignore: cast_nullable_to_non_nullable
as UserProfile?,
  ));
}

/// Create a copy of OrderEvidence
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$UserProfileCopyWith<$Res>? get uploader {
    if (_self.uploader == null) {
    return null;
  }

  return $UserProfileCopyWith<$Res>(_self.uploader!, (value) {
    return _then(_self.copyWith(uploader: value));
  });
}
}

// dart format on

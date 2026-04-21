// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'chat_listing_preview.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ChatListingPreview {

 String get id; String get title; List<ChatListingImage> get images;
/// Create a copy of ChatListingPreview
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ChatListingPreviewCopyWith<ChatListingPreview> get copyWith => _$ChatListingPreviewCopyWithImpl<ChatListingPreview>(this as ChatListingPreview, _$identity);

  /// Serializes this ChatListingPreview to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ChatListingPreview&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&const DeepCollectionEquality().equals(other.images, images));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,title,const DeepCollectionEquality().hash(images));

@override
String toString() {
  return 'ChatListingPreview(id: $id, title: $title, images: $images)';
}


}

/// @nodoc
abstract mixin class $ChatListingPreviewCopyWith<$Res>  {
  factory $ChatListingPreviewCopyWith(ChatListingPreview value, $Res Function(ChatListingPreview) _then) = _$ChatListingPreviewCopyWithImpl;
@useResult
$Res call({
 String id, String title, List<ChatListingImage> images
});




}
/// @nodoc
class _$ChatListingPreviewCopyWithImpl<$Res>
    implements $ChatListingPreviewCopyWith<$Res> {
  _$ChatListingPreviewCopyWithImpl(this._self, this._then);

  final ChatListingPreview _self;
  final $Res Function(ChatListingPreview) _then;

/// Create a copy of ChatListingPreview
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? title = null,Object? images = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,images: null == images ? _self.images : images // ignore: cast_nullable_to_non_nullable
as List<ChatListingImage>,
  ));
}

}


/// Adds pattern-matching-related methods to [ChatListingPreview].
extension ChatListingPreviewPatterns on ChatListingPreview {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ChatListingPreview value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ChatListingPreview() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ChatListingPreview value)  $default,){
final _that = this;
switch (_that) {
case _ChatListingPreview():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ChatListingPreview value)?  $default,){
final _that = this;
switch (_that) {
case _ChatListingPreview() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String title,  List<ChatListingImage> images)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ChatListingPreview() when $default != null:
return $default(_that.id,_that.title,_that.images);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String title,  List<ChatListingImage> images)  $default,) {final _that = this;
switch (_that) {
case _ChatListingPreview():
return $default(_that.id,_that.title,_that.images);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String title,  List<ChatListingImage> images)?  $default,) {final _that = this;
switch (_that) {
case _ChatListingPreview() when $default != null:
return $default(_that.id,_that.title,_that.images);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ChatListingPreview implements ChatListingPreview {
  const _ChatListingPreview({required this.id, required this.title, final  List<ChatListingImage> images = const []}): _images = images;
  factory _ChatListingPreview.fromJson(Map<String, dynamic> json) => _$ChatListingPreviewFromJson(json);

@override final  String id;
@override final  String title;
 final  List<ChatListingImage> _images;
@override@JsonKey() List<ChatListingImage> get images {
  if (_images is EqualUnmodifiableListView) return _images;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_images);
}


/// Create a copy of ChatListingPreview
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ChatListingPreviewCopyWith<_ChatListingPreview> get copyWith => __$ChatListingPreviewCopyWithImpl<_ChatListingPreview>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ChatListingPreviewToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ChatListingPreview&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&const DeepCollectionEquality().equals(other._images, _images));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,title,const DeepCollectionEquality().hash(_images));

@override
String toString() {
  return 'ChatListingPreview(id: $id, title: $title, images: $images)';
}


}

/// @nodoc
abstract mixin class _$ChatListingPreviewCopyWith<$Res> implements $ChatListingPreviewCopyWith<$Res> {
  factory _$ChatListingPreviewCopyWith(_ChatListingPreview value, $Res Function(_ChatListingPreview) _then) = __$ChatListingPreviewCopyWithImpl;
@override @useResult
$Res call({
 String id, String title, List<ChatListingImage> images
});




}
/// @nodoc
class __$ChatListingPreviewCopyWithImpl<$Res>
    implements _$ChatListingPreviewCopyWith<$Res> {
  __$ChatListingPreviewCopyWithImpl(this._self, this._then);

  final _ChatListingPreview _self;
  final $Res Function(_ChatListingPreview) _then;

/// Create a copy of ChatListingPreview
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? title = null,Object? images = null,}) {
  return _then(_ChatListingPreview(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,images: null == images ? _self._images : images // ignore: cast_nullable_to_non_nullable
as List<ChatListingImage>,
  ));
}


}


/// @nodoc
mixin _$ChatListingImage {

@JsonKey(name: 'image_url') String get imageUrl;
/// Create a copy of ChatListingImage
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ChatListingImageCopyWith<ChatListingImage> get copyWith => _$ChatListingImageCopyWithImpl<ChatListingImage>(this as ChatListingImage, _$identity);

  /// Serializes this ChatListingImage to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ChatListingImage&&(identical(other.imageUrl, imageUrl) || other.imageUrl == imageUrl));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,imageUrl);

@override
String toString() {
  return 'ChatListingImage(imageUrl: $imageUrl)';
}


}

/// @nodoc
abstract mixin class $ChatListingImageCopyWith<$Res>  {
  factory $ChatListingImageCopyWith(ChatListingImage value, $Res Function(ChatListingImage) _then) = _$ChatListingImageCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'image_url') String imageUrl
});




}
/// @nodoc
class _$ChatListingImageCopyWithImpl<$Res>
    implements $ChatListingImageCopyWith<$Res> {
  _$ChatListingImageCopyWithImpl(this._self, this._then);

  final ChatListingImage _self;
  final $Res Function(ChatListingImage) _then;

/// Create a copy of ChatListingImage
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? imageUrl = null,}) {
  return _then(_self.copyWith(
imageUrl: null == imageUrl ? _self.imageUrl : imageUrl // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [ChatListingImage].
extension ChatListingImagePatterns on ChatListingImage {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ChatListingImage value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ChatListingImage() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ChatListingImage value)  $default,){
final _that = this;
switch (_that) {
case _ChatListingImage():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ChatListingImage value)?  $default,){
final _that = this;
switch (_that) {
case _ChatListingImage() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'image_url')  String imageUrl)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ChatListingImage() when $default != null:
return $default(_that.imageUrl);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'image_url')  String imageUrl)  $default,) {final _that = this;
switch (_that) {
case _ChatListingImage():
return $default(_that.imageUrl);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'image_url')  String imageUrl)?  $default,) {final _that = this;
switch (_that) {
case _ChatListingImage() when $default != null:
return $default(_that.imageUrl);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ChatListingImage implements ChatListingImage {
  const _ChatListingImage({@JsonKey(name: 'image_url') required this.imageUrl});
  factory _ChatListingImage.fromJson(Map<String, dynamic> json) => _$ChatListingImageFromJson(json);

@override@JsonKey(name: 'image_url') final  String imageUrl;

/// Create a copy of ChatListingImage
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ChatListingImageCopyWith<_ChatListingImage> get copyWith => __$ChatListingImageCopyWithImpl<_ChatListingImage>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ChatListingImageToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ChatListingImage&&(identical(other.imageUrl, imageUrl) || other.imageUrl == imageUrl));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,imageUrl);

@override
String toString() {
  return 'ChatListingImage(imageUrl: $imageUrl)';
}


}

/// @nodoc
abstract mixin class _$ChatListingImageCopyWith<$Res> implements $ChatListingImageCopyWith<$Res> {
  factory _$ChatListingImageCopyWith(_ChatListingImage value, $Res Function(_ChatListingImage) _then) = __$ChatListingImageCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'image_url') String imageUrl
});




}
/// @nodoc
class __$ChatListingImageCopyWithImpl<$Res>
    implements _$ChatListingImageCopyWith<$Res> {
  __$ChatListingImageCopyWithImpl(this._self, this._then);

  final _ChatListingImage _self;
  final $Res Function(_ChatListingImage) _then;

/// Create a copy of ChatListingImage
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? imageUrl = null,}) {
  return _then(_ChatListingImage(
imageUrl: null == imageUrl ? _self.imageUrl : imageUrl // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on

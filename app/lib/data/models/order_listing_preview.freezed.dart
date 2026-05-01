// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'order_listing_preview.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$OrderListingPreview {

 String get id; String get title; List<OrderListingImage> get images;@JsonKey(name: 'rental_daily_price') double? get rentalDailyPrice;@JsonKey(name: 'rental_weekly_price') double? get rentalWeeklyPrice;@JsonKey(name: 'rental_monthly_price') double? get rentalMonthlyPrice;@JsonKey(name: 'deposit_amount') double get depositAmount;
/// Create a copy of OrderListingPreview
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$OrderListingPreviewCopyWith<OrderListingPreview> get copyWith => _$OrderListingPreviewCopyWithImpl<OrderListingPreview>(this as OrderListingPreview, _$identity);

  /// Serializes this OrderListingPreview to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is OrderListingPreview&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&const DeepCollectionEquality().equals(other.images, images)&&(identical(other.rentalDailyPrice, rentalDailyPrice) || other.rentalDailyPrice == rentalDailyPrice)&&(identical(other.rentalWeeklyPrice, rentalWeeklyPrice) || other.rentalWeeklyPrice == rentalWeeklyPrice)&&(identical(other.rentalMonthlyPrice, rentalMonthlyPrice) || other.rentalMonthlyPrice == rentalMonthlyPrice)&&(identical(other.depositAmount, depositAmount) || other.depositAmount == depositAmount));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,title,const DeepCollectionEquality().hash(images),rentalDailyPrice,rentalWeeklyPrice,rentalMonthlyPrice,depositAmount);

@override
String toString() {
  return 'OrderListingPreview(id: $id, title: $title, images: $images, rentalDailyPrice: $rentalDailyPrice, rentalWeeklyPrice: $rentalWeeklyPrice, rentalMonthlyPrice: $rentalMonthlyPrice, depositAmount: $depositAmount)';
}


}

/// @nodoc
abstract mixin class $OrderListingPreviewCopyWith<$Res>  {
  factory $OrderListingPreviewCopyWith(OrderListingPreview value, $Res Function(OrderListingPreview) _then) = _$OrderListingPreviewCopyWithImpl;
@useResult
$Res call({
 String id, String title, List<OrderListingImage> images,@JsonKey(name: 'rental_daily_price') double? rentalDailyPrice,@JsonKey(name: 'rental_weekly_price') double? rentalWeeklyPrice,@JsonKey(name: 'rental_monthly_price') double? rentalMonthlyPrice,@JsonKey(name: 'deposit_amount') double depositAmount
});




}
/// @nodoc
class _$OrderListingPreviewCopyWithImpl<$Res>
    implements $OrderListingPreviewCopyWith<$Res> {
  _$OrderListingPreviewCopyWithImpl(this._self, this._then);

  final OrderListingPreview _self;
  final $Res Function(OrderListingPreview) _then;

/// Create a copy of OrderListingPreview
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? title = null,Object? images = null,Object? rentalDailyPrice = freezed,Object? rentalWeeklyPrice = freezed,Object? rentalMonthlyPrice = freezed,Object? depositAmount = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,images: null == images ? _self.images : images // ignore: cast_nullable_to_non_nullable
as List<OrderListingImage>,rentalDailyPrice: freezed == rentalDailyPrice ? _self.rentalDailyPrice : rentalDailyPrice // ignore: cast_nullable_to_non_nullable
as double?,rentalWeeklyPrice: freezed == rentalWeeklyPrice ? _self.rentalWeeklyPrice : rentalWeeklyPrice // ignore: cast_nullable_to_non_nullable
as double?,rentalMonthlyPrice: freezed == rentalMonthlyPrice ? _self.rentalMonthlyPrice : rentalMonthlyPrice // ignore: cast_nullable_to_non_nullable
as double?,depositAmount: null == depositAmount ? _self.depositAmount : depositAmount // ignore: cast_nullable_to_non_nullable
as double,
  ));
}

}


/// Adds pattern-matching-related methods to [OrderListingPreview].
extension OrderListingPreviewPatterns on OrderListingPreview {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _OrderListingPreview value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _OrderListingPreview() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _OrderListingPreview value)  $default,){
final _that = this;
switch (_that) {
case _OrderListingPreview():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _OrderListingPreview value)?  $default,){
final _that = this;
switch (_that) {
case _OrderListingPreview() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String title,  List<OrderListingImage> images, @JsonKey(name: 'rental_daily_price')  double? rentalDailyPrice, @JsonKey(name: 'rental_weekly_price')  double? rentalWeeklyPrice, @JsonKey(name: 'rental_monthly_price')  double? rentalMonthlyPrice, @JsonKey(name: 'deposit_amount')  double depositAmount)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _OrderListingPreview() when $default != null:
return $default(_that.id,_that.title,_that.images,_that.rentalDailyPrice,_that.rentalWeeklyPrice,_that.rentalMonthlyPrice,_that.depositAmount);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String title,  List<OrderListingImage> images, @JsonKey(name: 'rental_daily_price')  double? rentalDailyPrice, @JsonKey(name: 'rental_weekly_price')  double? rentalWeeklyPrice, @JsonKey(name: 'rental_monthly_price')  double? rentalMonthlyPrice, @JsonKey(name: 'deposit_amount')  double depositAmount)  $default,) {final _that = this;
switch (_that) {
case _OrderListingPreview():
return $default(_that.id,_that.title,_that.images,_that.rentalDailyPrice,_that.rentalWeeklyPrice,_that.rentalMonthlyPrice,_that.depositAmount);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String title,  List<OrderListingImage> images, @JsonKey(name: 'rental_daily_price')  double? rentalDailyPrice, @JsonKey(name: 'rental_weekly_price')  double? rentalWeeklyPrice, @JsonKey(name: 'rental_monthly_price')  double? rentalMonthlyPrice, @JsonKey(name: 'deposit_amount')  double depositAmount)?  $default,) {final _that = this;
switch (_that) {
case _OrderListingPreview() when $default != null:
return $default(_that.id,_that.title,_that.images,_that.rentalDailyPrice,_that.rentalWeeklyPrice,_that.rentalMonthlyPrice,_that.depositAmount);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _OrderListingPreview implements OrderListingPreview {
  const _OrderListingPreview({required this.id, required this.title, final  List<OrderListingImage> images = const [], @JsonKey(name: 'rental_daily_price') this.rentalDailyPrice, @JsonKey(name: 'rental_weekly_price') this.rentalWeeklyPrice, @JsonKey(name: 'rental_monthly_price') this.rentalMonthlyPrice, @JsonKey(name: 'deposit_amount') this.depositAmount = 0.0}): _images = images;
  factory _OrderListingPreview.fromJson(Map<String, dynamic> json) => _$OrderListingPreviewFromJson(json);

@override final  String id;
@override final  String title;
 final  List<OrderListingImage> _images;
@override@JsonKey() List<OrderListingImage> get images {
  if (_images is EqualUnmodifiableListView) return _images;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_images);
}

@override@JsonKey(name: 'rental_daily_price') final  double? rentalDailyPrice;
@override@JsonKey(name: 'rental_weekly_price') final  double? rentalWeeklyPrice;
@override@JsonKey(name: 'rental_monthly_price') final  double? rentalMonthlyPrice;
@override@JsonKey(name: 'deposit_amount') final  double depositAmount;

/// Create a copy of OrderListingPreview
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$OrderListingPreviewCopyWith<_OrderListingPreview> get copyWith => __$OrderListingPreviewCopyWithImpl<_OrderListingPreview>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$OrderListingPreviewToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _OrderListingPreview&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&const DeepCollectionEquality().equals(other._images, _images)&&(identical(other.rentalDailyPrice, rentalDailyPrice) || other.rentalDailyPrice == rentalDailyPrice)&&(identical(other.rentalWeeklyPrice, rentalWeeklyPrice) || other.rentalWeeklyPrice == rentalWeeklyPrice)&&(identical(other.rentalMonthlyPrice, rentalMonthlyPrice) || other.rentalMonthlyPrice == rentalMonthlyPrice)&&(identical(other.depositAmount, depositAmount) || other.depositAmount == depositAmount));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,title,const DeepCollectionEquality().hash(_images),rentalDailyPrice,rentalWeeklyPrice,rentalMonthlyPrice,depositAmount);

@override
String toString() {
  return 'OrderListingPreview(id: $id, title: $title, images: $images, rentalDailyPrice: $rentalDailyPrice, rentalWeeklyPrice: $rentalWeeklyPrice, rentalMonthlyPrice: $rentalMonthlyPrice, depositAmount: $depositAmount)';
}


}

/// @nodoc
abstract mixin class _$OrderListingPreviewCopyWith<$Res> implements $OrderListingPreviewCopyWith<$Res> {
  factory _$OrderListingPreviewCopyWith(_OrderListingPreview value, $Res Function(_OrderListingPreview) _then) = __$OrderListingPreviewCopyWithImpl;
@override @useResult
$Res call({
 String id, String title, List<OrderListingImage> images,@JsonKey(name: 'rental_daily_price') double? rentalDailyPrice,@JsonKey(name: 'rental_weekly_price') double? rentalWeeklyPrice,@JsonKey(name: 'rental_monthly_price') double? rentalMonthlyPrice,@JsonKey(name: 'deposit_amount') double depositAmount
});




}
/// @nodoc
class __$OrderListingPreviewCopyWithImpl<$Res>
    implements _$OrderListingPreviewCopyWith<$Res> {
  __$OrderListingPreviewCopyWithImpl(this._self, this._then);

  final _OrderListingPreview _self;
  final $Res Function(_OrderListingPreview) _then;

/// Create a copy of OrderListingPreview
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? title = null,Object? images = null,Object? rentalDailyPrice = freezed,Object? rentalWeeklyPrice = freezed,Object? rentalMonthlyPrice = freezed,Object? depositAmount = null,}) {
  return _then(_OrderListingPreview(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,images: null == images ? _self._images : images // ignore: cast_nullable_to_non_nullable
as List<OrderListingImage>,rentalDailyPrice: freezed == rentalDailyPrice ? _self.rentalDailyPrice : rentalDailyPrice // ignore: cast_nullable_to_non_nullable
as double?,rentalWeeklyPrice: freezed == rentalWeeklyPrice ? _self.rentalWeeklyPrice : rentalWeeklyPrice // ignore: cast_nullable_to_non_nullable
as double?,rentalMonthlyPrice: freezed == rentalMonthlyPrice ? _self.rentalMonthlyPrice : rentalMonthlyPrice // ignore: cast_nullable_to_non_nullable
as double?,depositAmount: null == depositAmount ? _self.depositAmount : depositAmount // ignore: cast_nullable_to_non_nullable
as double,
  ));
}


}


/// @nodoc
mixin _$OrderListingImage {

@JsonKey(name: 'image_url') String get imageUrl;
/// Create a copy of OrderListingImage
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$OrderListingImageCopyWith<OrderListingImage> get copyWith => _$OrderListingImageCopyWithImpl<OrderListingImage>(this as OrderListingImage, _$identity);

  /// Serializes this OrderListingImage to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is OrderListingImage&&(identical(other.imageUrl, imageUrl) || other.imageUrl == imageUrl));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,imageUrl);

@override
String toString() {
  return 'OrderListingImage(imageUrl: $imageUrl)';
}


}

/// @nodoc
abstract mixin class $OrderListingImageCopyWith<$Res>  {
  factory $OrderListingImageCopyWith(OrderListingImage value, $Res Function(OrderListingImage) _then) = _$OrderListingImageCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'image_url') String imageUrl
});




}
/// @nodoc
class _$OrderListingImageCopyWithImpl<$Res>
    implements $OrderListingImageCopyWith<$Res> {
  _$OrderListingImageCopyWithImpl(this._self, this._then);

  final OrderListingImage _self;
  final $Res Function(OrderListingImage) _then;

/// Create a copy of OrderListingImage
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? imageUrl = null,}) {
  return _then(_self.copyWith(
imageUrl: null == imageUrl ? _self.imageUrl : imageUrl // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [OrderListingImage].
extension OrderListingImagePatterns on OrderListingImage {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _OrderListingImage value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _OrderListingImage() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _OrderListingImage value)  $default,){
final _that = this;
switch (_that) {
case _OrderListingImage():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _OrderListingImage value)?  $default,){
final _that = this;
switch (_that) {
case _OrderListingImage() when $default != null:
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
case _OrderListingImage() when $default != null:
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
case _OrderListingImage():
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
case _OrderListingImage() when $default != null:
return $default(_that.imageUrl);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _OrderListingImage implements OrderListingImage {
  const _OrderListingImage({@JsonKey(name: 'image_url') required this.imageUrl});
  factory _OrderListingImage.fromJson(Map<String, dynamic> json) => _$OrderListingImageFromJson(json);

@override@JsonKey(name: 'image_url') final  String imageUrl;

/// Create a copy of OrderListingImage
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$OrderListingImageCopyWith<_OrderListingImage> get copyWith => __$OrderListingImageCopyWithImpl<_OrderListingImage>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$OrderListingImageToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _OrderListingImage&&(identical(other.imageUrl, imageUrl) || other.imageUrl == imageUrl));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,imageUrl);

@override
String toString() {
  return 'OrderListingImage(imageUrl: $imageUrl)';
}


}

/// @nodoc
abstract mixin class _$OrderListingImageCopyWith<$Res> implements $OrderListingImageCopyWith<$Res> {
  factory _$OrderListingImageCopyWith(_OrderListingImage value, $Res Function(_OrderListingImage) _then) = __$OrderListingImageCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'image_url') String imageUrl
});




}
/// @nodoc
class __$OrderListingImageCopyWithImpl<$Res>
    implements _$OrderListingImageCopyWith<$Res> {
  __$OrderListingImageCopyWithImpl(this._self, this._then);

  final _OrderListingImage _self;
  final $Res Function(_OrderListingImage) _then;

/// Create a copy of OrderListingImage
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? imageUrl = null,}) {
  return _then(_OrderListingImage(
imageUrl: null == imageUrl ? _self.imageUrl : imageUrl // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on

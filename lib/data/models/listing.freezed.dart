// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'listing.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Listing {

 String get id;@JsonKey(name: 'seller_id') String get sellerId; String get title; String? get description; String get category; double get price;@JsonKey(name: 'transaction_type') String get transactionType; String get status;@JsonKey(name: 'view_count') int get viewCount;// NOTE: save_count and inquiry_count are server-managed counters;
// the client reads them but never writes directly.
@JsonKey(name: 'save_count') int get saveCount;@JsonKey(name: 'inquiry_count') int get inquiryCount;@JsonKey(name: 'allow_pickup_change') bool get allowPickupChange;@JsonKey(name: 'rental_daily_price') double? get rentalDailyPrice;@JsonKey(name: 'rental_weekly_price') double? get rentalWeeklyPrice;@JsonKey(name: 'rental_monthly_price') double? get rentalMonthlyPrice;@JsonKey(name: 'is_pinned') bool get isPinned;@JsonKey(name: 'pinned_days') int? get pinnedDays;// NOTE: images is populated from the listing_images join;
// defaults to empty list when only the listing row is fetched.
 List<ListingImage> get images;// NOTE: seller is only present on detail fetches that join user_profiles.
// It is intentionally nullable to support list-view queries.
 UserProfile? get seller;@JsonKey(name: 'created_at') DateTime get createdAt;@JsonKey(name: 'updated_at') DateTime get updatedAt;
/// Create a copy of Listing
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ListingCopyWith<Listing> get copyWith => _$ListingCopyWithImpl<Listing>(this as Listing, _$identity);

  /// Serializes this Listing to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Listing&&(identical(other.id, id) || other.id == id)&&(identical(other.sellerId, sellerId) || other.sellerId == sellerId)&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description)&&(identical(other.category, category) || other.category == category)&&(identical(other.price, price) || other.price == price)&&(identical(other.transactionType, transactionType) || other.transactionType == transactionType)&&(identical(other.status, status) || other.status == status)&&(identical(other.viewCount, viewCount) || other.viewCount == viewCount)&&(identical(other.saveCount, saveCount) || other.saveCount == saveCount)&&(identical(other.inquiryCount, inquiryCount) || other.inquiryCount == inquiryCount)&&(identical(other.allowPickupChange, allowPickupChange) || other.allowPickupChange == allowPickupChange)&&(identical(other.rentalDailyPrice, rentalDailyPrice) || other.rentalDailyPrice == rentalDailyPrice)&&(identical(other.rentalWeeklyPrice, rentalWeeklyPrice) || other.rentalWeeklyPrice == rentalWeeklyPrice)&&(identical(other.rentalMonthlyPrice, rentalMonthlyPrice) || other.rentalMonthlyPrice == rentalMonthlyPrice)&&(identical(other.isPinned, isPinned) || other.isPinned == isPinned)&&(identical(other.pinnedDays, pinnedDays) || other.pinnedDays == pinnedDays)&&const DeepCollectionEquality().equals(other.images, images)&&(identical(other.seller, seller) || other.seller == seller)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,sellerId,title,description,category,price,transactionType,status,viewCount,saveCount,inquiryCount,allowPickupChange,rentalDailyPrice,rentalWeeklyPrice,rentalMonthlyPrice,isPinned,pinnedDays,const DeepCollectionEquality().hash(images),seller,createdAt,updatedAt]);

@override
String toString() {
  return 'Listing(id: $id, sellerId: $sellerId, title: $title, description: $description, category: $category, price: $price, transactionType: $transactionType, status: $status, viewCount: $viewCount, saveCount: $saveCount, inquiryCount: $inquiryCount, allowPickupChange: $allowPickupChange, rentalDailyPrice: $rentalDailyPrice, rentalWeeklyPrice: $rentalWeeklyPrice, rentalMonthlyPrice: $rentalMonthlyPrice, isPinned: $isPinned, pinnedDays: $pinnedDays, images: $images, seller: $seller, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $ListingCopyWith<$Res>  {
  factory $ListingCopyWith(Listing value, $Res Function(Listing) _then) = _$ListingCopyWithImpl;
@useResult
$Res call({
 String id,@JsonKey(name: 'seller_id') String sellerId, String title, String? description, String category, double price,@JsonKey(name: 'transaction_type') String transactionType, String status,@JsonKey(name: 'view_count') int viewCount,@JsonKey(name: 'save_count') int saveCount,@JsonKey(name: 'inquiry_count') int inquiryCount,@JsonKey(name: 'allow_pickup_change') bool allowPickupChange,@JsonKey(name: 'rental_daily_price') double? rentalDailyPrice,@JsonKey(name: 'rental_weekly_price') double? rentalWeeklyPrice,@JsonKey(name: 'rental_monthly_price') double? rentalMonthlyPrice,@JsonKey(name: 'is_pinned') bool isPinned,@JsonKey(name: 'pinned_days') int? pinnedDays, List<ListingImage> images, UserProfile? seller,@JsonKey(name: 'created_at') DateTime createdAt,@JsonKey(name: 'updated_at') DateTime updatedAt
});


$UserProfileCopyWith<$Res>? get seller;

}
/// @nodoc
class _$ListingCopyWithImpl<$Res>
    implements $ListingCopyWith<$Res> {
  _$ListingCopyWithImpl(this._self, this._then);

  final Listing _self;
  final $Res Function(Listing) _then;

/// Create a copy of Listing
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? sellerId = null,Object? title = null,Object? description = freezed,Object? category = null,Object? price = null,Object? transactionType = null,Object? status = null,Object? viewCount = null,Object? saveCount = null,Object? inquiryCount = null,Object? allowPickupChange = null,Object? rentalDailyPrice = freezed,Object? rentalWeeklyPrice = freezed,Object? rentalMonthlyPrice = freezed,Object? isPinned = null,Object? pinnedDays = freezed,Object? images = null,Object? seller = freezed,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,sellerId: null == sellerId ? _self.sellerId : sellerId // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String,price: null == price ? _self.price : price // ignore: cast_nullable_to_non_nullable
as double,transactionType: null == transactionType ? _self.transactionType : transactionType // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,viewCount: null == viewCount ? _self.viewCount : viewCount // ignore: cast_nullable_to_non_nullable
as int,saveCount: null == saveCount ? _self.saveCount : saveCount // ignore: cast_nullable_to_non_nullable
as int,inquiryCount: null == inquiryCount ? _self.inquiryCount : inquiryCount // ignore: cast_nullable_to_non_nullable
as int,allowPickupChange: null == allowPickupChange ? _self.allowPickupChange : allowPickupChange // ignore: cast_nullable_to_non_nullable
as bool,rentalDailyPrice: freezed == rentalDailyPrice ? _self.rentalDailyPrice : rentalDailyPrice // ignore: cast_nullable_to_non_nullable
as double?,rentalWeeklyPrice: freezed == rentalWeeklyPrice ? _self.rentalWeeklyPrice : rentalWeeklyPrice // ignore: cast_nullable_to_non_nullable
as double?,rentalMonthlyPrice: freezed == rentalMonthlyPrice ? _self.rentalMonthlyPrice : rentalMonthlyPrice // ignore: cast_nullable_to_non_nullable
as double?,isPinned: null == isPinned ? _self.isPinned : isPinned // ignore: cast_nullable_to_non_nullable
as bool,pinnedDays: freezed == pinnedDays ? _self.pinnedDays : pinnedDays // ignore: cast_nullable_to_non_nullable
as int?,images: null == images ? _self.images : images // ignore: cast_nullable_to_non_nullable
as List<ListingImage>,seller: freezed == seller ? _self.seller : seller // ignore: cast_nullable_to_non_nullable
as UserProfile?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}
/// Create a copy of Listing
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$UserProfileCopyWith<$Res>? get seller {
    if (_self.seller == null) {
    return null;
  }

  return $UserProfileCopyWith<$Res>(_self.seller!, (value) {
    return _then(_self.copyWith(seller: value));
  });
}
}


/// Adds pattern-matching-related methods to [Listing].
extension ListingPatterns on Listing {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Listing value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Listing() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Listing value)  $default,){
final _that = this;
switch (_that) {
case _Listing():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Listing value)?  $default,){
final _that = this;
switch (_that) {
case _Listing() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'seller_id')  String sellerId,  String title,  String? description,  String category,  double price, @JsonKey(name: 'transaction_type')  String transactionType,  String status, @JsonKey(name: 'view_count')  int viewCount, @JsonKey(name: 'save_count')  int saveCount, @JsonKey(name: 'inquiry_count')  int inquiryCount, @JsonKey(name: 'allow_pickup_change')  bool allowPickupChange, @JsonKey(name: 'rental_daily_price')  double? rentalDailyPrice, @JsonKey(name: 'rental_weekly_price')  double? rentalWeeklyPrice, @JsonKey(name: 'rental_monthly_price')  double? rentalMonthlyPrice, @JsonKey(name: 'is_pinned')  bool isPinned, @JsonKey(name: 'pinned_days')  int? pinnedDays,  List<ListingImage> images,  UserProfile? seller, @JsonKey(name: 'created_at')  DateTime createdAt, @JsonKey(name: 'updated_at')  DateTime updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Listing() when $default != null:
return $default(_that.id,_that.sellerId,_that.title,_that.description,_that.category,_that.price,_that.transactionType,_that.status,_that.viewCount,_that.saveCount,_that.inquiryCount,_that.allowPickupChange,_that.rentalDailyPrice,_that.rentalWeeklyPrice,_that.rentalMonthlyPrice,_that.isPinned,_that.pinnedDays,_that.images,_that.seller,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'seller_id')  String sellerId,  String title,  String? description,  String category,  double price, @JsonKey(name: 'transaction_type')  String transactionType,  String status, @JsonKey(name: 'view_count')  int viewCount, @JsonKey(name: 'save_count')  int saveCount, @JsonKey(name: 'inquiry_count')  int inquiryCount, @JsonKey(name: 'allow_pickup_change')  bool allowPickupChange, @JsonKey(name: 'rental_daily_price')  double? rentalDailyPrice, @JsonKey(name: 'rental_weekly_price')  double? rentalWeeklyPrice, @JsonKey(name: 'rental_monthly_price')  double? rentalMonthlyPrice, @JsonKey(name: 'is_pinned')  bool isPinned, @JsonKey(name: 'pinned_days')  int? pinnedDays,  List<ListingImage> images,  UserProfile? seller, @JsonKey(name: 'created_at')  DateTime createdAt, @JsonKey(name: 'updated_at')  DateTime updatedAt)  $default,) {final _that = this;
switch (_that) {
case _Listing():
return $default(_that.id,_that.sellerId,_that.title,_that.description,_that.category,_that.price,_that.transactionType,_that.status,_that.viewCount,_that.saveCount,_that.inquiryCount,_that.allowPickupChange,_that.rentalDailyPrice,_that.rentalWeeklyPrice,_that.rentalMonthlyPrice,_that.isPinned,_that.pinnedDays,_that.images,_that.seller,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id, @JsonKey(name: 'seller_id')  String sellerId,  String title,  String? description,  String category,  double price, @JsonKey(name: 'transaction_type')  String transactionType,  String status, @JsonKey(name: 'view_count')  int viewCount, @JsonKey(name: 'save_count')  int saveCount, @JsonKey(name: 'inquiry_count')  int inquiryCount, @JsonKey(name: 'allow_pickup_change')  bool allowPickupChange, @JsonKey(name: 'rental_daily_price')  double? rentalDailyPrice, @JsonKey(name: 'rental_weekly_price')  double? rentalWeeklyPrice, @JsonKey(name: 'rental_monthly_price')  double? rentalMonthlyPrice, @JsonKey(name: 'is_pinned')  bool isPinned, @JsonKey(name: 'pinned_days')  int? pinnedDays,  List<ListingImage> images,  UserProfile? seller, @JsonKey(name: 'created_at')  DateTime createdAt, @JsonKey(name: 'updated_at')  DateTime updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _Listing() when $default != null:
return $default(_that.id,_that.sellerId,_that.title,_that.description,_that.category,_that.price,_that.transactionType,_that.status,_that.viewCount,_that.saveCount,_that.inquiryCount,_that.allowPickupChange,_that.rentalDailyPrice,_that.rentalWeeklyPrice,_that.rentalMonthlyPrice,_that.isPinned,_that.pinnedDays,_that.images,_that.seller,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Listing implements Listing {
  const _Listing({required this.id, @JsonKey(name: 'seller_id') required this.sellerId, required this.title, this.description, required this.category, required this.price, @JsonKey(name: 'transaction_type') required this.transactionType, this.status = 'active', @JsonKey(name: 'view_count') this.viewCount = 0, @JsonKey(name: 'save_count') this.saveCount = 0, @JsonKey(name: 'inquiry_count') this.inquiryCount = 0, @JsonKey(name: 'allow_pickup_change') this.allowPickupChange = false, @JsonKey(name: 'rental_daily_price') this.rentalDailyPrice, @JsonKey(name: 'rental_weekly_price') this.rentalWeeklyPrice, @JsonKey(name: 'rental_monthly_price') this.rentalMonthlyPrice, @JsonKey(name: 'is_pinned') this.isPinned = false, @JsonKey(name: 'pinned_days') this.pinnedDays, final  List<ListingImage> images = const [], this.seller, @JsonKey(name: 'created_at') required this.createdAt, @JsonKey(name: 'updated_at') required this.updatedAt}): _images = images;
  factory _Listing.fromJson(Map<String, dynamic> json) => _$ListingFromJson(json);

@override final  String id;
@override@JsonKey(name: 'seller_id') final  String sellerId;
@override final  String title;
@override final  String? description;
@override final  String category;
@override final  double price;
@override@JsonKey(name: 'transaction_type') final  String transactionType;
@override@JsonKey() final  String status;
@override@JsonKey(name: 'view_count') final  int viewCount;
// NOTE: save_count and inquiry_count are server-managed counters;
// the client reads them but never writes directly.
@override@JsonKey(name: 'save_count') final  int saveCount;
@override@JsonKey(name: 'inquiry_count') final  int inquiryCount;
@override@JsonKey(name: 'allow_pickup_change') final  bool allowPickupChange;
@override@JsonKey(name: 'rental_daily_price') final  double? rentalDailyPrice;
@override@JsonKey(name: 'rental_weekly_price') final  double? rentalWeeklyPrice;
@override@JsonKey(name: 'rental_monthly_price') final  double? rentalMonthlyPrice;
@override@JsonKey(name: 'is_pinned') final  bool isPinned;
@override@JsonKey(name: 'pinned_days') final  int? pinnedDays;
// NOTE: images is populated from the listing_images join;
// defaults to empty list when only the listing row is fetched.
 final  List<ListingImage> _images;
// NOTE: images is populated from the listing_images join;
// defaults to empty list when only the listing row is fetched.
@override@JsonKey() List<ListingImage> get images {
  if (_images is EqualUnmodifiableListView) return _images;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_images);
}

// NOTE: seller is only present on detail fetches that join user_profiles.
// It is intentionally nullable to support list-view queries.
@override final  UserProfile? seller;
@override@JsonKey(name: 'created_at') final  DateTime createdAt;
@override@JsonKey(name: 'updated_at') final  DateTime updatedAt;

/// Create a copy of Listing
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ListingCopyWith<_Listing> get copyWith => __$ListingCopyWithImpl<_Listing>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ListingToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Listing&&(identical(other.id, id) || other.id == id)&&(identical(other.sellerId, sellerId) || other.sellerId == sellerId)&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description)&&(identical(other.category, category) || other.category == category)&&(identical(other.price, price) || other.price == price)&&(identical(other.transactionType, transactionType) || other.transactionType == transactionType)&&(identical(other.status, status) || other.status == status)&&(identical(other.viewCount, viewCount) || other.viewCount == viewCount)&&(identical(other.saveCount, saveCount) || other.saveCount == saveCount)&&(identical(other.inquiryCount, inquiryCount) || other.inquiryCount == inquiryCount)&&(identical(other.allowPickupChange, allowPickupChange) || other.allowPickupChange == allowPickupChange)&&(identical(other.rentalDailyPrice, rentalDailyPrice) || other.rentalDailyPrice == rentalDailyPrice)&&(identical(other.rentalWeeklyPrice, rentalWeeklyPrice) || other.rentalWeeklyPrice == rentalWeeklyPrice)&&(identical(other.rentalMonthlyPrice, rentalMonthlyPrice) || other.rentalMonthlyPrice == rentalMonthlyPrice)&&(identical(other.isPinned, isPinned) || other.isPinned == isPinned)&&(identical(other.pinnedDays, pinnedDays) || other.pinnedDays == pinnedDays)&&const DeepCollectionEquality().equals(other._images, _images)&&(identical(other.seller, seller) || other.seller == seller)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,sellerId,title,description,category,price,transactionType,status,viewCount,saveCount,inquiryCount,allowPickupChange,rentalDailyPrice,rentalWeeklyPrice,rentalMonthlyPrice,isPinned,pinnedDays,const DeepCollectionEquality().hash(_images),seller,createdAt,updatedAt]);

@override
String toString() {
  return 'Listing(id: $id, sellerId: $sellerId, title: $title, description: $description, category: $category, price: $price, transactionType: $transactionType, status: $status, viewCount: $viewCount, saveCount: $saveCount, inquiryCount: $inquiryCount, allowPickupChange: $allowPickupChange, rentalDailyPrice: $rentalDailyPrice, rentalWeeklyPrice: $rentalWeeklyPrice, rentalMonthlyPrice: $rentalMonthlyPrice, isPinned: $isPinned, pinnedDays: $pinnedDays, images: $images, seller: $seller, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$ListingCopyWith<$Res> implements $ListingCopyWith<$Res> {
  factory _$ListingCopyWith(_Listing value, $Res Function(_Listing) _then) = __$ListingCopyWithImpl;
@override @useResult
$Res call({
 String id,@JsonKey(name: 'seller_id') String sellerId, String title, String? description, String category, double price,@JsonKey(name: 'transaction_type') String transactionType, String status,@JsonKey(name: 'view_count') int viewCount,@JsonKey(name: 'save_count') int saveCount,@JsonKey(name: 'inquiry_count') int inquiryCount,@JsonKey(name: 'allow_pickup_change') bool allowPickupChange,@JsonKey(name: 'rental_daily_price') double? rentalDailyPrice,@JsonKey(name: 'rental_weekly_price') double? rentalWeeklyPrice,@JsonKey(name: 'rental_monthly_price') double? rentalMonthlyPrice,@JsonKey(name: 'is_pinned') bool isPinned,@JsonKey(name: 'pinned_days') int? pinnedDays, List<ListingImage> images, UserProfile? seller,@JsonKey(name: 'created_at') DateTime createdAt,@JsonKey(name: 'updated_at') DateTime updatedAt
});


@override $UserProfileCopyWith<$Res>? get seller;

}
/// @nodoc
class __$ListingCopyWithImpl<$Res>
    implements _$ListingCopyWith<$Res> {
  __$ListingCopyWithImpl(this._self, this._then);

  final _Listing _self;
  final $Res Function(_Listing) _then;

/// Create a copy of Listing
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? sellerId = null,Object? title = null,Object? description = freezed,Object? category = null,Object? price = null,Object? transactionType = null,Object? status = null,Object? viewCount = null,Object? saveCount = null,Object? inquiryCount = null,Object? allowPickupChange = null,Object? rentalDailyPrice = freezed,Object? rentalWeeklyPrice = freezed,Object? rentalMonthlyPrice = freezed,Object? isPinned = null,Object? pinnedDays = freezed,Object? images = null,Object? seller = freezed,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_Listing(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,sellerId: null == sellerId ? _self.sellerId : sellerId // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String,price: null == price ? _self.price : price // ignore: cast_nullable_to_non_nullable
as double,transactionType: null == transactionType ? _self.transactionType : transactionType // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,viewCount: null == viewCount ? _self.viewCount : viewCount // ignore: cast_nullable_to_non_nullable
as int,saveCount: null == saveCount ? _self.saveCount : saveCount // ignore: cast_nullable_to_non_nullable
as int,inquiryCount: null == inquiryCount ? _self.inquiryCount : inquiryCount // ignore: cast_nullable_to_non_nullable
as int,allowPickupChange: null == allowPickupChange ? _self.allowPickupChange : allowPickupChange // ignore: cast_nullable_to_non_nullable
as bool,rentalDailyPrice: freezed == rentalDailyPrice ? _self.rentalDailyPrice : rentalDailyPrice // ignore: cast_nullable_to_non_nullable
as double?,rentalWeeklyPrice: freezed == rentalWeeklyPrice ? _self.rentalWeeklyPrice : rentalWeeklyPrice // ignore: cast_nullable_to_non_nullable
as double?,rentalMonthlyPrice: freezed == rentalMonthlyPrice ? _self.rentalMonthlyPrice : rentalMonthlyPrice // ignore: cast_nullable_to_non_nullable
as double?,isPinned: null == isPinned ? _self.isPinned : isPinned // ignore: cast_nullable_to_non_nullable
as bool,pinnedDays: freezed == pinnedDays ? _self.pinnedDays : pinnedDays // ignore: cast_nullable_to_non_nullable
as int?,images: null == images ? _self._images : images // ignore: cast_nullable_to_non_nullable
as List<ListingImage>,seller: freezed == seller ? _self.seller : seller // ignore: cast_nullable_to_non_nullable
as UserProfile?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

/// Create a copy of Listing
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$UserProfileCopyWith<$Res>? get seller {
    if (_self.seller == null) {
    return null;
  }

  return $UserProfileCopyWith<$Res>(_self.seller!, (value) {
    return _then(_self.copyWith(seller: value));
  });
}
}

// dart format on

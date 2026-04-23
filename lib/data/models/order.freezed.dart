// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'order.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Order {

 String get id;@JsonKey(name: 'listing_id') String get listingId;@JsonKey(name: 'buyer_id') String get buyerId;@JsonKey(name: 'seller_id') String get sellerId;@JsonKey(name: 'order_type') String get orderType; String get status;@JsonKey(name: 'school') String get school;@JsonKey(name: 'rental_start_date') DateTime? get rentalStartDate;@JsonKey(name: 'rental_end_date') DateTime? get rentalEndDate;// NOTE: Using DateTime? instead of bool so we record WHEN the item
// was returned, not just whether it was. null = not yet returned.
@JsonKey(name: 'return_confirmed_at') DateTime? get returnConfirmedAt;@JsonKey(name: 'transaction_snapshot_url') String? get transactionSnapshotUrl;@JsonKey(name: 'delivery_confirmed_by_buyer') bool get deliveryConfirmedByBuyer;@JsonKey(name: 'delivery_confirmed_by_seller') bool get deliveryConfirmedBySeller;@JsonKey(name: 'delivery_photo_url') String? get deliveryPhotoUrl;@JsonKey(name: 'delivery_note') String? get deliveryNote;@JsonKey(name: 'total_price') double get totalPrice;@JsonKey(name: 'deposit_amount') double get depositAmount;@JsonKey(name: 'created_at') DateTime get createdAt;@JsonKey(name: 'updated_at') DateTime get updatedAt;@JsonKey(name: 'pickup_location_id') String? get pickupLocationId;@JsonKey(name: 'rental_status') String? get rentalStatus;@JsonKey(name: 'deposit_refunded_at') DateTime? get depositRefundedAt;@JsonKey(name: 'return_requested_at') DateTime? get returnRequestedAt;// Nested join data — populated only by specific join queries
 UserProfile? get buyer; UserProfile? get seller; OrderListingPreview? get listing;@JsonKey(name: 'pickup_location') PickupLocation? get pickupLocation;
/// Create a copy of Order
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$OrderCopyWith<Order> get copyWith => _$OrderCopyWithImpl<Order>(this as Order, _$identity);

  /// Serializes this Order to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Order&&(identical(other.id, id) || other.id == id)&&(identical(other.listingId, listingId) || other.listingId == listingId)&&(identical(other.buyerId, buyerId) || other.buyerId == buyerId)&&(identical(other.sellerId, sellerId) || other.sellerId == sellerId)&&(identical(other.orderType, orderType) || other.orderType == orderType)&&(identical(other.status, status) || other.status == status)&&(identical(other.school, school) || other.school == school)&&(identical(other.rentalStartDate, rentalStartDate) || other.rentalStartDate == rentalStartDate)&&(identical(other.rentalEndDate, rentalEndDate) || other.rentalEndDate == rentalEndDate)&&(identical(other.returnConfirmedAt, returnConfirmedAt) || other.returnConfirmedAt == returnConfirmedAt)&&(identical(other.transactionSnapshotUrl, transactionSnapshotUrl) || other.transactionSnapshotUrl == transactionSnapshotUrl)&&(identical(other.deliveryConfirmedByBuyer, deliveryConfirmedByBuyer) || other.deliveryConfirmedByBuyer == deliveryConfirmedByBuyer)&&(identical(other.deliveryConfirmedBySeller, deliveryConfirmedBySeller) || other.deliveryConfirmedBySeller == deliveryConfirmedBySeller)&&(identical(other.deliveryPhotoUrl, deliveryPhotoUrl) || other.deliveryPhotoUrl == deliveryPhotoUrl)&&(identical(other.deliveryNote, deliveryNote) || other.deliveryNote == deliveryNote)&&(identical(other.totalPrice, totalPrice) || other.totalPrice == totalPrice)&&(identical(other.depositAmount, depositAmount) || other.depositAmount == depositAmount)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.pickupLocationId, pickupLocationId) || other.pickupLocationId == pickupLocationId)&&(identical(other.rentalStatus, rentalStatus) || other.rentalStatus == rentalStatus)&&(identical(other.depositRefundedAt, depositRefundedAt) || other.depositRefundedAt == depositRefundedAt)&&(identical(other.returnRequestedAt, returnRequestedAt) || other.returnRequestedAt == returnRequestedAt)&&(identical(other.buyer, buyer) || other.buyer == buyer)&&(identical(other.seller, seller) || other.seller == seller)&&(identical(other.listing, listing) || other.listing == listing)&&(identical(other.pickupLocation, pickupLocation) || other.pickupLocation == pickupLocation));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,listingId,buyerId,sellerId,orderType,status,school,rentalStartDate,rentalEndDate,returnConfirmedAt,transactionSnapshotUrl,deliveryConfirmedByBuyer,deliveryConfirmedBySeller,deliveryPhotoUrl,deliveryNote,totalPrice,depositAmount,createdAt,updatedAt,pickupLocationId,rentalStatus,depositRefundedAt,returnRequestedAt,buyer,seller,listing,pickupLocation]);

@override
String toString() {
  return 'Order(id: $id, listingId: $listingId, buyerId: $buyerId, sellerId: $sellerId, orderType: $orderType, status: $status, school: $school, rentalStartDate: $rentalStartDate, rentalEndDate: $rentalEndDate, returnConfirmedAt: $returnConfirmedAt, transactionSnapshotUrl: $transactionSnapshotUrl, deliveryConfirmedByBuyer: $deliveryConfirmedByBuyer, deliveryConfirmedBySeller: $deliveryConfirmedBySeller, deliveryPhotoUrl: $deliveryPhotoUrl, deliveryNote: $deliveryNote, totalPrice: $totalPrice, depositAmount: $depositAmount, createdAt: $createdAt, updatedAt: $updatedAt, pickupLocationId: $pickupLocationId, rentalStatus: $rentalStatus, depositRefundedAt: $depositRefundedAt, returnRequestedAt: $returnRequestedAt, buyer: $buyer, seller: $seller, listing: $listing, pickupLocation: $pickupLocation)';
}


}

/// @nodoc
abstract mixin class $OrderCopyWith<$Res>  {
  factory $OrderCopyWith(Order value, $Res Function(Order) _then) = _$OrderCopyWithImpl;
@useResult
$Res call({
 String id,@JsonKey(name: 'listing_id') String listingId,@JsonKey(name: 'buyer_id') String buyerId,@JsonKey(name: 'seller_id') String sellerId,@JsonKey(name: 'order_type') String orderType, String status,@JsonKey(name: 'school') String school,@JsonKey(name: 'rental_start_date') DateTime? rentalStartDate,@JsonKey(name: 'rental_end_date') DateTime? rentalEndDate,@JsonKey(name: 'return_confirmed_at') DateTime? returnConfirmedAt,@JsonKey(name: 'transaction_snapshot_url') String? transactionSnapshotUrl,@JsonKey(name: 'delivery_confirmed_by_buyer') bool deliveryConfirmedByBuyer,@JsonKey(name: 'delivery_confirmed_by_seller') bool deliveryConfirmedBySeller,@JsonKey(name: 'delivery_photo_url') String? deliveryPhotoUrl,@JsonKey(name: 'delivery_note') String? deliveryNote,@JsonKey(name: 'total_price') double totalPrice,@JsonKey(name: 'deposit_amount') double depositAmount,@JsonKey(name: 'created_at') DateTime createdAt,@JsonKey(name: 'updated_at') DateTime updatedAt,@JsonKey(name: 'pickup_location_id') String? pickupLocationId,@JsonKey(name: 'rental_status') String? rentalStatus,@JsonKey(name: 'deposit_refunded_at') DateTime? depositRefundedAt,@JsonKey(name: 'return_requested_at') DateTime? returnRequestedAt, UserProfile? buyer, UserProfile? seller, OrderListingPreview? listing,@JsonKey(name: 'pickup_location') PickupLocation? pickupLocation
});


$UserProfileCopyWith<$Res>? get buyer;$UserProfileCopyWith<$Res>? get seller;$OrderListingPreviewCopyWith<$Res>? get listing;$PickupLocationCopyWith<$Res>? get pickupLocation;

}
/// @nodoc
class _$OrderCopyWithImpl<$Res>
    implements $OrderCopyWith<$Res> {
  _$OrderCopyWithImpl(this._self, this._then);

  final Order _self;
  final $Res Function(Order) _then;

/// Create a copy of Order
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? listingId = null,Object? buyerId = null,Object? sellerId = null,Object? orderType = null,Object? status = null,Object? school = null,Object? rentalStartDate = freezed,Object? rentalEndDate = freezed,Object? returnConfirmedAt = freezed,Object? transactionSnapshotUrl = freezed,Object? deliveryConfirmedByBuyer = null,Object? deliveryConfirmedBySeller = null,Object? deliveryPhotoUrl = freezed,Object? deliveryNote = freezed,Object? totalPrice = null,Object? depositAmount = null,Object? createdAt = null,Object? updatedAt = null,Object? pickupLocationId = freezed,Object? rentalStatus = freezed,Object? depositRefundedAt = freezed,Object? returnRequestedAt = freezed,Object? buyer = freezed,Object? seller = freezed,Object? listing = freezed,Object? pickupLocation = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,listingId: null == listingId ? _self.listingId : listingId // ignore: cast_nullable_to_non_nullable
as String,buyerId: null == buyerId ? _self.buyerId : buyerId // ignore: cast_nullable_to_non_nullable
as String,sellerId: null == sellerId ? _self.sellerId : sellerId // ignore: cast_nullable_to_non_nullable
as String,orderType: null == orderType ? _self.orderType : orderType // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,school: null == school ? _self.school : school // ignore: cast_nullable_to_non_nullable
as String,rentalStartDate: freezed == rentalStartDate ? _self.rentalStartDate : rentalStartDate // ignore: cast_nullable_to_non_nullable
as DateTime?,rentalEndDate: freezed == rentalEndDate ? _self.rentalEndDate : rentalEndDate // ignore: cast_nullable_to_non_nullable
as DateTime?,returnConfirmedAt: freezed == returnConfirmedAt ? _self.returnConfirmedAt : returnConfirmedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,transactionSnapshotUrl: freezed == transactionSnapshotUrl ? _self.transactionSnapshotUrl : transactionSnapshotUrl // ignore: cast_nullable_to_non_nullable
as String?,deliveryConfirmedByBuyer: null == deliveryConfirmedByBuyer ? _self.deliveryConfirmedByBuyer : deliveryConfirmedByBuyer // ignore: cast_nullable_to_non_nullable
as bool,deliveryConfirmedBySeller: null == deliveryConfirmedBySeller ? _self.deliveryConfirmedBySeller : deliveryConfirmedBySeller // ignore: cast_nullable_to_non_nullable
as bool,deliveryPhotoUrl: freezed == deliveryPhotoUrl ? _self.deliveryPhotoUrl : deliveryPhotoUrl // ignore: cast_nullable_to_non_nullable
as String?,deliveryNote: freezed == deliveryNote ? _self.deliveryNote : deliveryNote // ignore: cast_nullable_to_non_nullable
as String?,totalPrice: null == totalPrice ? _self.totalPrice : totalPrice // ignore: cast_nullable_to_non_nullable
as double,depositAmount: null == depositAmount ? _self.depositAmount : depositAmount // ignore: cast_nullable_to_non_nullable
as double,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,pickupLocationId: freezed == pickupLocationId ? _self.pickupLocationId : pickupLocationId // ignore: cast_nullable_to_non_nullable
as String?,rentalStatus: freezed == rentalStatus ? _self.rentalStatus : rentalStatus // ignore: cast_nullable_to_non_nullable
as String?,depositRefundedAt: freezed == depositRefundedAt ? _self.depositRefundedAt : depositRefundedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,returnRequestedAt: freezed == returnRequestedAt ? _self.returnRequestedAt : returnRequestedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,buyer: freezed == buyer ? _self.buyer : buyer // ignore: cast_nullable_to_non_nullable
as UserProfile?,seller: freezed == seller ? _self.seller : seller // ignore: cast_nullable_to_non_nullable
as UserProfile?,listing: freezed == listing ? _self.listing : listing // ignore: cast_nullable_to_non_nullable
as OrderListingPreview?,pickupLocation: freezed == pickupLocation ? _self.pickupLocation : pickupLocation // ignore: cast_nullable_to_non_nullable
as PickupLocation?,
  ));
}
/// Create a copy of Order
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$UserProfileCopyWith<$Res>? get buyer {
    if (_self.buyer == null) {
    return null;
  }

  return $UserProfileCopyWith<$Res>(_self.buyer!, (value) {
    return _then(_self.copyWith(buyer: value));
  });
}/// Create a copy of Order
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
}/// Create a copy of Order
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$OrderListingPreviewCopyWith<$Res>? get listing {
    if (_self.listing == null) {
    return null;
  }

  return $OrderListingPreviewCopyWith<$Res>(_self.listing!, (value) {
    return _then(_self.copyWith(listing: value));
  });
}/// Create a copy of Order
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PickupLocationCopyWith<$Res>? get pickupLocation {
    if (_self.pickupLocation == null) {
    return null;
  }

  return $PickupLocationCopyWith<$Res>(_self.pickupLocation!, (value) {
    return _then(_self.copyWith(pickupLocation: value));
  });
}
}


/// Adds pattern-matching-related methods to [Order].
extension OrderPatterns on Order {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Order value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Order() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Order value)  $default,){
final _that = this;
switch (_that) {
case _Order():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Order value)?  $default,){
final _that = this;
switch (_that) {
case _Order() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'listing_id')  String listingId, @JsonKey(name: 'buyer_id')  String buyerId, @JsonKey(name: 'seller_id')  String sellerId, @JsonKey(name: 'order_type')  String orderType,  String status, @JsonKey(name: 'school')  String school, @JsonKey(name: 'rental_start_date')  DateTime? rentalStartDate, @JsonKey(name: 'rental_end_date')  DateTime? rentalEndDate, @JsonKey(name: 'return_confirmed_at')  DateTime? returnConfirmedAt, @JsonKey(name: 'transaction_snapshot_url')  String? transactionSnapshotUrl, @JsonKey(name: 'delivery_confirmed_by_buyer')  bool deliveryConfirmedByBuyer, @JsonKey(name: 'delivery_confirmed_by_seller')  bool deliveryConfirmedBySeller, @JsonKey(name: 'delivery_photo_url')  String? deliveryPhotoUrl, @JsonKey(name: 'delivery_note')  String? deliveryNote, @JsonKey(name: 'total_price')  double totalPrice, @JsonKey(name: 'deposit_amount')  double depositAmount, @JsonKey(name: 'created_at')  DateTime createdAt, @JsonKey(name: 'updated_at')  DateTime updatedAt, @JsonKey(name: 'pickup_location_id')  String? pickupLocationId, @JsonKey(name: 'rental_status')  String? rentalStatus, @JsonKey(name: 'deposit_refunded_at')  DateTime? depositRefundedAt, @JsonKey(name: 'return_requested_at')  DateTime? returnRequestedAt,  UserProfile? buyer,  UserProfile? seller,  OrderListingPreview? listing, @JsonKey(name: 'pickup_location')  PickupLocation? pickupLocation)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Order() when $default != null:
return $default(_that.id,_that.listingId,_that.buyerId,_that.sellerId,_that.orderType,_that.status,_that.school,_that.rentalStartDate,_that.rentalEndDate,_that.returnConfirmedAt,_that.transactionSnapshotUrl,_that.deliveryConfirmedByBuyer,_that.deliveryConfirmedBySeller,_that.deliveryPhotoUrl,_that.deliveryNote,_that.totalPrice,_that.depositAmount,_that.createdAt,_that.updatedAt,_that.pickupLocationId,_that.rentalStatus,_that.depositRefundedAt,_that.returnRequestedAt,_that.buyer,_that.seller,_that.listing,_that.pickupLocation);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'listing_id')  String listingId, @JsonKey(name: 'buyer_id')  String buyerId, @JsonKey(name: 'seller_id')  String sellerId, @JsonKey(name: 'order_type')  String orderType,  String status, @JsonKey(name: 'school')  String school, @JsonKey(name: 'rental_start_date')  DateTime? rentalStartDate, @JsonKey(name: 'rental_end_date')  DateTime? rentalEndDate, @JsonKey(name: 'return_confirmed_at')  DateTime? returnConfirmedAt, @JsonKey(name: 'transaction_snapshot_url')  String? transactionSnapshotUrl, @JsonKey(name: 'delivery_confirmed_by_buyer')  bool deliveryConfirmedByBuyer, @JsonKey(name: 'delivery_confirmed_by_seller')  bool deliveryConfirmedBySeller, @JsonKey(name: 'delivery_photo_url')  String? deliveryPhotoUrl, @JsonKey(name: 'delivery_note')  String? deliveryNote, @JsonKey(name: 'total_price')  double totalPrice, @JsonKey(name: 'deposit_amount')  double depositAmount, @JsonKey(name: 'created_at')  DateTime createdAt, @JsonKey(name: 'updated_at')  DateTime updatedAt, @JsonKey(name: 'pickup_location_id')  String? pickupLocationId, @JsonKey(name: 'rental_status')  String? rentalStatus, @JsonKey(name: 'deposit_refunded_at')  DateTime? depositRefundedAt, @JsonKey(name: 'return_requested_at')  DateTime? returnRequestedAt,  UserProfile? buyer,  UserProfile? seller,  OrderListingPreview? listing, @JsonKey(name: 'pickup_location')  PickupLocation? pickupLocation)  $default,) {final _that = this;
switch (_that) {
case _Order():
return $default(_that.id,_that.listingId,_that.buyerId,_that.sellerId,_that.orderType,_that.status,_that.school,_that.rentalStartDate,_that.rentalEndDate,_that.returnConfirmedAt,_that.transactionSnapshotUrl,_that.deliveryConfirmedByBuyer,_that.deliveryConfirmedBySeller,_that.deliveryPhotoUrl,_that.deliveryNote,_that.totalPrice,_that.depositAmount,_that.createdAt,_that.updatedAt,_that.pickupLocationId,_that.rentalStatus,_that.depositRefundedAt,_that.returnRequestedAt,_that.buyer,_that.seller,_that.listing,_that.pickupLocation);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id, @JsonKey(name: 'listing_id')  String listingId, @JsonKey(name: 'buyer_id')  String buyerId, @JsonKey(name: 'seller_id')  String sellerId, @JsonKey(name: 'order_type')  String orderType,  String status, @JsonKey(name: 'school')  String school, @JsonKey(name: 'rental_start_date')  DateTime? rentalStartDate, @JsonKey(name: 'rental_end_date')  DateTime? rentalEndDate, @JsonKey(name: 'return_confirmed_at')  DateTime? returnConfirmedAt, @JsonKey(name: 'transaction_snapshot_url')  String? transactionSnapshotUrl, @JsonKey(name: 'delivery_confirmed_by_buyer')  bool deliveryConfirmedByBuyer, @JsonKey(name: 'delivery_confirmed_by_seller')  bool deliveryConfirmedBySeller, @JsonKey(name: 'delivery_photo_url')  String? deliveryPhotoUrl, @JsonKey(name: 'delivery_note')  String? deliveryNote, @JsonKey(name: 'total_price')  double totalPrice, @JsonKey(name: 'deposit_amount')  double depositAmount, @JsonKey(name: 'created_at')  DateTime createdAt, @JsonKey(name: 'updated_at')  DateTime updatedAt, @JsonKey(name: 'pickup_location_id')  String? pickupLocationId, @JsonKey(name: 'rental_status')  String? rentalStatus, @JsonKey(name: 'deposit_refunded_at')  DateTime? depositRefundedAt, @JsonKey(name: 'return_requested_at')  DateTime? returnRequestedAt,  UserProfile? buyer,  UserProfile? seller,  OrderListingPreview? listing, @JsonKey(name: 'pickup_location')  PickupLocation? pickupLocation)?  $default,) {final _that = this;
switch (_that) {
case _Order() when $default != null:
return $default(_that.id,_that.listingId,_that.buyerId,_that.sellerId,_that.orderType,_that.status,_that.school,_that.rentalStartDate,_that.rentalEndDate,_that.returnConfirmedAt,_that.transactionSnapshotUrl,_that.deliveryConfirmedByBuyer,_that.deliveryConfirmedBySeller,_that.deliveryPhotoUrl,_that.deliveryNote,_that.totalPrice,_that.depositAmount,_that.createdAt,_that.updatedAt,_that.pickupLocationId,_that.rentalStatus,_that.depositRefundedAt,_that.returnRequestedAt,_that.buyer,_that.seller,_that.listing,_that.pickupLocation);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Order implements Order {
  const _Order({required this.id, @JsonKey(name: 'listing_id') required this.listingId, @JsonKey(name: 'buyer_id') required this.buyerId, @JsonKey(name: 'seller_id') required this.sellerId, @JsonKey(name: 'order_type') required this.orderType, this.status = 'pending', @JsonKey(name: 'school') this.school = 'Smith College', @JsonKey(name: 'rental_start_date') this.rentalStartDate, @JsonKey(name: 'rental_end_date') this.rentalEndDate, @JsonKey(name: 'return_confirmed_at') this.returnConfirmedAt, @JsonKey(name: 'transaction_snapshot_url') this.transactionSnapshotUrl, @JsonKey(name: 'delivery_confirmed_by_buyer') this.deliveryConfirmedByBuyer = false, @JsonKey(name: 'delivery_confirmed_by_seller') this.deliveryConfirmedBySeller = false, @JsonKey(name: 'delivery_photo_url') this.deliveryPhotoUrl, @JsonKey(name: 'delivery_note') this.deliveryNote, @JsonKey(name: 'total_price') required this.totalPrice, @JsonKey(name: 'deposit_amount') this.depositAmount = 0.0, @JsonKey(name: 'created_at') required this.createdAt, @JsonKey(name: 'updated_at') required this.updatedAt, @JsonKey(name: 'pickup_location_id') this.pickupLocationId, @JsonKey(name: 'rental_status') this.rentalStatus, @JsonKey(name: 'deposit_refunded_at') this.depositRefundedAt, @JsonKey(name: 'return_requested_at') this.returnRequestedAt, this.buyer, this.seller, this.listing, @JsonKey(name: 'pickup_location') this.pickupLocation});
  factory _Order.fromJson(Map<String, dynamic> json) => _$OrderFromJson(json);

@override final  String id;
@override@JsonKey(name: 'listing_id') final  String listingId;
@override@JsonKey(name: 'buyer_id') final  String buyerId;
@override@JsonKey(name: 'seller_id') final  String sellerId;
@override@JsonKey(name: 'order_type') final  String orderType;
@override@JsonKey() final  String status;
@override@JsonKey(name: 'school') final  String school;
@override@JsonKey(name: 'rental_start_date') final  DateTime? rentalStartDate;
@override@JsonKey(name: 'rental_end_date') final  DateTime? rentalEndDate;
// NOTE: Using DateTime? instead of bool so we record WHEN the item
// was returned, not just whether it was. null = not yet returned.
@override@JsonKey(name: 'return_confirmed_at') final  DateTime? returnConfirmedAt;
@override@JsonKey(name: 'transaction_snapshot_url') final  String? transactionSnapshotUrl;
@override@JsonKey(name: 'delivery_confirmed_by_buyer') final  bool deliveryConfirmedByBuyer;
@override@JsonKey(name: 'delivery_confirmed_by_seller') final  bool deliveryConfirmedBySeller;
@override@JsonKey(name: 'delivery_photo_url') final  String? deliveryPhotoUrl;
@override@JsonKey(name: 'delivery_note') final  String? deliveryNote;
@override@JsonKey(name: 'total_price') final  double totalPrice;
@override@JsonKey(name: 'deposit_amount') final  double depositAmount;
@override@JsonKey(name: 'created_at') final  DateTime createdAt;
@override@JsonKey(name: 'updated_at') final  DateTime updatedAt;
@override@JsonKey(name: 'pickup_location_id') final  String? pickupLocationId;
@override@JsonKey(name: 'rental_status') final  String? rentalStatus;
@override@JsonKey(name: 'deposit_refunded_at') final  DateTime? depositRefundedAt;
@override@JsonKey(name: 'return_requested_at') final  DateTime? returnRequestedAt;
// Nested join data — populated only by specific join queries
@override final  UserProfile? buyer;
@override final  UserProfile? seller;
@override final  OrderListingPreview? listing;
@override@JsonKey(name: 'pickup_location') final  PickupLocation? pickupLocation;

/// Create a copy of Order
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$OrderCopyWith<_Order> get copyWith => __$OrderCopyWithImpl<_Order>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$OrderToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Order&&(identical(other.id, id) || other.id == id)&&(identical(other.listingId, listingId) || other.listingId == listingId)&&(identical(other.buyerId, buyerId) || other.buyerId == buyerId)&&(identical(other.sellerId, sellerId) || other.sellerId == sellerId)&&(identical(other.orderType, orderType) || other.orderType == orderType)&&(identical(other.status, status) || other.status == status)&&(identical(other.school, school) || other.school == school)&&(identical(other.rentalStartDate, rentalStartDate) || other.rentalStartDate == rentalStartDate)&&(identical(other.rentalEndDate, rentalEndDate) || other.rentalEndDate == rentalEndDate)&&(identical(other.returnConfirmedAt, returnConfirmedAt) || other.returnConfirmedAt == returnConfirmedAt)&&(identical(other.transactionSnapshotUrl, transactionSnapshotUrl) || other.transactionSnapshotUrl == transactionSnapshotUrl)&&(identical(other.deliveryConfirmedByBuyer, deliveryConfirmedByBuyer) || other.deliveryConfirmedByBuyer == deliveryConfirmedByBuyer)&&(identical(other.deliveryConfirmedBySeller, deliveryConfirmedBySeller) || other.deliveryConfirmedBySeller == deliveryConfirmedBySeller)&&(identical(other.deliveryPhotoUrl, deliveryPhotoUrl) || other.deliveryPhotoUrl == deliveryPhotoUrl)&&(identical(other.deliveryNote, deliveryNote) || other.deliveryNote == deliveryNote)&&(identical(other.totalPrice, totalPrice) || other.totalPrice == totalPrice)&&(identical(other.depositAmount, depositAmount) || other.depositAmount == depositAmount)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.pickupLocationId, pickupLocationId) || other.pickupLocationId == pickupLocationId)&&(identical(other.rentalStatus, rentalStatus) || other.rentalStatus == rentalStatus)&&(identical(other.depositRefundedAt, depositRefundedAt) || other.depositRefundedAt == depositRefundedAt)&&(identical(other.returnRequestedAt, returnRequestedAt) || other.returnRequestedAt == returnRequestedAt)&&(identical(other.buyer, buyer) || other.buyer == buyer)&&(identical(other.seller, seller) || other.seller == seller)&&(identical(other.listing, listing) || other.listing == listing)&&(identical(other.pickupLocation, pickupLocation) || other.pickupLocation == pickupLocation));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,listingId,buyerId,sellerId,orderType,status,school,rentalStartDate,rentalEndDate,returnConfirmedAt,transactionSnapshotUrl,deliveryConfirmedByBuyer,deliveryConfirmedBySeller,deliveryPhotoUrl,deliveryNote,totalPrice,depositAmount,createdAt,updatedAt,pickupLocationId,rentalStatus,depositRefundedAt,returnRequestedAt,buyer,seller,listing,pickupLocation]);

@override
String toString() {
  return 'Order(id: $id, listingId: $listingId, buyerId: $buyerId, sellerId: $sellerId, orderType: $orderType, status: $status, school: $school, rentalStartDate: $rentalStartDate, rentalEndDate: $rentalEndDate, returnConfirmedAt: $returnConfirmedAt, transactionSnapshotUrl: $transactionSnapshotUrl, deliveryConfirmedByBuyer: $deliveryConfirmedByBuyer, deliveryConfirmedBySeller: $deliveryConfirmedBySeller, deliveryPhotoUrl: $deliveryPhotoUrl, deliveryNote: $deliveryNote, totalPrice: $totalPrice, depositAmount: $depositAmount, createdAt: $createdAt, updatedAt: $updatedAt, pickupLocationId: $pickupLocationId, rentalStatus: $rentalStatus, depositRefundedAt: $depositRefundedAt, returnRequestedAt: $returnRequestedAt, buyer: $buyer, seller: $seller, listing: $listing, pickupLocation: $pickupLocation)';
}


}

/// @nodoc
abstract mixin class _$OrderCopyWith<$Res> implements $OrderCopyWith<$Res> {
  factory _$OrderCopyWith(_Order value, $Res Function(_Order) _then) = __$OrderCopyWithImpl;
@override @useResult
$Res call({
 String id,@JsonKey(name: 'listing_id') String listingId,@JsonKey(name: 'buyer_id') String buyerId,@JsonKey(name: 'seller_id') String sellerId,@JsonKey(name: 'order_type') String orderType, String status,@JsonKey(name: 'school') String school,@JsonKey(name: 'rental_start_date') DateTime? rentalStartDate,@JsonKey(name: 'rental_end_date') DateTime? rentalEndDate,@JsonKey(name: 'return_confirmed_at') DateTime? returnConfirmedAt,@JsonKey(name: 'transaction_snapshot_url') String? transactionSnapshotUrl,@JsonKey(name: 'delivery_confirmed_by_buyer') bool deliveryConfirmedByBuyer,@JsonKey(name: 'delivery_confirmed_by_seller') bool deliveryConfirmedBySeller,@JsonKey(name: 'delivery_photo_url') String? deliveryPhotoUrl,@JsonKey(name: 'delivery_note') String? deliveryNote,@JsonKey(name: 'total_price') double totalPrice,@JsonKey(name: 'deposit_amount') double depositAmount,@JsonKey(name: 'created_at') DateTime createdAt,@JsonKey(name: 'updated_at') DateTime updatedAt,@JsonKey(name: 'pickup_location_id') String? pickupLocationId,@JsonKey(name: 'rental_status') String? rentalStatus,@JsonKey(name: 'deposit_refunded_at') DateTime? depositRefundedAt,@JsonKey(name: 'return_requested_at') DateTime? returnRequestedAt, UserProfile? buyer, UserProfile? seller, OrderListingPreview? listing,@JsonKey(name: 'pickup_location') PickupLocation? pickupLocation
});


@override $UserProfileCopyWith<$Res>? get buyer;@override $UserProfileCopyWith<$Res>? get seller;@override $OrderListingPreviewCopyWith<$Res>? get listing;@override $PickupLocationCopyWith<$Res>? get pickupLocation;

}
/// @nodoc
class __$OrderCopyWithImpl<$Res>
    implements _$OrderCopyWith<$Res> {
  __$OrderCopyWithImpl(this._self, this._then);

  final _Order _self;
  final $Res Function(_Order) _then;

/// Create a copy of Order
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? listingId = null,Object? buyerId = null,Object? sellerId = null,Object? orderType = null,Object? status = null,Object? school = null,Object? rentalStartDate = freezed,Object? rentalEndDate = freezed,Object? returnConfirmedAt = freezed,Object? transactionSnapshotUrl = freezed,Object? deliveryConfirmedByBuyer = null,Object? deliveryConfirmedBySeller = null,Object? deliveryPhotoUrl = freezed,Object? deliveryNote = freezed,Object? totalPrice = null,Object? depositAmount = null,Object? createdAt = null,Object? updatedAt = null,Object? pickupLocationId = freezed,Object? rentalStatus = freezed,Object? depositRefundedAt = freezed,Object? returnRequestedAt = freezed,Object? buyer = freezed,Object? seller = freezed,Object? listing = freezed,Object? pickupLocation = freezed,}) {
  return _then(_Order(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,listingId: null == listingId ? _self.listingId : listingId // ignore: cast_nullable_to_non_nullable
as String,buyerId: null == buyerId ? _self.buyerId : buyerId // ignore: cast_nullable_to_non_nullable
as String,sellerId: null == sellerId ? _self.sellerId : sellerId // ignore: cast_nullable_to_non_nullable
as String,orderType: null == orderType ? _self.orderType : orderType // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,school: null == school ? _self.school : school // ignore: cast_nullable_to_non_nullable
as String,rentalStartDate: freezed == rentalStartDate ? _self.rentalStartDate : rentalStartDate // ignore: cast_nullable_to_non_nullable
as DateTime?,rentalEndDate: freezed == rentalEndDate ? _self.rentalEndDate : rentalEndDate // ignore: cast_nullable_to_non_nullable
as DateTime?,returnConfirmedAt: freezed == returnConfirmedAt ? _self.returnConfirmedAt : returnConfirmedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,transactionSnapshotUrl: freezed == transactionSnapshotUrl ? _self.transactionSnapshotUrl : transactionSnapshotUrl // ignore: cast_nullable_to_non_nullable
as String?,deliveryConfirmedByBuyer: null == deliveryConfirmedByBuyer ? _self.deliveryConfirmedByBuyer : deliveryConfirmedByBuyer // ignore: cast_nullable_to_non_nullable
as bool,deliveryConfirmedBySeller: null == deliveryConfirmedBySeller ? _self.deliveryConfirmedBySeller : deliveryConfirmedBySeller // ignore: cast_nullable_to_non_nullable
as bool,deliveryPhotoUrl: freezed == deliveryPhotoUrl ? _self.deliveryPhotoUrl : deliveryPhotoUrl // ignore: cast_nullable_to_non_nullable
as String?,deliveryNote: freezed == deliveryNote ? _self.deliveryNote : deliveryNote // ignore: cast_nullable_to_non_nullable
as String?,totalPrice: null == totalPrice ? _self.totalPrice : totalPrice // ignore: cast_nullable_to_non_nullable
as double,depositAmount: null == depositAmount ? _self.depositAmount : depositAmount // ignore: cast_nullable_to_non_nullable
as double,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,pickupLocationId: freezed == pickupLocationId ? _self.pickupLocationId : pickupLocationId // ignore: cast_nullable_to_non_nullable
as String?,rentalStatus: freezed == rentalStatus ? _self.rentalStatus : rentalStatus // ignore: cast_nullable_to_non_nullable
as String?,depositRefundedAt: freezed == depositRefundedAt ? _self.depositRefundedAt : depositRefundedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,returnRequestedAt: freezed == returnRequestedAt ? _self.returnRequestedAt : returnRequestedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,buyer: freezed == buyer ? _self.buyer : buyer // ignore: cast_nullable_to_non_nullable
as UserProfile?,seller: freezed == seller ? _self.seller : seller // ignore: cast_nullable_to_non_nullable
as UserProfile?,listing: freezed == listing ? _self.listing : listing // ignore: cast_nullable_to_non_nullable
as OrderListingPreview?,pickupLocation: freezed == pickupLocation ? _self.pickupLocation : pickupLocation // ignore: cast_nullable_to_non_nullable
as PickupLocation?,
  ));
}

/// Create a copy of Order
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$UserProfileCopyWith<$Res>? get buyer {
    if (_self.buyer == null) {
    return null;
  }

  return $UserProfileCopyWith<$Res>(_self.buyer!, (value) {
    return _then(_self.copyWith(buyer: value));
  });
}/// Create a copy of Order
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
}/// Create a copy of Order
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$OrderListingPreviewCopyWith<$Res>? get listing {
    if (_self.listing == null) {
    return null;
  }

  return $OrderListingPreviewCopyWith<$Res>(_self.listing!, (value) {
    return _then(_self.copyWith(listing: value));
  });
}/// Create a copy of Order
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PickupLocationCopyWith<$Res>? get pickupLocation {
    if (_self.pickupLocation == null) {
    return null;
  }

  return $PickupLocationCopyWith<$Res>(_self.pickupLocation!, (value) {
    return _then(_self.copyWith(pickupLocation: value));
  });
}
}

// dart format on

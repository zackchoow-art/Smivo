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

 String get id; String get listingId; String get buyerId; String get sellerId; String get orderType; String get status; DateTime? get rentalStartDate; DateTime? get rentalEndDate;// NOTE: Using DateTime? instead of bool so we record WHEN the item
// was returned, not just whether it was. null = not yet returned.
 DateTime? get returnConfirmedAt; String? get transactionSnapshotUrl; bool get deliveryConfirmedByBuyer; bool get deliveryConfirmedBySeller; String? get deliveryPhotoUrl; String? get deliveryNote; double get totalPrice; DateTime get createdAt; DateTime get updatedAt;
/// Create a copy of Order
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$OrderCopyWith<Order> get copyWith => _$OrderCopyWithImpl<Order>(this as Order, _$identity);

  /// Serializes this Order to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Order&&(identical(other.id, id) || other.id == id)&&(identical(other.listingId, listingId) || other.listingId == listingId)&&(identical(other.buyerId, buyerId) || other.buyerId == buyerId)&&(identical(other.sellerId, sellerId) || other.sellerId == sellerId)&&(identical(other.orderType, orderType) || other.orderType == orderType)&&(identical(other.status, status) || other.status == status)&&(identical(other.rentalStartDate, rentalStartDate) || other.rentalStartDate == rentalStartDate)&&(identical(other.rentalEndDate, rentalEndDate) || other.rentalEndDate == rentalEndDate)&&(identical(other.returnConfirmedAt, returnConfirmedAt) || other.returnConfirmedAt == returnConfirmedAt)&&(identical(other.transactionSnapshotUrl, transactionSnapshotUrl) || other.transactionSnapshotUrl == transactionSnapshotUrl)&&(identical(other.deliveryConfirmedByBuyer, deliveryConfirmedByBuyer) || other.deliveryConfirmedByBuyer == deliveryConfirmedByBuyer)&&(identical(other.deliveryConfirmedBySeller, deliveryConfirmedBySeller) || other.deliveryConfirmedBySeller == deliveryConfirmedBySeller)&&(identical(other.deliveryPhotoUrl, deliveryPhotoUrl) || other.deliveryPhotoUrl == deliveryPhotoUrl)&&(identical(other.deliveryNote, deliveryNote) || other.deliveryNote == deliveryNote)&&(identical(other.totalPrice, totalPrice) || other.totalPrice == totalPrice)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,listingId,buyerId,sellerId,orderType,status,rentalStartDate,rentalEndDate,returnConfirmedAt,transactionSnapshotUrl,deliveryConfirmedByBuyer,deliveryConfirmedBySeller,deliveryPhotoUrl,deliveryNote,totalPrice,createdAt,updatedAt);

@override
String toString() {
  return 'Order(id: $id, listingId: $listingId, buyerId: $buyerId, sellerId: $sellerId, orderType: $orderType, status: $status, rentalStartDate: $rentalStartDate, rentalEndDate: $rentalEndDate, returnConfirmedAt: $returnConfirmedAt, transactionSnapshotUrl: $transactionSnapshotUrl, deliveryConfirmedByBuyer: $deliveryConfirmedByBuyer, deliveryConfirmedBySeller: $deliveryConfirmedBySeller, deliveryPhotoUrl: $deliveryPhotoUrl, deliveryNote: $deliveryNote, totalPrice: $totalPrice, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $OrderCopyWith<$Res>  {
  factory $OrderCopyWith(Order value, $Res Function(Order) _then) = _$OrderCopyWithImpl;
@useResult
$Res call({
 String id, String listingId, String buyerId, String sellerId, String orderType, String status, DateTime? rentalStartDate, DateTime? rentalEndDate, DateTime? returnConfirmedAt, String? transactionSnapshotUrl, bool deliveryConfirmedByBuyer, bool deliveryConfirmedBySeller, String? deliveryPhotoUrl, String? deliveryNote, double totalPrice, DateTime createdAt, DateTime updatedAt
});




}
/// @nodoc
class _$OrderCopyWithImpl<$Res>
    implements $OrderCopyWith<$Res> {
  _$OrderCopyWithImpl(this._self, this._then);

  final Order _self;
  final $Res Function(Order) _then;

/// Create a copy of Order
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? listingId = null,Object? buyerId = null,Object? sellerId = null,Object? orderType = null,Object? status = null,Object? rentalStartDate = freezed,Object? rentalEndDate = freezed,Object? returnConfirmedAt = freezed,Object? transactionSnapshotUrl = freezed,Object? deliveryConfirmedByBuyer = null,Object? deliveryConfirmedBySeller = null,Object? deliveryPhotoUrl = freezed,Object? deliveryNote = freezed,Object? totalPrice = null,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,listingId: null == listingId ? _self.listingId : listingId // ignore: cast_nullable_to_non_nullable
as String,buyerId: null == buyerId ? _self.buyerId : buyerId // ignore: cast_nullable_to_non_nullable
as String,sellerId: null == sellerId ? _self.sellerId : sellerId // ignore: cast_nullable_to_non_nullable
as String,orderType: null == orderType ? _self.orderType : orderType // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,rentalStartDate: freezed == rentalStartDate ? _self.rentalStartDate : rentalStartDate // ignore: cast_nullable_to_non_nullable
as DateTime?,rentalEndDate: freezed == rentalEndDate ? _self.rentalEndDate : rentalEndDate // ignore: cast_nullable_to_non_nullable
as DateTime?,returnConfirmedAt: freezed == returnConfirmedAt ? _self.returnConfirmedAt : returnConfirmedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,transactionSnapshotUrl: freezed == transactionSnapshotUrl ? _self.transactionSnapshotUrl : transactionSnapshotUrl // ignore: cast_nullable_to_non_nullable
as String?,deliveryConfirmedByBuyer: null == deliveryConfirmedByBuyer ? _self.deliveryConfirmedByBuyer : deliveryConfirmedByBuyer // ignore: cast_nullable_to_non_nullable
as bool,deliveryConfirmedBySeller: null == deliveryConfirmedBySeller ? _self.deliveryConfirmedBySeller : deliveryConfirmedBySeller // ignore: cast_nullable_to_non_nullable
as bool,deliveryPhotoUrl: freezed == deliveryPhotoUrl ? _self.deliveryPhotoUrl : deliveryPhotoUrl // ignore: cast_nullable_to_non_nullable
as String?,deliveryNote: freezed == deliveryNote ? _self.deliveryNote : deliveryNote // ignore: cast_nullable_to_non_nullable
as String?,totalPrice: null == totalPrice ? _self.totalPrice : totalPrice // ignore: cast_nullable_to_non_nullable
as double,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String listingId,  String buyerId,  String sellerId,  String orderType,  String status,  DateTime? rentalStartDate,  DateTime? rentalEndDate,  DateTime? returnConfirmedAt,  String? transactionSnapshotUrl,  bool deliveryConfirmedByBuyer,  bool deliveryConfirmedBySeller,  String? deliveryPhotoUrl,  String? deliveryNote,  double totalPrice,  DateTime createdAt,  DateTime updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Order() when $default != null:
return $default(_that.id,_that.listingId,_that.buyerId,_that.sellerId,_that.orderType,_that.status,_that.rentalStartDate,_that.rentalEndDate,_that.returnConfirmedAt,_that.transactionSnapshotUrl,_that.deliveryConfirmedByBuyer,_that.deliveryConfirmedBySeller,_that.deliveryPhotoUrl,_that.deliveryNote,_that.totalPrice,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String listingId,  String buyerId,  String sellerId,  String orderType,  String status,  DateTime? rentalStartDate,  DateTime? rentalEndDate,  DateTime? returnConfirmedAt,  String? transactionSnapshotUrl,  bool deliveryConfirmedByBuyer,  bool deliveryConfirmedBySeller,  String? deliveryPhotoUrl,  String? deliveryNote,  double totalPrice,  DateTime createdAt,  DateTime updatedAt)  $default,) {final _that = this;
switch (_that) {
case _Order():
return $default(_that.id,_that.listingId,_that.buyerId,_that.sellerId,_that.orderType,_that.status,_that.rentalStartDate,_that.rentalEndDate,_that.returnConfirmedAt,_that.transactionSnapshotUrl,_that.deliveryConfirmedByBuyer,_that.deliveryConfirmedBySeller,_that.deliveryPhotoUrl,_that.deliveryNote,_that.totalPrice,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String listingId,  String buyerId,  String sellerId,  String orderType,  String status,  DateTime? rentalStartDate,  DateTime? rentalEndDate,  DateTime? returnConfirmedAt,  String? transactionSnapshotUrl,  bool deliveryConfirmedByBuyer,  bool deliveryConfirmedBySeller,  String? deliveryPhotoUrl,  String? deliveryNote,  double totalPrice,  DateTime createdAt,  DateTime updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _Order() when $default != null:
return $default(_that.id,_that.listingId,_that.buyerId,_that.sellerId,_that.orderType,_that.status,_that.rentalStartDate,_that.rentalEndDate,_that.returnConfirmedAt,_that.transactionSnapshotUrl,_that.deliveryConfirmedByBuyer,_that.deliveryConfirmedBySeller,_that.deliveryPhotoUrl,_that.deliveryNote,_that.totalPrice,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Order implements Order {
  const _Order({required this.id, required this.listingId, required this.buyerId, required this.sellerId, required this.orderType, this.status = 'pending', this.rentalStartDate, this.rentalEndDate, this.returnConfirmedAt, this.transactionSnapshotUrl, this.deliveryConfirmedByBuyer = false, this.deliveryConfirmedBySeller = false, this.deliveryPhotoUrl, this.deliveryNote, required this.totalPrice, required this.createdAt, required this.updatedAt});
  factory _Order.fromJson(Map<String, dynamic> json) => _$OrderFromJson(json);

@override final  String id;
@override final  String listingId;
@override final  String buyerId;
@override final  String sellerId;
@override final  String orderType;
@override@JsonKey() final  String status;
@override final  DateTime? rentalStartDate;
@override final  DateTime? rentalEndDate;
// NOTE: Using DateTime? instead of bool so we record WHEN the item
// was returned, not just whether it was. null = not yet returned.
@override final  DateTime? returnConfirmedAt;
@override final  String? transactionSnapshotUrl;
@override@JsonKey() final  bool deliveryConfirmedByBuyer;
@override@JsonKey() final  bool deliveryConfirmedBySeller;
@override final  String? deliveryPhotoUrl;
@override final  String? deliveryNote;
@override final  double totalPrice;
@override final  DateTime createdAt;
@override final  DateTime updatedAt;

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
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Order&&(identical(other.id, id) || other.id == id)&&(identical(other.listingId, listingId) || other.listingId == listingId)&&(identical(other.buyerId, buyerId) || other.buyerId == buyerId)&&(identical(other.sellerId, sellerId) || other.sellerId == sellerId)&&(identical(other.orderType, orderType) || other.orderType == orderType)&&(identical(other.status, status) || other.status == status)&&(identical(other.rentalStartDate, rentalStartDate) || other.rentalStartDate == rentalStartDate)&&(identical(other.rentalEndDate, rentalEndDate) || other.rentalEndDate == rentalEndDate)&&(identical(other.returnConfirmedAt, returnConfirmedAt) || other.returnConfirmedAt == returnConfirmedAt)&&(identical(other.transactionSnapshotUrl, transactionSnapshotUrl) || other.transactionSnapshotUrl == transactionSnapshotUrl)&&(identical(other.deliveryConfirmedByBuyer, deliveryConfirmedByBuyer) || other.deliveryConfirmedByBuyer == deliveryConfirmedByBuyer)&&(identical(other.deliveryConfirmedBySeller, deliveryConfirmedBySeller) || other.deliveryConfirmedBySeller == deliveryConfirmedBySeller)&&(identical(other.deliveryPhotoUrl, deliveryPhotoUrl) || other.deliveryPhotoUrl == deliveryPhotoUrl)&&(identical(other.deliveryNote, deliveryNote) || other.deliveryNote == deliveryNote)&&(identical(other.totalPrice, totalPrice) || other.totalPrice == totalPrice)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,listingId,buyerId,sellerId,orderType,status,rentalStartDate,rentalEndDate,returnConfirmedAt,transactionSnapshotUrl,deliveryConfirmedByBuyer,deliveryConfirmedBySeller,deliveryPhotoUrl,deliveryNote,totalPrice,createdAt,updatedAt);

@override
String toString() {
  return 'Order(id: $id, listingId: $listingId, buyerId: $buyerId, sellerId: $sellerId, orderType: $orderType, status: $status, rentalStartDate: $rentalStartDate, rentalEndDate: $rentalEndDate, returnConfirmedAt: $returnConfirmedAt, transactionSnapshotUrl: $transactionSnapshotUrl, deliveryConfirmedByBuyer: $deliveryConfirmedByBuyer, deliveryConfirmedBySeller: $deliveryConfirmedBySeller, deliveryPhotoUrl: $deliveryPhotoUrl, deliveryNote: $deliveryNote, totalPrice: $totalPrice, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$OrderCopyWith<$Res> implements $OrderCopyWith<$Res> {
  factory _$OrderCopyWith(_Order value, $Res Function(_Order) _then) = __$OrderCopyWithImpl;
@override @useResult
$Res call({
 String id, String listingId, String buyerId, String sellerId, String orderType, String status, DateTime? rentalStartDate, DateTime? rentalEndDate, DateTime? returnConfirmedAt, String? transactionSnapshotUrl, bool deliveryConfirmedByBuyer, bool deliveryConfirmedBySeller, String? deliveryPhotoUrl, String? deliveryNote, double totalPrice, DateTime createdAt, DateTime updatedAt
});




}
/// @nodoc
class __$OrderCopyWithImpl<$Res>
    implements _$OrderCopyWith<$Res> {
  __$OrderCopyWithImpl(this._self, this._then);

  final _Order _self;
  final $Res Function(_Order) _then;

/// Create a copy of Order
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? listingId = null,Object? buyerId = null,Object? sellerId = null,Object? orderType = null,Object? status = null,Object? rentalStartDate = freezed,Object? rentalEndDate = freezed,Object? returnConfirmedAt = freezed,Object? transactionSnapshotUrl = freezed,Object? deliveryConfirmedByBuyer = null,Object? deliveryConfirmedBySeller = null,Object? deliveryPhotoUrl = freezed,Object? deliveryNote = freezed,Object? totalPrice = null,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_Order(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,listingId: null == listingId ? _self.listingId : listingId // ignore: cast_nullable_to_non_nullable
as String,buyerId: null == buyerId ? _self.buyerId : buyerId // ignore: cast_nullable_to_non_nullable
as String,sellerId: null == sellerId ? _self.sellerId : sellerId // ignore: cast_nullable_to_non_nullable
as String,orderType: null == orderType ? _self.orderType : orderType // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,rentalStartDate: freezed == rentalStartDate ? _self.rentalStartDate : rentalStartDate // ignore: cast_nullable_to_non_nullable
as DateTime?,rentalEndDate: freezed == rentalEndDate ? _self.rentalEndDate : rentalEndDate // ignore: cast_nullable_to_non_nullable
as DateTime?,returnConfirmedAt: freezed == returnConfirmedAt ? _self.returnConfirmedAt : returnConfirmedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,transactionSnapshotUrl: freezed == transactionSnapshotUrl ? _self.transactionSnapshotUrl : transactionSnapshotUrl // ignore: cast_nullable_to_non_nullable
as String?,deliveryConfirmedByBuyer: null == deliveryConfirmedByBuyer ? _self.deliveryConfirmedByBuyer : deliveryConfirmedByBuyer // ignore: cast_nullable_to_non_nullable
as bool,deliveryConfirmedBySeller: null == deliveryConfirmedBySeller ? _self.deliveryConfirmedBySeller : deliveryConfirmedBySeller // ignore: cast_nullable_to_non_nullable
as bool,deliveryPhotoUrl: freezed == deliveryPhotoUrl ? _self.deliveryPhotoUrl : deliveryPhotoUrl // ignore: cast_nullable_to_non_nullable
as String?,deliveryNote: freezed == deliveryNote ? _self.deliveryNote : deliveryNote // ignore: cast_nullable_to_non_nullable
as String?,totalPrice: null == totalPrice ? _self.totalPrice : totalPrice // ignore: cast_nullable_to_non_nullable
as double,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on

// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'chat_room.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ChatRoom {

 String get id;@JsonKey(name: 'listing_id') String get listingId;@JsonKey(name: 'buyer_id') String get buyerId;@JsonKey(name: 'seller_id') String get sellerId;@JsonKey(name: 'unread_count_buyer') int get unreadCountBuyer;@JsonKey(name: 'unread_count_seller') int get unreadCountSeller;@JsonKey(name: 'last_message_at') DateTime? get lastMessageAt;@JsonKey(name: 'created_at') DateTime get createdAt;@JsonKey(name: 'updated_at') DateTime get updatedAt;// Per-room feature flags — added via migration 00034
@JsonKey(name: 'is_pinned') bool get isPinned;@JsonKey(name: 'is_archived') bool get isArchived;@JsonKey(name: 'is_unread_override') bool get isUnreadOverride;// Nested join data — populated only by fetchChatRooms query
 UserProfile? get buyer; UserProfile? get seller; ChatListingPreview? get listing;@JsonKey(name: 'last_message') List<Message> get lastMessage;
/// Create a copy of ChatRoom
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ChatRoomCopyWith<ChatRoom> get copyWith => _$ChatRoomCopyWithImpl<ChatRoom>(this as ChatRoom, _$identity);

  /// Serializes this ChatRoom to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ChatRoom&&(identical(other.id, id) || other.id == id)&&(identical(other.listingId, listingId) || other.listingId == listingId)&&(identical(other.buyerId, buyerId) || other.buyerId == buyerId)&&(identical(other.sellerId, sellerId) || other.sellerId == sellerId)&&(identical(other.unreadCountBuyer, unreadCountBuyer) || other.unreadCountBuyer == unreadCountBuyer)&&(identical(other.unreadCountSeller, unreadCountSeller) || other.unreadCountSeller == unreadCountSeller)&&(identical(other.lastMessageAt, lastMessageAt) || other.lastMessageAt == lastMessageAt)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.isPinned, isPinned) || other.isPinned == isPinned)&&(identical(other.isArchived, isArchived) || other.isArchived == isArchived)&&(identical(other.isUnreadOverride, isUnreadOverride) || other.isUnreadOverride == isUnreadOverride)&&(identical(other.buyer, buyer) || other.buyer == buyer)&&(identical(other.seller, seller) || other.seller == seller)&&(identical(other.listing, listing) || other.listing == listing)&&const DeepCollectionEquality().equals(other.lastMessage, lastMessage));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,listingId,buyerId,sellerId,unreadCountBuyer,unreadCountSeller,lastMessageAt,createdAt,updatedAt,isPinned,isArchived,isUnreadOverride,buyer,seller,listing,const DeepCollectionEquality().hash(lastMessage));

@override
String toString() {
  return 'ChatRoom(id: $id, listingId: $listingId, buyerId: $buyerId, sellerId: $sellerId, unreadCountBuyer: $unreadCountBuyer, unreadCountSeller: $unreadCountSeller, lastMessageAt: $lastMessageAt, createdAt: $createdAt, updatedAt: $updatedAt, isPinned: $isPinned, isArchived: $isArchived, isUnreadOverride: $isUnreadOverride, buyer: $buyer, seller: $seller, listing: $listing, lastMessage: $lastMessage)';
}


}

/// @nodoc
abstract mixin class $ChatRoomCopyWith<$Res>  {
  factory $ChatRoomCopyWith(ChatRoom value, $Res Function(ChatRoom) _then) = _$ChatRoomCopyWithImpl;
@useResult
$Res call({
 String id,@JsonKey(name: 'listing_id') String listingId,@JsonKey(name: 'buyer_id') String buyerId,@JsonKey(name: 'seller_id') String sellerId,@JsonKey(name: 'unread_count_buyer') int unreadCountBuyer,@JsonKey(name: 'unread_count_seller') int unreadCountSeller,@JsonKey(name: 'last_message_at') DateTime? lastMessageAt,@JsonKey(name: 'created_at') DateTime createdAt,@JsonKey(name: 'updated_at') DateTime updatedAt,@JsonKey(name: 'is_pinned') bool isPinned,@JsonKey(name: 'is_archived') bool isArchived,@JsonKey(name: 'is_unread_override') bool isUnreadOverride, UserProfile? buyer, UserProfile? seller, ChatListingPreview? listing,@JsonKey(name: 'last_message') List<Message> lastMessage
});


$UserProfileCopyWith<$Res>? get buyer;$UserProfileCopyWith<$Res>? get seller;$ChatListingPreviewCopyWith<$Res>? get listing;

}
/// @nodoc
class _$ChatRoomCopyWithImpl<$Res>
    implements $ChatRoomCopyWith<$Res> {
  _$ChatRoomCopyWithImpl(this._self, this._then);

  final ChatRoom _self;
  final $Res Function(ChatRoom) _then;

/// Create a copy of ChatRoom
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? listingId = null,Object? buyerId = null,Object? sellerId = null,Object? unreadCountBuyer = null,Object? unreadCountSeller = null,Object? lastMessageAt = freezed,Object? createdAt = null,Object? updatedAt = null,Object? isPinned = null,Object? isArchived = null,Object? isUnreadOverride = null,Object? buyer = freezed,Object? seller = freezed,Object? listing = freezed,Object? lastMessage = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,listingId: null == listingId ? _self.listingId : listingId // ignore: cast_nullable_to_non_nullable
as String,buyerId: null == buyerId ? _self.buyerId : buyerId // ignore: cast_nullable_to_non_nullable
as String,sellerId: null == sellerId ? _self.sellerId : sellerId // ignore: cast_nullable_to_non_nullable
as String,unreadCountBuyer: null == unreadCountBuyer ? _self.unreadCountBuyer : unreadCountBuyer // ignore: cast_nullable_to_non_nullable
as int,unreadCountSeller: null == unreadCountSeller ? _self.unreadCountSeller : unreadCountSeller // ignore: cast_nullable_to_non_nullable
as int,lastMessageAt: freezed == lastMessageAt ? _self.lastMessageAt : lastMessageAt // ignore: cast_nullable_to_non_nullable
as DateTime?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,isPinned: null == isPinned ? _self.isPinned : isPinned // ignore: cast_nullable_to_non_nullable
as bool,isArchived: null == isArchived ? _self.isArchived : isArchived // ignore: cast_nullable_to_non_nullable
as bool,isUnreadOverride: null == isUnreadOverride ? _self.isUnreadOverride : isUnreadOverride // ignore: cast_nullable_to_non_nullable
as bool,buyer: freezed == buyer ? _self.buyer : buyer // ignore: cast_nullable_to_non_nullable
as UserProfile?,seller: freezed == seller ? _self.seller : seller // ignore: cast_nullable_to_non_nullable
as UserProfile?,listing: freezed == listing ? _self.listing : listing // ignore: cast_nullable_to_non_nullable
as ChatListingPreview?,lastMessage: null == lastMessage ? _self.lastMessage : lastMessage // ignore: cast_nullable_to_non_nullable
as List<Message>,
  ));
}
/// Create a copy of ChatRoom
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
}/// Create a copy of ChatRoom
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
}/// Create a copy of ChatRoom
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ChatListingPreviewCopyWith<$Res>? get listing {
    if (_self.listing == null) {
    return null;
  }

  return $ChatListingPreviewCopyWith<$Res>(_self.listing!, (value) {
    return _then(_self.copyWith(listing: value));
  });
}
}


/// Adds pattern-matching-related methods to [ChatRoom].
extension ChatRoomPatterns on ChatRoom {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ChatRoom value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ChatRoom() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ChatRoom value)  $default,){
final _that = this;
switch (_that) {
case _ChatRoom():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ChatRoom value)?  $default,){
final _that = this;
switch (_that) {
case _ChatRoom() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'listing_id')  String listingId, @JsonKey(name: 'buyer_id')  String buyerId, @JsonKey(name: 'seller_id')  String sellerId, @JsonKey(name: 'unread_count_buyer')  int unreadCountBuyer, @JsonKey(name: 'unread_count_seller')  int unreadCountSeller, @JsonKey(name: 'last_message_at')  DateTime? lastMessageAt, @JsonKey(name: 'created_at')  DateTime createdAt, @JsonKey(name: 'updated_at')  DateTime updatedAt, @JsonKey(name: 'is_pinned')  bool isPinned, @JsonKey(name: 'is_archived')  bool isArchived, @JsonKey(name: 'is_unread_override')  bool isUnreadOverride,  UserProfile? buyer,  UserProfile? seller,  ChatListingPreview? listing, @JsonKey(name: 'last_message')  List<Message> lastMessage)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ChatRoom() when $default != null:
return $default(_that.id,_that.listingId,_that.buyerId,_that.sellerId,_that.unreadCountBuyer,_that.unreadCountSeller,_that.lastMessageAt,_that.createdAt,_that.updatedAt,_that.isPinned,_that.isArchived,_that.isUnreadOverride,_that.buyer,_that.seller,_that.listing,_that.lastMessage);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'listing_id')  String listingId, @JsonKey(name: 'buyer_id')  String buyerId, @JsonKey(name: 'seller_id')  String sellerId, @JsonKey(name: 'unread_count_buyer')  int unreadCountBuyer, @JsonKey(name: 'unread_count_seller')  int unreadCountSeller, @JsonKey(name: 'last_message_at')  DateTime? lastMessageAt, @JsonKey(name: 'created_at')  DateTime createdAt, @JsonKey(name: 'updated_at')  DateTime updatedAt, @JsonKey(name: 'is_pinned')  bool isPinned, @JsonKey(name: 'is_archived')  bool isArchived, @JsonKey(name: 'is_unread_override')  bool isUnreadOverride,  UserProfile? buyer,  UserProfile? seller,  ChatListingPreview? listing, @JsonKey(name: 'last_message')  List<Message> lastMessage)  $default,) {final _that = this;
switch (_that) {
case _ChatRoom():
return $default(_that.id,_that.listingId,_that.buyerId,_that.sellerId,_that.unreadCountBuyer,_that.unreadCountSeller,_that.lastMessageAt,_that.createdAt,_that.updatedAt,_that.isPinned,_that.isArchived,_that.isUnreadOverride,_that.buyer,_that.seller,_that.listing,_that.lastMessage);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id, @JsonKey(name: 'listing_id')  String listingId, @JsonKey(name: 'buyer_id')  String buyerId, @JsonKey(name: 'seller_id')  String sellerId, @JsonKey(name: 'unread_count_buyer')  int unreadCountBuyer, @JsonKey(name: 'unread_count_seller')  int unreadCountSeller, @JsonKey(name: 'last_message_at')  DateTime? lastMessageAt, @JsonKey(name: 'created_at')  DateTime createdAt, @JsonKey(name: 'updated_at')  DateTime updatedAt, @JsonKey(name: 'is_pinned')  bool isPinned, @JsonKey(name: 'is_archived')  bool isArchived, @JsonKey(name: 'is_unread_override')  bool isUnreadOverride,  UserProfile? buyer,  UserProfile? seller,  ChatListingPreview? listing, @JsonKey(name: 'last_message')  List<Message> lastMessage)?  $default,) {final _that = this;
switch (_that) {
case _ChatRoom() when $default != null:
return $default(_that.id,_that.listingId,_that.buyerId,_that.sellerId,_that.unreadCountBuyer,_that.unreadCountSeller,_that.lastMessageAt,_that.createdAt,_that.updatedAt,_that.isPinned,_that.isArchived,_that.isUnreadOverride,_that.buyer,_that.seller,_that.listing,_that.lastMessage);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ChatRoom implements ChatRoom {
  const _ChatRoom({required this.id, @JsonKey(name: 'listing_id') required this.listingId, @JsonKey(name: 'buyer_id') required this.buyerId, @JsonKey(name: 'seller_id') required this.sellerId, @JsonKey(name: 'unread_count_buyer') this.unreadCountBuyer = 0, @JsonKey(name: 'unread_count_seller') this.unreadCountSeller = 0, @JsonKey(name: 'last_message_at') this.lastMessageAt, @JsonKey(name: 'created_at') required this.createdAt, @JsonKey(name: 'updated_at') required this.updatedAt, @JsonKey(name: 'is_pinned') this.isPinned = false, @JsonKey(name: 'is_archived') this.isArchived = false, @JsonKey(name: 'is_unread_override') this.isUnreadOverride = false, this.buyer, this.seller, this.listing, @JsonKey(name: 'last_message') final  List<Message> lastMessage = const []}): _lastMessage = lastMessage;
  factory _ChatRoom.fromJson(Map<String, dynamic> json) => _$ChatRoomFromJson(json);

@override final  String id;
@override@JsonKey(name: 'listing_id') final  String listingId;
@override@JsonKey(name: 'buyer_id') final  String buyerId;
@override@JsonKey(name: 'seller_id') final  String sellerId;
@override@JsonKey(name: 'unread_count_buyer') final  int unreadCountBuyer;
@override@JsonKey(name: 'unread_count_seller') final  int unreadCountSeller;
@override@JsonKey(name: 'last_message_at') final  DateTime? lastMessageAt;
@override@JsonKey(name: 'created_at') final  DateTime createdAt;
@override@JsonKey(name: 'updated_at') final  DateTime updatedAt;
// Per-room feature flags — added via migration 00034
@override@JsonKey(name: 'is_pinned') final  bool isPinned;
@override@JsonKey(name: 'is_archived') final  bool isArchived;
@override@JsonKey(name: 'is_unread_override') final  bool isUnreadOverride;
// Nested join data — populated only by fetchChatRooms query
@override final  UserProfile? buyer;
@override final  UserProfile? seller;
@override final  ChatListingPreview? listing;
 final  List<Message> _lastMessage;
@override@JsonKey(name: 'last_message') List<Message> get lastMessage {
  if (_lastMessage is EqualUnmodifiableListView) return _lastMessage;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_lastMessage);
}


/// Create a copy of ChatRoom
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ChatRoomCopyWith<_ChatRoom> get copyWith => __$ChatRoomCopyWithImpl<_ChatRoom>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ChatRoomToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ChatRoom&&(identical(other.id, id) || other.id == id)&&(identical(other.listingId, listingId) || other.listingId == listingId)&&(identical(other.buyerId, buyerId) || other.buyerId == buyerId)&&(identical(other.sellerId, sellerId) || other.sellerId == sellerId)&&(identical(other.unreadCountBuyer, unreadCountBuyer) || other.unreadCountBuyer == unreadCountBuyer)&&(identical(other.unreadCountSeller, unreadCountSeller) || other.unreadCountSeller == unreadCountSeller)&&(identical(other.lastMessageAt, lastMessageAt) || other.lastMessageAt == lastMessageAt)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.isPinned, isPinned) || other.isPinned == isPinned)&&(identical(other.isArchived, isArchived) || other.isArchived == isArchived)&&(identical(other.isUnreadOverride, isUnreadOverride) || other.isUnreadOverride == isUnreadOverride)&&(identical(other.buyer, buyer) || other.buyer == buyer)&&(identical(other.seller, seller) || other.seller == seller)&&(identical(other.listing, listing) || other.listing == listing)&&const DeepCollectionEquality().equals(other._lastMessage, _lastMessage));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,listingId,buyerId,sellerId,unreadCountBuyer,unreadCountSeller,lastMessageAt,createdAt,updatedAt,isPinned,isArchived,isUnreadOverride,buyer,seller,listing,const DeepCollectionEquality().hash(_lastMessage));

@override
String toString() {
  return 'ChatRoom(id: $id, listingId: $listingId, buyerId: $buyerId, sellerId: $sellerId, unreadCountBuyer: $unreadCountBuyer, unreadCountSeller: $unreadCountSeller, lastMessageAt: $lastMessageAt, createdAt: $createdAt, updatedAt: $updatedAt, isPinned: $isPinned, isArchived: $isArchived, isUnreadOverride: $isUnreadOverride, buyer: $buyer, seller: $seller, listing: $listing, lastMessage: $lastMessage)';
}


}

/// @nodoc
abstract mixin class _$ChatRoomCopyWith<$Res> implements $ChatRoomCopyWith<$Res> {
  factory _$ChatRoomCopyWith(_ChatRoom value, $Res Function(_ChatRoom) _then) = __$ChatRoomCopyWithImpl;
@override @useResult
$Res call({
 String id,@JsonKey(name: 'listing_id') String listingId,@JsonKey(name: 'buyer_id') String buyerId,@JsonKey(name: 'seller_id') String sellerId,@JsonKey(name: 'unread_count_buyer') int unreadCountBuyer,@JsonKey(name: 'unread_count_seller') int unreadCountSeller,@JsonKey(name: 'last_message_at') DateTime? lastMessageAt,@JsonKey(name: 'created_at') DateTime createdAt,@JsonKey(name: 'updated_at') DateTime updatedAt,@JsonKey(name: 'is_pinned') bool isPinned,@JsonKey(name: 'is_archived') bool isArchived,@JsonKey(name: 'is_unread_override') bool isUnreadOverride, UserProfile? buyer, UserProfile? seller, ChatListingPreview? listing,@JsonKey(name: 'last_message') List<Message> lastMessage
});


@override $UserProfileCopyWith<$Res>? get buyer;@override $UserProfileCopyWith<$Res>? get seller;@override $ChatListingPreviewCopyWith<$Res>? get listing;

}
/// @nodoc
class __$ChatRoomCopyWithImpl<$Res>
    implements _$ChatRoomCopyWith<$Res> {
  __$ChatRoomCopyWithImpl(this._self, this._then);

  final _ChatRoom _self;
  final $Res Function(_ChatRoom) _then;

/// Create a copy of ChatRoom
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? listingId = null,Object? buyerId = null,Object? sellerId = null,Object? unreadCountBuyer = null,Object? unreadCountSeller = null,Object? lastMessageAt = freezed,Object? createdAt = null,Object? updatedAt = null,Object? isPinned = null,Object? isArchived = null,Object? isUnreadOverride = null,Object? buyer = freezed,Object? seller = freezed,Object? listing = freezed,Object? lastMessage = null,}) {
  return _then(_ChatRoom(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,listingId: null == listingId ? _self.listingId : listingId // ignore: cast_nullable_to_non_nullable
as String,buyerId: null == buyerId ? _self.buyerId : buyerId // ignore: cast_nullable_to_non_nullable
as String,sellerId: null == sellerId ? _self.sellerId : sellerId // ignore: cast_nullable_to_non_nullable
as String,unreadCountBuyer: null == unreadCountBuyer ? _self.unreadCountBuyer : unreadCountBuyer // ignore: cast_nullable_to_non_nullable
as int,unreadCountSeller: null == unreadCountSeller ? _self.unreadCountSeller : unreadCountSeller // ignore: cast_nullable_to_non_nullable
as int,lastMessageAt: freezed == lastMessageAt ? _self.lastMessageAt : lastMessageAt // ignore: cast_nullable_to_non_nullable
as DateTime?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,isPinned: null == isPinned ? _self.isPinned : isPinned // ignore: cast_nullable_to_non_nullable
as bool,isArchived: null == isArchived ? _self.isArchived : isArchived // ignore: cast_nullable_to_non_nullable
as bool,isUnreadOverride: null == isUnreadOverride ? _self.isUnreadOverride : isUnreadOverride // ignore: cast_nullable_to_non_nullable
as bool,buyer: freezed == buyer ? _self.buyer : buyer // ignore: cast_nullable_to_non_nullable
as UserProfile?,seller: freezed == seller ? _self.seller : seller // ignore: cast_nullable_to_non_nullable
as UserProfile?,listing: freezed == listing ? _self.listing : listing // ignore: cast_nullable_to_non_nullable
as ChatListingPreview?,lastMessage: null == lastMessage ? _self._lastMessage : lastMessage // ignore: cast_nullable_to_non_nullable
as List<Message>,
  ));
}

/// Create a copy of ChatRoom
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
}/// Create a copy of ChatRoom
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
}/// Create a copy of ChatRoom
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ChatListingPreviewCopyWith<$Res>? get listing {
    if (_self.listing == null) {
    return null;
  }

  return $ChatListingPreviewCopyWith<$Res>(_self.listing!, (value) {
    return _then(_self.copyWith(listing: value));
  });
}
}

// dart format on

// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'carpool_vote.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$CarpoolVote {

 String get id;@JsonKey(name: 'proposal_id') String get proposalId;@JsonKey(name: 'voter_id') String get voterId;// NOTE: 'approve' counts toward required_votes; 'reject' does not
// but may trigger early proposal expiry depending on business rules.
 String get vote;@JsonKey(name: 'created_at') DateTime get createdAt;
/// Create a copy of CarpoolVote
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CarpoolVoteCopyWith<CarpoolVote> get copyWith => _$CarpoolVoteCopyWithImpl<CarpoolVote>(this as CarpoolVote, _$identity);

  /// Serializes this CarpoolVote to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CarpoolVote&&(identical(other.id, id) || other.id == id)&&(identical(other.proposalId, proposalId) || other.proposalId == proposalId)&&(identical(other.voterId, voterId) || other.voterId == voterId)&&(identical(other.vote, vote) || other.vote == vote)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,proposalId,voterId,vote,createdAt);

@override
String toString() {
  return 'CarpoolVote(id: $id, proposalId: $proposalId, voterId: $voterId, vote: $vote, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $CarpoolVoteCopyWith<$Res>  {
  factory $CarpoolVoteCopyWith(CarpoolVote value, $Res Function(CarpoolVote) _then) = _$CarpoolVoteCopyWithImpl;
@useResult
$Res call({
 String id,@JsonKey(name: 'proposal_id') String proposalId,@JsonKey(name: 'voter_id') String voterId, String vote,@JsonKey(name: 'created_at') DateTime createdAt
});




}
/// @nodoc
class _$CarpoolVoteCopyWithImpl<$Res>
    implements $CarpoolVoteCopyWith<$Res> {
  _$CarpoolVoteCopyWithImpl(this._self, this._then);

  final CarpoolVote _self;
  final $Res Function(CarpoolVote) _then;

/// Create a copy of CarpoolVote
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? proposalId = null,Object? voterId = null,Object? vote = null,Object? createdAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,proposalId: null == proposalId ? _self.proposalId : proposalId // ignore: cast_nullable_to_non_nullable
as String,voterId: null == voterId ? _self.voterId : voterId // ignore: cast_nullable_to_non_nullable
as String,vote: null == vote ? _self.vote : vote // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [CarpoolVote].
extension CarpoolVotePatterns on CarpoolVote {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CarpoolVote value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CarpoolVote() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CarpoolVote value)  $default,){
final _that = this;
switch (_that) {
case _CarpoolVote():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CarpoolVote value)?  $default,){
final _that = this;
switch (_that) {
case _CarpoolVote() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'proposal_id')  String proposalId, @JsonKey(name: 'voter_id')  String voterId,  String vote, @JsonKey(name: 'created_at')  DateTime createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CarpoolVote() when $default != null:
return $default(_that.id,_that.proposalId,_that.voterId,_that.vote,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'proposal_id')  String proposalId, @JsonKey(name: 'voter_id')  String voterId,  String vote, @JsonKey(name: 'created_at')  DateTime createdAt)  $default,) {final _that = this;
switch (_that) {
case _CarpoolVote():
return $default(_that.id,_that.proposalId,_that.voterId,_that.vote,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id, @JsonKey(name: 'proposal_id')  String proposalId, @JsonKey(name: 'voter_id')  String voterId,  String vote, @JsonKey(name: 'created_at')  DateTime createdAt)?  $default,) {final _that = this;
switch (_that) {
case _CarpoolVote() when $default != null:
return $default(_that.id,_that.proposalId,_that.voterId,_that.vote,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CarpoolVote implements CarpoolVote {
  const _CarpoolVote({required this.id, @JsonKey(name: 'proposal_id') required this.proposalId, @JsonKey(name: 'voter_id') required this.voterId, required this.vote, @JsonKey(name: 'created_at') required this.createdAt});
  factory _CarpoolVote.fromJson(Map<String, dynamic> json) => _$CarpoolVoteFromJson(json);

@override final  String id;
@override@JsonKey(name: 'proposal_id') final  String proposalId;
@override@JsonKey(name: 'voter_id') final  String voterId;
// NOTE: 'approve' counts toward required_votes; 'reject' does not
// but may trigger early proposal expiry depending on business rules.
@override final  String vote;
@override@JsonKey(name: 'created_at') final  DateTime createdAt;

/// Create a copy of CarpoolVote
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CarpoolVoteCopyWith<_CarpoolVote> get copyWith => __$CarpoolVoteCopyWithImpl<_CarpoolVote>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CarpoolVoteToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CarpoolVote&&(identical(other.id, id) || other.id == id)&&(identical(other.proposalId, proposalId) || other.proposalId == proposalId)&&(identical(other.voterId, voterId) || other.voterId == voterId)&&(identical(other.vote, vote) || other.vote == vote)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,proposalId,voterId,vote,createdAt);

@override
String toString() {
  return 'CarpoolVote(id: $id, proposalId: $proposalId, voterId: $voterId, vote: $vote, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$CarpoolVoteCopyWith<$Res> implements $CarpoolVoteCopyWith<$Res> {
  factory _$CarpoolVoteCopyWith(_CarpoolVote value, $Res Function(_CarpoolVote) _then) = __$CarpoolVoteCopyWithImpl;
@override @useResult
$Res call({
 String id,@JsonKey(name: 'proposal_id') String proposalId,@JsonKey(name: 'voter_id') String voterId, String vote,@JsonKey(name: 'created_at') DateTime createdAt
});




}
/// @nodoc
class __$CarpoolVoteCopyWithImpl<$Res>
    implements _$CarpoolVoteCopyWith<$Res> {
  __$CarpoolVoteCopyWithImpl(this._self, this._then);

  final _CarpoolVote _self;
  final $Res Function(_CarpoolVote) _then;

/// Create a copy of CarpoolVote
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? proposalId = null,Object? voterId = null,Object? vote = null,Object? createdAt = null,}) {
  return _then(_CarpoolVote(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,proposalId: null == proposalId ? _self.proposalId : proposalId // ignore: cast_nullable_to_non_nullable
as String,voterId: null == voterId ? _self.voterId : voterId // ignore: cast_nullable_to_non_nullable
as String,vote: null == vote ? _self.vote : vote // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on

// ignore_for_file: invalid_annotation_target
import 'package:freezed_annotation/freezed_annotation.dart';

part 'review_tag.freezed.dart';
part 'review_tag.g.dart';

@freezed
abstract class ReviewTag with _$ReviewTag {
  const factory ReviewTag({
    required String id,
    required String name,
    required String type, // 'buyer', 'seller', or 'general'
    @JsonKey(name: 'created_at') required DateTime createdAt,
  }) = _ReviewTag;

  factory ReviewTag.fromJson(Map<String, dynamic> json) =>
      _$ReviewTagFromJson(json);
}

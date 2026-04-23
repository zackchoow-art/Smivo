// ignore_for_file: invalid_annotation_target
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:smivo/data/models/user_profile.dart';

part 'order_evidence.freezed.dart';
part 'order_evidence.g.dart';

/// Represents a photo uploaded as delivery evidence.
@freezed
abstract class OrderEvidence with _$OrderEvidence {
  const factory OrderEvidence({
    required String id,
    @JsonKey(name: 'order_id') required String orderId,
    @JsonKey(name: 'uploader_id') required String uploaderId,
    @JsonKey(name: 'image_url') required String imageUrl,
    String? caption,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    @JsonKey(name: 'updated_at') required DateTime updatedAt,
    UserProfile? uploader,
  }) = _OrderEvidence;

  factory OrderEvidence.fromJson(Map<String, dynamic> json) =>
      _$OrderEvidenceFromJson(json);
}

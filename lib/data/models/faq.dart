// ignore_for_file: invalid_annotation_target
import 'package:freezed_annotation/freezed_annotation.dart';

part 'faq.freezed.dart';
part 'faq.g.dart';

/// A help/FAQ entry. Can be global (school_id = null) or
/// school-specific. Global FAQs serve as templates that are
/// copied into school-specific FAQs via seed_school_defaults().
@freezed
abstract class Faq with _$Faq {
  const factory Faq({
    required String id,
    // NOTE: null = global FAQ (visible to all schools)
    @JsonKey(name: 'school_id') String? schoolId,
    required String category,
    required String question,
    required String answer,
    @JsonKey(name: 'display_order') required int displayOrder,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    @JsonKey(name: 'updated_at') required DateTime updatedAt,
  }) = _Faq;

  factory Faq.fromJson(Map<String, dynamic> json) => _$FaqFromJson(json);
}

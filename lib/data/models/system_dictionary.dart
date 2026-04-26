// ignore_for_file: invalid_annotation_target
import 'package:freezed_annotation/freezed_annotation.dart';

part 'system_dictionary.freezed.dart';
part 'system_dictionary.g.dart';

/// A key-value entry in the system data dictionary.
///
/// Groups related constants (order statuses, notification types, etc.)
/// under a dict_type. The extra field stores UI metadata like icon
/// names and color hex values.
@freezed
abstract class SystemDictionary with _$SystemDictionary {
  const factory SystemDictionary({
    required String id,
    @JsonKey(name: 'dict_type') required String dictType,
    @JsonKey(name: 'dict_key') required String dictKey,
    @JsonKey(name: 'dict_value') required String dictValue,
    String? description,
    Map<String, dynamic>? extra,
    @JsonKey(name: 'display_order') @Default(0) int displayOrder,
    @JsonKey(name: 'is_active') @Default(true) bool isActive,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    @JsonKey(name: 'updated_at') required DateTime updatedAt,
  }) = _SystemDictionary;

  factory SystemDictionary.fromJson(Map<String, dynamic> json) =>
      _$SystemDictionaryFromJson(json);
}

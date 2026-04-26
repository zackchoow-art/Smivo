import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:smivo/data/models/system_dictionary.dart';
import 'package:smivo/data/repositories/school_data_repository.dart';

part 'admin_dictionary_provider.g.dart';

/// Fetches all system dictionary entries, optionally filtered by type.
@riverpod
Future<List<SystemDictionary>> adminDictionaries(
  Ref ref, {
  String? dictType,
}) async {
  return ref.watch(schoolDataRepositoryProvider).fetchDictionaries(dictType: dictType);
}

/// Fetches distinct dict_type values for the filter dropdown.
@riverpod
Future<List<String>> adminDictTypes(Ref ref) async {
  final all = await ref.watch(schoolDataRepositoryProvider).fetchDictionaries();
  final types = all.map((d) => d.dictType).toSet().toList()..sort();
  return types;
}

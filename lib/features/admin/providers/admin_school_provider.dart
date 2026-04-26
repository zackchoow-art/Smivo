import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:smivo/data/models/school.dart';
import 'package:smivo/data/repositories/school_repository.dart';

part 'admin_school_provider.g.dart';

@riverpod
class AdminSchoolController extends _$AdminSchoolController {
  @override
  FutureOr<List<School>> build() async {
    return ref.watch(schoolRepositoryProvider).fetchAllSchools();
  }

  Future<void> addSchool(School school) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final newSchool = await ref.read(schoolRepositoryProvider).createSchool(school);
      final currentList = state.valueOrNull ?? [];
      return [...currentList, newSchool]..sort((a, b) => a.name.compareTo(b.name));
    });
  }

  Future<void> updateSchool(School school) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final updatedSchool = await ref.read(schoolRepositoryProvider).updateSchool(school);
      final currentList = state.valueOrNull ?? [];
      return currentList.map((e) => e.id == updatedSchool.id ? updatedSchool : e).toList()
        ..sort((a, b) => a.name.compareTo(b.name));
    });
  }

  Future<void> deleteSchool(String id) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(schoolRepositoryProvider).deleteSchool(id);
      final currentList = state.valueOrNull ?? [];
      return currentList.where((e) => e.id != id).toList();
    });
  }
}

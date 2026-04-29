import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:smivo/data/models/faq.dart';
import 'package:smivo/data/repositories/faq_repository.dart';

part 'admin_faq_provider.g.dart';

@riverpod
class AdminFaqController extends _$AdminFaqController {
  @override
  FutureOr<List<Faq>> build() async {
    return ref.watch(faqRepositoryProvider).fetchFaqs();
  }

  Future<void> addFaq(Faq faq) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final newFaq = await ref.read(faqRepositoryProvider).createFaq(faq);
      final currentList = state.valueOrNull ?? [];
      return [...currentList, newFaq]
        ..sort((a, b) => a.displayOrder.compareTo(b.displayOrder));
    });
  }

  Future<void> updateFaq(Faq faq) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final updatedFaq = await ref.read(faqRepositoryProvider).updateFaq(faq);
      final currentList = state.valueOrNull ?? [];
      return currentList
          .map((e) => e.id == updatedFaq.id ? updatedFaq : e)
          .toList()
        ..sort((a, b) => a.displayOrder.compareTo(b.displayOrder));
    });
  }

  Future<void> deleteFaq(String id) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(faqRepositoryProvider).deleteFaq(id);
      final currentList = state.valueOrNull ?? [];
      return currentList.where((e) => e.id != id).toList();
    });
  }
}

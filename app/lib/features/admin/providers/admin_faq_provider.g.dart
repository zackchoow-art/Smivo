// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_faq_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(AdminFaqController)
final adminFaqControllerProvider = AdminFaqControllerProvider._();

final class AdminFaqControllerProvider
    extends $AsyncNotifierProvider<AdminFaqController, List<Faq>> {
  AdminFaqControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'adminFaqControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$adminFaqControllerHash();

  @$internal
  @override
  AdminFaqController create() => AdminFaqController();
}

String _$adminFaqControllerHash() =>
    r'2a3581c749e9317d75aeae300b916a01316e900c';

abstract class _$AdminFaqController extends $AsyncNotifier<List<Faq>> {
  FutureOr<List<Faq>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<List<Faq>>, List<Faq>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<Faq>>, List<Faq>>,
              AsyncValue<List<Faq>>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_school_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(AdminSchoolController)
final adminSchoolControllerProvider = AdminSchoolControllerProvider._();

final class AdminSchoolControllerProvider
    extends $AsyncNotifierProvider<AdminSchoolController, List<School>> {
  AdminSchoolControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'adminSchoolControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$adminSchoolControllerHash();

  @$internal
  @override
  AdminSchoolController create() => AdminSchoolController();
}

String _$adminSchoolControllerHash() =>
    r'3d670d44b0e316bbcbc8323231a93b7cc2fd04fd';

abstract class _$AdminSchoolController extends $AsyncNotifier<List<School>> {
  FutureOr<List<School>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<List<School>>, List<School>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<School>>, List<School>>,
              AsyncValue<List<School>>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

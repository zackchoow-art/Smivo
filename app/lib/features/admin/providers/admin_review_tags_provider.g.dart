// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_review_tags_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(AdminReviewTags)
final adminReviewTagsProvider = AdminReviewTagsProvider._();

final class AdminReviewTagsProvider
    extends
        $AsyncNotifierProvider<AdminReviewTags, List<Map<String, dynamic>>> {
  AdminReviewTagsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'adminReviewTagsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$adminReviewTagsHash();

  @$internal
  @override
  AdminReviewTags create() => AdminReviewTags();
}

String _$adminReviewTagsHash() => r'a83c7ffbf3d7911af08da3095221b683faed3160';

abstract class _$AdminReviewTags
    extends $AsyncNotifier<List<Map<String, dynamic>>> {
  FutureOr<List<Map<String, dynamic>>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref
            as $Ref<
              AsyncValue<List<Map<String, dynamic>>>,
              List<Map<String, dynamic>>
            >;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<List<Map<String, dynamic>>>,
                List<Map<String, dynamic>>
              >,
              AsyncValue<List<Map<String, dynamic>>>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

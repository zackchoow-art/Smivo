// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'feedback_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(MyFeedbacks)
final myFeedbacksProvider = MyFeedbacksProvider._();

final class MyFeedbacksProvider
    extends $AsyncNotifierProvider<MyFeedbacks, List<UserFeedback>> {
  MyFeedbacksProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'myFeedbacksProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$myFeedbacksHash();

  @$internal
  @override
  MyFeedbacks create() => MyFeedbacks();
}

String _$myFeedbacksHash() => r'7b0dc40e939a31c43af459c0c491b1094b7740c0';

abstract class _$MyFeedbacks extends $AsyncNotifier<List<UserFeedback>> {
  FutureOr<List<UserFeedback>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref as $Ref<AsyncValue<List<UserFeedback>>, List<UserFeedback>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<UserFeedback>>, List<UserFeedback>>,
              AsyncValue<List<UserFeedback>>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

@ProviderFor(SubmitFeedbackAction)
final submitFeedbackActionProvider = SubmitFeedbackActionProvider._();

final class SubmitFeedbackActionProvider
    extends $NotifierProvider<SubmitFeedbackAction, AsyncValue<void>> {
  SubmitFeedbackActionProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'submitFeedbackActionProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$submitFeedbackActionHash();

  @$internal
  @override
  SubmitFeedbackAction create() => SubmitFeedbackAction();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AsyncValue<void> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AsyncValue<void>>(value),
    );
  }
}

String _$submitFeedbackActionHash() =>
    r'c56c6a329e7fa7e97882b65f9c8357e2e253e99b';

abstract class _$SubmitFeedbackAction extends $Notifier<AsyncValue<void>> {
  AsyncValue<void> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<void>, AsyncValue<void>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<void>, AsyncValue<void>>,
              AsyncValue<void>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

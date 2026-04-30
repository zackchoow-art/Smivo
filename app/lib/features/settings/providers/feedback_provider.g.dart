// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'feedback_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$myFeedbacksHash() => r'c5d52007494e9929bfa68b3f97d270a88ff92360';

/// See also [MyFeedbacks].
@ProviderFor(MyFeedbacks)
final myFeedbacksProvider =
    AutoDisposeAsyncNotifierProvider<MyFeedbacks, List<UserFeedback>>.internal(
      MyFeedbacks.new,
      name: r'myFeedbacksProvider',
      debugGetCreateSourceHash:
          const bool.fromEnvironment('dart.vm.product')
              ? null
              : _$myFeedbacksHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$MyFeedbacks = AutoDisposeAsyncNotifier<List<UserFeedback>>;
String _$submitFeedbackActionHash() =>
    r'e21f02c1f675a471124646d01520471b54257cef';

/// See also [SubmitFeedbackAction].
@ProviderFor(SubmitFeedbackAction)
final submitFeedbackActionProvider = AutoDisposeNotifierProvider<
  SubmitFeedbackAction,
  AsyncValue<void>
>.internal(
  SubmitFeedbackAction.new,
  name: r'submitFeedbackActionProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$submitFeedbackActionHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$SubmitFeedbackAction = AutoDisposeNotifier<AsyncValue<void>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'school_data_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Fetches active categories for the current user's school.
/// Falls back to AppConstants.categories if DB returns empty.

@ProviderFor(mySchoolCategories)
final mySchoolCategoriesProvider = MySchoolCategoriesProvider._();

/// Fetches active categories for the current user's school.
/// Falls back to AppConstants.categories if DB returns empty.

final class MySchoolCategoriesProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<SchoolCategory>>,
          List<SchoolCategory>,
          FutureOr<List<SchoolCategory>>
        >
    with
        $FutureModifier<List<SchoolCategory>>,
        $FutureProvider<List<SchoolCategory>> {
  /// Fetches active categories for the current user's school.
  /// Falls back to AppConstants.categories if DB returns empty.
  MySchoolCategoriesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'mySchoolCategoriesProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$mySchoolCategoriesHash();

  @$internal
  @override
  $FutureProviderElement<List<SchoolCategory>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<SchoolCategory>> create(Ref ref) {
    return mySchoolCategories(ref);
  }
}

String _$mySchoolCategoriesHash() =>
    r'18210e355ac7b32ba3e8bd3fb68b92d7f6eb3511';

/// Fetches active conditions for the current user's school.
/// Falls back to hardcoded list if DB returns empty.

@ProviderFor(mySchoolConditions)
final mySchoolConditionsProvider = MySchoolConditionsProvider._();

/// Fetches active conditions for the current user's school.
/// Falls back to hardcoded list if DB returns empty.

final class MySchoolConditionsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<SchoolCondition>>,
          List<SchoolCondition>,
          FutureOr<List<SchoolCondition>>
        >
    with
        $FutureModifier<List<SchoolCondition>>,
        $FutureProvider<List<SchoolCondition>> {
  /// Fetches active conditions for the current user's school.
  /// Falls back to hardcoded list if DB returns empty.
  MySchoolConditionsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'mySchoolConditionsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$mySchoolConditionsHash();

  @$internal
  @override
  $FutureProviderElement<List<SchoolCondition>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<SchoolCondition>> create(Ref ref) {
    return mySchoolConditions(ref);
  }
}

String _$mySchoolConditionsHash() =>
    r'fdbdb652066868987afe2c1f4909fd4a513fe3e5';

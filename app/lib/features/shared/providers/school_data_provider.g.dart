// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'school_data_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$mySchoolCategoriesHash() =>
    r'29ce49dbf49c8d4afbc4728229fba9e311ea1f29';

/// Fetches active categories for the current user's school.
/// Falls back to AppConstants.categories if DB returns empty.
///
/// Copied from [mySchoolCategories].
@ProviderFor(mySchoolCategories)
final mySchoolCategoriesProvider =
    AutoDisposeFutureProvider<List<SchoolCategory>>.internal(
      mySchoolCategories,
      name: r'mySchoolCategoriesProvider',
      debugGetCreateSourceHash:
          const bool.fromEnvironment('dart.vm.product')
              ? null
              : _$mySchoolCategoriesHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef MySchoolCategoriesRef =
    AutoDisposeFutureProviderRef<List<SchoolCategory>>;
String _$mySchoolConditionsHash() =>
    r'c14812776d169bc560a80419830ae14157e9a32a';

/// Fetches active conditions for the current user's school.
/// Falls back to hardcoded list if DB returns empty.
///
/// Copied from [mySchoolConditions].
@ProviderFor(mySchoolConditions)
final mySchoolConditionsProvider =
    AutoDisposeFutureProvider<List<SchoolCondition>>.internal(
      mySchoolConditions,
      name: r'mySchoolConditionsProvider',
      debugGetCreateSourceHash:
          const bool.fromEnvironment('dart.vm.product')
              ? null
              : _$mySchoolConditionsHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef MySchoolConditionsRef =
    AutoDisposeFutureProviderRef<List<SchoolCondition>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package

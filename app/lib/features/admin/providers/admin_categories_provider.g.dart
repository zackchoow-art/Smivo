// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_categories_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Fetches categories for a given school.

@ProviderFor(adminSchoolCategories)
final adminSchoolCategoriesProvider = AdminSchoolCategoriesFamily._();

/// Fetches categories for a given school.

final class AdminSchoolCategoriesProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<SchoolCategory>>,
          List<SchoolCategory>,
          FutureOr<List<SchoolCategory>>
        >
    with
        $FutureModifier<List<SchoolCategory>>,
        $FutureProvider<List<SchoolCategory>> {
  /// Fetches categories for a given school.
  AdminSchoolCategoriesProvider._({
    required AdminSchoolCategoriesFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'adminSchoolCategoriesProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$adminSchoolCategoriesHash();

  @override
  String toString() {
    return r'adminSchoolCategoriesProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<SchoolCategory>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<SchoolCategory>> create(Ref ref) {
    final argument = this.argument as String;
    return adminSchoolCategories(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is AdminSchoolCategoriesProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$adminSchoolCategoriesHash() =>
    r'3764de7bfc6789fa4dede6390efc64884a7cfe62';

/// Fetches categories for a given school.

final class AdminSchoolCategoriesFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<SchoolCategory>>, String> {
  AdminSchoolCategoriesFamily._()
    : super(
        retry: null,
        name: r'adminSchoolCategoriesProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Fetches categories for a given school.

  AdminSchoolCategoriesProvider call(String schoolId) =>
      AdminSchoolCategoriesProvider._(argument: schoolId, from: this);

  @override
  String toString() => r'adminSchoolCategoriesProvider';
}

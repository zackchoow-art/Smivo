// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_conditions_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Fetches conditions for a given school.

@ProviderFor(adminSchoolConditions)
final adminSchoolConditionsProvider = AdminSchoolConditionsFamily._();

/// Fetches conditions for a given school.

final class AdminSchoolConditionsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<SchoolCondition>>,
          List<SchoolCondition>,
          FutureOr<List<SchoolCondition>>
        >
    with
        $FutureModifier<List<SchoolCondition>>,
        $FutureProvider<List<SchoolCondition>> {
  /// Fetches conditions for a given school.
  AdminSchoolConditionsProvider._({
    required AdminSchoolConditionsFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'adminSchoolConditionsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$adminSchoolConditionsHash();

  @override
  String toString() {
    return r'adminSchoolConditionsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<SchoolCondition>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<SchoolCondition>> create(Ref ref) {
    final argument = this.argument as String;
    return adminSchoolConditions(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is AdminSchoolConditionsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$adminSchoolConditionsHash() =>
    r'c196d493b80f8f0266732675632ad1e14049b21a';

/// Fetches conditions for a given school.

final class AdminSchoolConditionsFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<SchoolCondition>>, String> {
  AdminSchoolConditionsFamily._()
    : super(
        retry: null,
        name: r'adminSchoolConditionsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Fetches conditions for a given school.

  AdminSchoolConditionsProvider call(String schoolId) =>
      AdminSchoolConditionsProvider._(argument: schoolId, from: this);

  @override
  String toString() => r'adminSchoolConditionsProvider';
}

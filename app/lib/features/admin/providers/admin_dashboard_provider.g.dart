// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_dashboard_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(adminDashboardMetrics)
final adminDashboardMetricsProvider = AdminDashboardMetricsProvider._();

final class AdminDashboardMetricsProvider
    extends
        $FunctionalProvider<
          AsyncValue<DashboardMetrics>,
          DashboardMetrics,
          FutureOr<DashboardMetrics>
        >
    with $FutureModifier<DashboardMetrics>, $FutureProvider<DashboardMetrics> {
  AdminDashboardMetricsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'adminDashboardMetricsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$adminDashboardMetricsHash();

  @$internal
  @override
  $FutureProviderElement<DashboardMetrics> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<DashboardMetrics> create(Ref ref) {
    return adminDashboardMetrics(ref);
  }
}

String _$adminDashboardMetricsHash() =>
    r'6c85018d2f84d3000b8a258785037f2dd6c3cfc3';

@ProviderFor(adminRecentOrders)
final adminRecentOrdersProvider = AdminRecentOrdersProvider._();

final class AdminRecentOrdersProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Map<String, dynamic>>>,
          List<Map<String, dynamic>>,
          FutureOr<List<Map<String, dynamic>>>
        >
    with
        $FutureModifier<List<Map<String, dynamic>>>,
        $FutureProvider<List<Map<String, dynamic>>> {
  AdminRecentOrdersProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'adminRecentOrdersProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$adminRecentOrdersHash();

  @$internal
  @override
  $FutureProviderElement<List<Map<String, dynamic>>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<Map<String, dynamic>>> create(Ref ref) {
    return adminRecentOrders(ref);
  }
}

String _$adminRecentOrdersHash() => r'da718b6e59fc855371045358df0b0bbb27267fb6';

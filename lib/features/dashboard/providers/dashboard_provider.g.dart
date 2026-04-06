// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dashboard_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$dashboardSummaryHash() => r'b4e0d0b44d42e87b78f4c542616bda70799953c2';

/// See also [dashboardSummary].
@ProviderFor(dashboardSummary)
final dashboardSummaryProvider = FutureProvider<DashboardSummary>.internal(
  dashboardSummary,
  name: r'dashboardSummaryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$dashboardSummaryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef DashboardSummaryRef = FutureProviderRef<DashboardSummary>;
String _$spendingTrendHash() => r'ecc186d262d86c833a985caa0347084e1069ee9d';

/// See also [spendingTrend].
@ProviderFor(spendingTrend)
final spendingTrendProvider = FutureProvider<List<double>>.internal(
  spendingTrend,
  name: r'spendingTrendProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$spendingTrendHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef SpendingTrendRef = FutureProviderRef<List<double>>;
String _$chartPeriodNotifierHash() =>
    r'c65abbb10c2a3bfc2de7d99ead79f91b8fc82d6f';

/// See also [ChartPeriodNotifier].
@ProviderFor(ChartPeriodNotifier)
final chartPeriodNotifierProvider =
    AutoDisposeNotifierProvider<ChartPeriodNotifier, ChartPeriod>.internal(
      ChartPeriodNotifier.new,
      name: r'chartPeriodNotifierProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$chartPeriodNotifierHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$ChartPeriodNotifier = AutoDisposeNotifier<ChartPeriod>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package

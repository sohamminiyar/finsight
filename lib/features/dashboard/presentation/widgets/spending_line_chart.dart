import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../providers/dashboard_provider.dart';

class SpendingLineChart extends ConsumerWidget {
  const SpendingLineChart({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screenSize = MediaQuery.sizeOf(context);
    final period = ref.watch(chartPeriodNotifierProvider);
    final trendAsync = ref.watch(spendingTrendProvider);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          if (!isDark)
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Spending Analytics',
                    style: AppTextStyles.headlineSmall(context).copyWith(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  SizedBox(
                    width: 140,
                    child: Text(
                      period == ChartPeriod.week 
                        ? 'Daily spending trends' 
                        : 'Weekly spending totals',
                      style: AppTextStyles.bodySmall(context).copyWith(
                        color: Colors.grey,
                        height: 1.2,
                      ),
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkScaffold : Colors.grey[100],
                  borderRadius: BorderRadius.circular(32),
                ),
                child: Row(
                  children: [
                    _buildToggleButton(
                      context,
                      ref,
                      label: 'WEEK',
                      isSelected: period == ChartPeriod.week,
                      onTap: () => ref.read(chartPeriodNotifierProvider.notifier).setPeriod(ChartPeriod.week),
                    ),
                    _buildToggleButton(
                      context,
                      ref,
                      label: 'MONTH',
                      isSelected: period == ChartPeriod.month,
                      onTap: () => ref.read(chartPeriodNotifierProvider.notifier).setPeriod(ChartPeriod.month),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          SizedBox(
            height: screenSize.height * 0.22,
            child: trendAsync.when(
              data: (data) {
                if (data.isEmpty) return const Center(child: Text('No data available'));
                
                final spots = data.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value)).toList();
                final maxVal = data.reduce((a, b) => a > b ? a : b);
                final yMax = maxVal == 0 ? 100.0 : maxVal * 1.2;

                return LineChart(
                  LineChartData(
                    lineTouchData: LineTouchData(
                      handleBuiltInTouches: true,
                      touchTooltipData: LineTouchTooltipData(
                        getTooltipColor: (touchedSpot) => const Color(0xFF006080),
                        tooltipRoundedRadius: 12,
                        getTooltipItems: (List<LineBarSpot> touchedSpots) {
                          return touchedSpots.map((LineBarSpot touchedSpot) {
                            return LineTooltipItem(
                              '₹${touchedSpot.y.toStringAsFixed(0)}',
                              const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            );
                          }).toList();
                        },
                      ),
                    ),
                    gridData: const FlGridData(show: false),
                    titlesData: FlTitlesData(
                      show: true,
                      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 30,
                          interval: 1,
                          getTitlesWidget: (value, meta) {
                            if (period == ChartPeriod.week) {
                              const days = ['MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT', 'SUN'];
                              if (value.toInt() >= 0 && value.toInt() < 7) {
                                return Padding(
                                  padding: const EdgeInsets.only(top: 12.0),
                                  child: Text(
                                    days[value.toInt()],
                                    style: AppTextStyles.bodySmall(context).copyWith(
                                      color: Colors.grey,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                );
                              }
                            } else {
                              final weeks = ['3W AGO', '2W AGO', 'LAST W', 'THIS W'];
                              if (value.toInt() >= 0 && value.toInt() < 4) {
                                return Padding(
                                  padding: const EdgeInsets.only(top: 12.0),
                                  child: Text(
                                    weeks[value.toInt()],
                                    style: AppTextStyles.bodySmall(context).copyWith(
                                      color: Colors.grey,
                                      fontSize: 9,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                );
                              }
                            }
                            return const SizedBox.shrink();
                          },
                        ),
                      ),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 45,
                          getTitlesWidget: (value, meta) {
                            if (value == 0) return const SizedBox.shrink();
                            return Text(
                              '₹${value.toInt()}',
                              style: const TextStyle(color: Colors.grey, fontSize: 10),
                            );
                          },
                        ),
                      ),
                    ),
                    borderData: FlBorderData(show: false),
                    minX: 0,
                    maxX: (period == ChartPeriod.week ? 6 : 3).toDouble(),
                    minY: 0,
                    maxY: yMax,
                    lineBarsData: [
                      LineChartBarData(
                        spots: spots,
                        isCurved: true,
                        curveSmoothness: 0.35,
                        color: const Color(0xFF0080A0),
                        barWidth: 3,
                        isStrokeCapRound: true,
                        dotData: const FlDotData(show: true),
                        belowBarData: BarAreaData(
                          show: true,
                          gradient: LinearGradient(
                            colors: [
                              const Color(0xFF0080A0).withOpacity(0.2),
                              const Color(0xFF0080A0).withOpacity(0.0),
                            ],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, s) => Center(child: Text('Error: $e')),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToggleButton(
    BuildContext context, 
    WidgetRef ref, {
    required String label, 
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF006080) : Colors.transparent,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey,
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
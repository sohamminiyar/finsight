import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

class CategoryPieChart extends StatelessWidget {
  const CategoryPieChart({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        SizedBox(
          height: 200,
          child: PieChart(
            PieChartData(
              sectionsSpace: 0,
              centerSpaceRadius: 40,
              sections: [
                PieChartSectionData(
                  color: AppColors.primary,
                  value: 40,
                  title: '40%',
                  radius: 50,
                  titleStyle: AppTextStyles.labelLarge(context).copyWith(color: Colors.white),
                ),
                PieChartSectionData(
                  color: AppColors.income,
                  value: 30,
                  title: '30%',
                  radius: 50,
                  titleStyle: AppTextStyles.labelLarge(context).copyWith(color: Colors.white),
                ),
                PieChartSectionData(
                  color: AppColors.expense,
                  value: 15,
                  title: '15%',
                  radius: 50,
                  titleStyle: AppTextStyles.labelLarge(context).copyWith(color: Colors.white),
                ),
                PieChartSectionData(
                  color: Colors.amber,
                  value: 15,
                  title: '15%',
                  radius: 50,
                  titleStyle: AppTextStyles.labelLarge(context).copyWith(color: Colors.white),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
        _buildLegend(context),
      ],
    );
  }

  Widget _buildLegend(BuildContext context) {
    return Wrap(
      spacing: 16,
      runSpacing: 12,
      alignment: WrapAlignment.center,
      children: [
        _buildLegendItem(context, 'Housing', AppColors.primary),
        _buildLegendItem(context, 'Food', AppColors.income),
        _buildLegendItem(context, 'Transport', AppColors.expense),
        _buildLegendItem(context, 'Others', Colors.amber),
      ],
    );
  }

  Widget _buildLegendItem(BuildContext context, String label, Color color) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: AppTextStyles.bodySmall(context).copyWith(
            color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
          ),
        ),
      ],
    );
  }
}

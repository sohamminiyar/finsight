import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

class WeeklyComparisonBar extends StatelessWidget {
  const WeeklyComparisonBar({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Weekly Comparison',
          style: AppTextStyles.headlineSmall(context).copyWith(
            fontSize: 18,
            color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            _buildBarItem(context, 'Last Week', 1200, AppColors.primary.withOpacity(0.4)),
            const SizedBox(width: 16),
            _buildBarItem(context, 'This Week', 1500, AppColors.primary),
          ],
        ),
      ],
    );
  }

  Widget _buildBarItem(BuildContext context, String label, double value, Color color) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 12,
            width: double.infinity,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(6),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: AppTextStyles.bodySmall(context).copyWith(
                  color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                ),
              ),
              Text(
                '₹${value.toStringAsFixed(0)}',
                style: AppTextStyles.labelLarge(context).copyWith(
                  color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
